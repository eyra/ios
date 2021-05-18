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
    
    func push() {
        let viewController = factory.createViewController()
        currentModalViewController.pushViewController(viewController, animated: true)
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
    
    func update(title: String) {
        if let currentViewController = currentModalViewController.topViewController {
            currentViewController.navigationItem.title = title
        }
    }
    
    func isPopped(viewController: ViewController, fromScript: Bool) {
        if !fromScript {
            scriptWrapper.screenIsPopped()
        }
    }
    
    func isDismissed(modalViewController: ModalViewController, fromScript: Bool) {
        if !fromScript {
            modalViewControllers.removeLast()
            scriptWrapper.modalIsPopped()
        }
        
        if let topViewController =  currentModalViewController.topViewController as? ViewController {
            topViewController.showWebView()
        }
    }
}
