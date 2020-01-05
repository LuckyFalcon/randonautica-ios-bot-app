//
//  FlutterCoordinator.swift
//  Runner
//
//  Created by soliax on 2020/01/04.
//  Copyright © 2020 Randonauts
//
//  Based on cosinus84's blog at https://medium.com/@cosinus84/flutter-view-controller-used-in-ios-app-using-coordinator-pattern-8896339d64ba

import Foundation
import UIKit

final class FlutterCoordinator: BaseCoordinator{
    weak var navigationController: UINavigationController?
    weak var delegate: FlutterToAppCoordinatorDelegate?
    
    override func start() {
        super.start()
        navigationController?.popToRootViewController(animated: true)
    }
    
    init(navigationController: UINavigationController?) {
        super.init()
        self.navigationController = navigationController
    }
}
