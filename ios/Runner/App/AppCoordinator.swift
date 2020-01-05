//
//  AppCoordinator.swift
//  Runner
//
//  Created by soliax on 2020/01/04.
//  Copyright © 2020 Randonauts
//
//  Based on cosinus84's blog at https://medium.com/@cosinus84/flutter-view-controller-used-in-ios-app-using-coordinator-pattern-8896339d64ba

import Foundation
import UIKit

class AppCoordinator: BaseCoordinator{
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        super.init()
        self.navigationController = navigationController
    }
    
    override func start() {
        super.start()
    }
}

protocol TrueEntropyToAppCoordinatorDelegate: class {
    func navigateToFlutterViewController()
}

protocol FlutterToAppCoordinatorDelegate: class {
    func navigateToTrueEntropyViewController(bytesNeeded: Int, channel: FlutterMethodChannel )
}

extension AppCoordinator: TrueEntropyToAppCoordinatorDelegate{
    func navigateToFlutterViewController() {
        let coordinator = FlutterCoordinator(navigationController:     self.navigationController)
        coordinator.delegate = self
        self.add(coordinator)
        coordinator.start()
    }
}

extension AppCoordinator: FlutterToAppCoordinatorDelegate{
    func navigateToTrueEntropyViewController(bytesNeeded: Int, channel: FlutterMethodChannel) {
        let coordinator = TrueEntropyCoordinator(navigationController:    self.navigationController)
        coordinator.delegate = self
        self.add(coordinator)
        coordinator.start()
        coordinator.openView(bytesNeeded: bytesNeeded, channel: channel)
    }
}
