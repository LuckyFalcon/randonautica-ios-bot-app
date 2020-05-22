// Copyright (c) 2017 Vault12, Inc.
// MIT License https://opensource.org/licenses/MIT
//
// Entropy generation screen

import UIKit
import AVFoundation
import Flutter

extension String: Error {}

class GenerationController: UIViewController, CameraFramesDelegate, UITableViewDataSource, UITableViewDelegate {
    static var isCancelled = false
    
    var frames: CameraFrames?
    var ticker = 0
    var blockNumber = 0
    var timer = Timer()
    var defaults = UserDefaults.standard
    
    var cameraRadius: CGFloat = 0
    var cameraCenterY: CGFloat = 0
    
    @IBOutlet weak var overlay: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var overlayStatus: UILabel!
    @IBOutlet weak var settingsTable: UITableView!
    
    var stats = ["TIME ELAPSED",
                 "BYTES IN BUFFER",
                 "ENTROPY GENERATED",
                 "χ² OF LAST BLOCK",
                 "REJECTED FRAMES",
                 "OVERSATURATED"]
    
    // for loading TrueEntropy view (soliax) (https://medium.com/@cosinus84/flutter-view-controller-used-in-ios-app-using-coordinator-pattern-8896339d64ba)
    var coordinatorDelegate: TrueEntropyCoordinatorDelegate?
    var bytesNeeded: Int = 0
    var rngType: String = ""
    var channel: FlutterMethodChannel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GenerationController.isCancelled = false
        
        // as we bypass the SettingsController and load this GenerationController
        // directly from flutter, we set our default values here (soliax)
        defaults.set(2, forKey: "speed")
        defaults.set("libwrapper", forKey: "delivery")
        defaults.set(false, forKey: "upload_csv")
        defaults.set(bytesNeeded, forKey: "block_size")
        defaults.set(1, forKey: "block_amount")
        defaults.set(false, forKey: "block_amount_unlimited")
        defaults.set("", forKey: "relay")
        defaults.set("", forKey: "recipient")
        defaults.set(330, forKey: "x2_limit")
        defaults.set(false, forKey: "x2_limit_enabled")
        
        // app should stay always active when entropy generation started
        UIApplication.shared.isIdleTimerDisabled = true
        
        cameraRadius = (self.view!.layer.bounds.width - 20) / 2
        cameraCenterY = (self.view!.layer.bounds.height - 250) / 2 - cameraRadius
        
        // fix layout for iPhone X
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
            cameraCenterY -= 16
        }
        
        // 2020-04-10 insertion hack by soliax
        // quick repurposing this UI and upload code to use SteveLib (libTemporal) instead of CamRNG
        if (rngType == "goToTemporal") {
            // remove all the CamRNG stats from the table except the timer
            stats = ["TIME ELAPSED"]
            settingsTable.dataSource = self
            settingsTable.delegate = self
            settingsTable.tableFooterView = UIView()
            
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(timerForSteveAction), userInfo: nil, repeats: true)
            
            // Rotating image on center
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = CGFloat.pi * 2
            animation.duration = Constants.spinnerAnimationDuration
            animation.repeatCount = .infinity
            animation.isRemovedOnCompletion = false
            overlay.layer.add(animation, forKey: "spinAnimation")
            
            // summon Steve to generate magical entropy (on a background thread to not freeze the UI)
            let concurrentQueue = DispatchQueue.init(label: "concurrentQueue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
            concurrentQueue.async {
                let steveBytes: UnsafeMutablePointer<UInt8> = hitBooks(Int32(self.bytesNeeded))

                // upload entropy to the libwrapper API server
                let bufferPtr = UnsafeMutableBufferPointer(start: steveBytes, count: self.bytesNeeded)
                let buffer = Array(bufferPtr)
                self.postEntropyToLibwrapper(entropy: buffer)
                free(steveBytes)
            }
            
            return
        }
        
        settingsTable.dataSource = self
        settingsTable.delegate = self
        settingsTable.tableFooterView = UIView()
        
        addCameraLayer()
        
        // Don't update stats if there's no camera available
        if (AVCaptureDevice.devices(for: AVMediaType.video).count > 0) {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    private func addCameraLayer() {
        let cameraFrame = CGRect(x: 10, y: cameraCenterY,  width: cameraRadius * 2, height: cameraRadius * 2)
        
        if (AVCaptureDevice.devices(for: AVMediaType.video).count > 0) {
            // Show camera layer
            frames = CameraFrames(dlg:self)
            frames!.previewLayer!.frame = cameraFrame
            frames!.previewLayer!.cornerRadius = cameraRadius
            frames!.previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.view!.layer.addSublayer(frames!.previewLayer!)
        } else {
            // Emulate camera layer if camera is not accessible (simulator?)
            let coloredLayer = CALayer()
            coloredLayer.frame = cameraFrame
            coloredLayer.backgroundColor = Constants.mainColor.cgColor
            coloredLayer.opacity = 0.3
            coloredLayer.cornerRadius = cameraRadius
            self.view!.layer.addSublayer(coloredLayer)
        }
        overlayView.superview?.bringSubviewToFront(overlayView)
        
        // Circular upload progress bar
        let circleLayer = CAShapeLayer()
        circleLayer.path = progressPath(0)
        circleLayer.strokeColor = Constants.mainColor.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 4
        self.view!.layer.addSublayer(circleLayer)
        
        // Rotating image on center
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = Constants.spinnerAnimationDuration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        overlay.layer.add(animation, forKey: "spinAnimation")
    }
    
    func localized(_ val: Int) -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: val), number: NumberFormatter.Style.decimal)
    }
    
    @objc func timerForSteveAction() {
        ticker += 1
        
        // Text animation
        let animation: CATransition = CATransition()
        animation.duration = 0.1
        animation.type = CATransitionType.fade
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        settingsTable.cellForRow(at: IndexPath(row: 0, section: 0))?.layer.add(animation, forKey: "changeTextTransition")
        
        // Row 0: Time elapsed
        updateValue(row: 0, val: String(format: "%02i:%02i", ticker / 5 / 60, ticker / 5 % 60))
    }
    
    @objc func timerAction() {
        ticker += 1
        
        // Text animation
        let animation: CATransition = CATransition()
        animation.duration = 0.1
        animation.type = CATransitionType.fade
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        for i in 0..<stats.count {
            settingsTable.cellForRow(at: IndexPath(row: i, section: 0))?.layer.add(animation, forKey: "changeTextTransition")
        }
        
        let ext = self.frames?.extractor
        let col = self.frames?.collector
        
        // Row 0: Time elapsed
        updateValue(row: 0, val: String(format: "%02i:%02i", ticker / 5 / 60, ticker / 5 % 60))
        
        // Row 1: Bytes in buffer
        updateValue(row: 1, val: localized(ext!.pos))
        
        // Row 2: Bytes generated
        updateValue(row: 2, val: localized(col!.totalGenerated))
        
        // Row 3: χ²
        if col!.lastChi > 0 {
            updateValue(row: 3, val: String(format:"%.2f",  col!.lastChi))
        }
        
        // Highlight if χ² is over limit
        let x2valueLabel = self.settingsTable.cellForRow(at: IndexPath(row: 3, section: 0))?.detailTextLabel
        if defaults.bool(forKey: "x2_limit_enabled") && (col!.lastChi > defaults.double(forKey: "x2_limit")) {
            x2valueLabel?.textColor = Constants.warningColor
        } else {
            x2valueLabel?.textColor = Constants.mainColor
        }
        
        // Row 4: Number of frames we reject due to too high mean (i.e camera movement)
        updateValue(row: 4, val: localized(col!.rejectedFrames))
        
        // Row 5: Corrupt pixels
        updateValue(row: 5, val: String(format:"%.2f%%",  col!.corruptPixels))
    }
    
    func bytesConvertToHexstring(byte : [UInt8]) -> String {
        var string = ""
        
        for val in byte {
            //getBytes(&byte, range: NSMakeRange(i, 1))
            string = string + String(format: "%02x", val)
        }
        
        return string
    }
    
    // set the entropy in the libwrapper api server
    func postEntropyToLibwrapper(entropy: [UInt8]) {
        if (GenerationController.isCancelled) {
            GenerationController.isCancelled = false
            return
        }

        let timestamp = Int64(NSDate().timeIntervalSince1970)

        let params = ["size": entropy.count * 2,
                      "raw": "true",
                      "timestamp": timestamp * 1000,
                      "entropy": entropy.map { String(format: "%02x", $0) }.joined()
            ] as Dictionary<String, AnyObject>
        
        var request = URLRequest(url: URL(string: "https://api.randonauts.com/setentropy")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            if error != nil {
                print(error!)
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    //print(json)
                    print("uploaded entropy to libwrapper API")
                    
                    DispatchQueue.main.async {
                        // send gid back to flutter to send to bot via javascript layer
                        self.channel?.invokeMethod("gid", arguments: json["Gid"])
                        
                        // go back to flutter
                        self.coordinatorDelegate?.navigateToFlutter()
                    }
                } catch {
                    if let returnData = String(data: data!, encoding: .utf8) {
                        print(returnData)
                    } else {
                        print("invalid response")
                    }
                }
            }
        })
        
        task.resume()
    }
    
    func uploadEntropy(entropy: [UInt8], blockNumber: Int) {
        // soliax - was crashing here trying to call main UI thread from background thread
        //print(self.bytesConvertToHexstring(byte: entropy))
        //entropy.reduce("", combine: { $0 + String(format: "%02x", $1)})
        //print(entropy.map { String(format: "%02x", $0) }.joined())
        //return
        
        self.blockNumber = blockNumber
        let timestamp = Int64(NSDate().timeIntervalSince1970)
        
        // Update circular progress bar, if we are not in unlimited generation mode
        if !defaults.bool(forKey: "block_amount_unlimited") {
            DispatchQueue.main.async {
                let percentage = CGFloat(blockNumber) / CGFloat(self.defaults.integer(forKey: "block_amount"))
                let progressLayer = self.view!.layer.sublayers?[(self.view!.layer.sublayers?.count)!-1] as? CAShapeLayer
                progressLayer?.path = self.progressPath(percentage)
            }
        }
        
        // upload generated entropy to libwrapper API (soliax)
        if defaults.string(forKey: "delivery") == "libwrapper" {
            postEntropyToLibwrapper(entropy: entropy)
            return
        }
        
        // Upload block to Zax relay, if in Network mode
        if defaults.string(forKey: "delivery") == "network" {
            do {
                let isLastBlock = !defaults.bool(forKey: "block_amount_unlimited") && (blockNumber == defaults.integer(forKey: "block_amount"))
                if isLastBlock {
                    updateStatus("FINISHING UPLOAD")
                }
                /*soliax
                 try GlowLite.shared.sendFile(keyTo: defaults.string(forKey: "recipient")!,
                 file: entropy,
                 name: "TE_block\(blockNumber)_\(timestamp).bin") {
                 (res) -> () in
                 if isLastBlock {
                 self.closeView()
                 }
                 }
                 } catch {
                 print("Network error")
                 */
            }
            
            return
        }
        
        // Otherwise, stop generation and prepare for airdrop
        updateStatus("WRITING BLOCK \(blockNumber)")
        frames?.session?.stopRunning()
        
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        var files = [URL]()
        
        if defaults.bool(forKey: "upload_csv") {
            let f = NSMutableString(capacity: entropy.count * 50)
            // Use "Bins" column with Excel Histogram function
            f.append("Values,Bins\n")
            for i in 0 ..< entropy.count {
                f.append(String(entropy[i]))
                if i<256 { f.append(",\(i)") }
                f.append("\n")
            }
            let path1 = dir.appendingPathComponent("TE_block\(blockNumber)_\(timestamp).csv")
            do {
                try f.write(to: path1, atomically: false, encoding: String.Encoding.ascii.rawValue)
                files.append(path1)
            }
            catch {/* error handling here */}
        }
        
        let path2 = dir.appendingPathComponent("TE_block\(blockNumber)_\(timestamp).bin")
        FileManager.default.createFile(atPath: path2.path, contents: Data(bytes: entropy), attributes: nil)
        files.append(path2)
        
        // AirDrop the files
        let controller  = UIActivityViewController(activityItems: files, applicationActivities: nil)
        controller.popoverPresentationController?.sourceView = self.view
        controller.completionWithItemsHandler = doneSharingHandler
        controller.excludedActivityTypes = [.postToTwitter, .saveToCameraRoll ,.postToFacebook, .postToWeibo, .message, .mail, .print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo]
        self.present(controller, animated: true)
    }
    
    func doneSharingHandler(activityType: UIActivity.ActivityType?, shared: Bool, items: [Any]?, error: Error?) {
        if !defaults.bool(forKey: "block_amount_unlimited") && (self.blockNumber == defaults.integer(forKey: "block_amount")) {
            self.closeView()
        } else {
            self.updateStatus("GENERATING ENTROPY")
            self.frames?.session?.startRunning()
        }
    }
    
    func progressPath(_ percentage: CGFloat) -> CGPath {
        return UIBezierPath(arcCenter: CGPoint(x: 10 + self.cameraRadius, y: self.cameraCenterY + self.cameraRadius),
                            radius: self.cameraRadius - 2, startAngle: -CGFloat.pi / 2.0,
                            endAngle: -CGFloat.pi / 2.0 + (CGFloat.pi * 2.0 * percentage), clockwise: true).cgPath
    }
    
    func updateStatus(_ status: String) {
        DispatchQueue.main.async {
            self.overlayStatus.text = status
        }
    }
    
    func updateValue(row: Int, val: String) {
        if val == "0" { return }
        DispatchQueue.main.async {
            self.settingsTable.cellForRow(at: IndexPath(row: row, section: 0))?.detailTextLabel?.text = val
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTable.dequeueReusableCell(withIdentifier: "keyValue")!
        cell.detailTextLabel?.text = " "
        cell.textLabel?.text = stats[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return stats.count }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 40 }
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    @IBAction func closeClicked(_ sender: Any) {
        GenerationController.isCancelled = true
        frames?.session?.stopRunning()
        self.closeView()
    }
    
    func closeView() {
        self.performSegue(withIdentifier: "backToSettings", sender: self)
        self.dismiss(animated: false, completion: nil)
        
        // by soliax
        // go back to flutter
        self.channel?.invokeMethod("gid", arguments: "Cancel")
        self.coordinatorDelegate?.navigateToFlutter()
    }
}
