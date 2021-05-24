//
//  ViewControllerManager.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 17/05/2021.
//

import Foundation

class ViewControllerManager: ScriptMessageDelegate {
    var rootModalViewController: ModalViewController!
    var scriptWrapper: ScriptWrapper!
    
    var modalViewControllers: [ModalViewController] = []
        
    var currentModalViewController: ModalViewController {
        return modalViewControllers.last ?? rootModalViewController
    }
    
    func push(screenId: String) {
        if popDetected(screenId) {
            pop()
        } else {
            let viewController = factory.createViewController(screenId: screenId)
            currentModalViewController.pushViewController(viewController, animated: true)
        }
    }

    func popDetected(_ screenId: String) -> Bool {
        guard let previous = previousViewController(modalViewController: currentModalViewController),
              let previousScreenId = previous.screenId,
              previousScreenId == screenId else { return false }
        return true
    }
        
    func previousViewController(modalViewController: ModalViewController) -> ViewController? {
        let count = modalViewController.viewControllers.count
        guard count >= 2 else { return nil }
        return modalViewController.viewControllers[count-2] as? ViewController
    }
        
    func pop() {
        if let topViewController = currentModalViewController.topViewController as? ViewController {
            topViewController.willBePoppedFromScript = true
        }
        currentModalViewController.popViewController(animated: true)
    }
    
    func present() {
        if let topViewController = currentModalViewController.topViewController as? ViewController {
            topViewController.showScreenshot()
        }
        
        let rootViewController = factory.createViewController()
        let modalViewController = factory.createModalViewController(rootViewController: rootViewController)
        currentModalViewController.present(modalViewController, animated: true, completion: nil)
        modalViewControllers.append(modalViewController)
    }
    
    func dismiss() {
        if let modalViewController = modalViewControllers.popLast() {
            modalViewController.willBeDismissedFromScript = true
            modalViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func update(screenId: String, title: String) {
        if let currentViewController = currentModalViewController.topViewController as? ViewController {
            currentViewController.screenId = screenId
            currentViewController.navigationItem.title = title
        }
    }
    
    func isPopped(viewController: ViewController, fromScript: Bool) {
        if !fromScript {
            popToTop()
        }
    }
        
    func isDismissed(modalViewController: ModalViewController, fromScript: Bool) {
        if !fromScript {
            modalViewControllers.removeLast()
            popToTop()
        }
        
        if let topViewController =  currentModalViewController.topViewController as? ViewController {
            topViewController.showWebView()
        }
    }
    
    private func popToTop() {
        if let topScreenId = (currentModalViewController.topViewController as? ViewController)?.screenId {
            scriptWrapper.popToScreen(screenId: topScreenId)
        }
    }
}
