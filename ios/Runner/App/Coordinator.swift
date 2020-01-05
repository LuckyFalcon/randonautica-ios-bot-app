//
//  Coordinator.swift
//  Runner
//
//  Created by soliax on 2020/01/04.
//  Copyright © 2020 Randonauts
//
//  Based on cosinus84's blog at https://medium.com/@cosinus84/flutter-view-controller-used-in-ios-app-using-coordinator-pattern-8896339d64ba

import Foundation
import UIKit

protocol Coordinator: class {
    var childCoordinators: [Coordinator] { get }
    func add(_ coordinator: Coordinator)
    func remove(_ coordinator: Coordinator)
    func removeAll()
    func start()
}

class BaseCoordinator:  Coordinator{
    private var _childCoordinators: [Coordinator] = []
    var childCoordinators: [Coordinator] {
        return self._childCoordinators
    }
    
    init() {
        guard type(of: self) != BaseCoordinator.self else {
            fatalError("BaseCoordinator cannot be instantiated")
        }
    }
    
    func add(_ coordinator: Coordinator) {
        self._childCoordinators.append(coordinator)
    }
    
    func remove(_ coordinator: Coordinator) {
        self._childCoordinators = self.childCoordinators.filter { $0 !== coordinator }
    }
    
    func removeAll() {
        self._childCoordinators.removeAll()
    }
    
    func start() {}
}
