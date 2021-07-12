//
//  ModalViewController.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 17/05/2021.
//

import UIKit

class ModalViewController: UINavigationController {
    
    let navigationHandler: NavigationHandler
    var willBeDismissedFromScript: Bool = false
    
    init(rootViewController: ViewController, navigationHandler: NavigationHandler) {
        self.navigationHandler = navigationHandler
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationHandler.isDismissed(modalViewController: self, fromScript: willBeDismissedFromScript)
    }
    
    public func pushViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: @escaping () -> Void)
    {
        pushViewController(viewController, animated: animated)

        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }

    func popViewController(
        animated: Bool,
        completion: @escaping () -> Void)
    {
        popViewController(animated: animated)

        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}
