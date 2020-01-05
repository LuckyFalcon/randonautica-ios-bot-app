//
//  TrueEntropyCoordinator.swift
//  Runner
//
//  Created by soliax on 2020/01/04.
//  Copyright © 2020 Randonauts
//
//  Based on cosinus84's blog at https://medium.com/@cosinus84/flutter-view-controller-used-in-ios-app-using-coordinator-pattern-8896339d64ba

import Foundation
import UIKit
import Flutter

final class TrueEntropyCoordinator: BaseCoordinator{
    weak var navigationController: UINavigationController?
    weak var delegate: TrueEntropyToAppCoordinatorDelegate?
    
    override func start() {
        super.start()
    }
    
    func openView(bytesNeeded: Int, channel: FlutterMethodChannel)
    {
        let storyboard = UIStoryboard(name: "TrueEntropyMain", bundle: nil)
        if let container = storyboard.instantiateViewController(withIdentifier: "GenerationController") as? GenerationController {
            container.coordinatorDelegate = self
            container.bytesNeeded = bytesNeeded
            container.channel = channel
            navigationController?.pushViewController(container, animated: true)
        }
    }
    
    init(navigationController: UINavigationController?) {
        super.init()
        self.navigationController = navigationController
    }
}

protocol TrueEntropyCoordinatorDelegate {
    func navigateToFlutter()
}

extension TrueEntropyCoordinator: TrueEntropyCoordinatorDelegate{
    func navigateToFlutter() {
        self.delegate?.navigateToFlutterViewController()
    }
}
