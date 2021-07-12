//
//  NavigationHandler.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 17/05/2021.
//

import Foundation

class NavigationHandler: ScriptMessageDelegate {
        
    var transition: Transition?
    
    var rootModalViewController: ModalViewController!
    var rootViewController: ViewController!
    
    var scriptWrapper: ScriptWrapper!
    
    var modalViewControllers: [ModalViewController] = []
        
    var currentModalViewController: ModalViewController {
        modalViewControllers.last ?? rootModalViewController
    }
    
    var topViewController: ViewController {
        currentModalViewController.topViewController as? ViewController ?? rootViewController
    }
        
    var previousViewController: ViewController? {
        let count = currentModalViewController.viewControllers.count
        guard count >= 2 else { return nil }
        return currentModalViewController.viewControllers[count-2] as? ViewController
    }
    
    var id: Int = 0
    
    func nextId() -> String {
        id = id + 1
        return "\(id-1)"
    }
        
    let transitionBuilder: TransitionBuilder
    let webViewManager: WebViewManager
    
    init(transitionBuilder: TransitionBuilder, webViewManager: WebViewManager) {
        self.transitionBuilder = transitionBuilder
        self.webViewManager = webViewManager
    }
    
    func push(screenId: String) {
        if popDetected(screenId) {
            pop()
        } else {
            print("push \(screenId)")
            let nextViewController = factory.createViewController(id: nextId(), screenId: screenId)
            transition = transitionBuilder.build(from: topViewController, to: nextViewController, isPop: false) { [weak self] in
                self?.pushAction(nextViewController)
            }
        }
    }
    
    private func pushAction(_ nextViewController: ViewController) {
        self.currentModalViewController.pushViewController(nextViewController, animated: true) { [weak self] in
            self?.transition?.nativeReady()
        }
    }

    func popDetected(_ screenId: String) -> Bool {
        print("WARNING pop detected for \(screenId)")
        return previousViewController?.screenId == screenId
    }
        
    func pop() {
        guard let previousViewController = previousViewController else { assertionFailure(); return }
        topViewController.willBePoppedFromScript = true // circuit breaker
        
        transition = transitionBuilder.build(from: topViewController, to: previousViewController, isPop: true) { [weak self] in
            self?.popAction()
        }
    }
    
    private func popAction() {
        currentModalViewController.popViewController(animated: true) { [weak self] in
            self?.transition?.nativeReady()
        }
    }
    
    func present() {
        let rootViewController = factory.createViewController(id: nextId(), screenId: "")
        let modalViewController = factory.createModalViewController(rootViewController: rootViewController)
        transition = transitionBuilder.build(from: topViewController, to: rootViewController, isPop: false) { [weak self] in
            self?.presentAction(modalViewController)
        }
    }
    
    private func presentAction(_ modalViewController: ModalViewController) {
        currentModalViewController.present(modalViewController, animated: true, completion: nil)
        modalViewControllers.append(modalViewController)
    }
    
    func dismiss() {
        if let modalViewController = modalViewControllers.popLast() {
            guard let previousViewController = modalViewController.topViewController as? ViewController else { assertionFailure(); return }
            transition = transitionBuilder.build(from: previousViewController, to: topViewController, isPop: false) { [weak self] in
                self?.dismissAction(modalViewController)
            }
        }
    }
    
    private func dismissAction(_ modalViewController: ModalViewController) {
        modalViewController.willBeDismissedFromScript = true
        modalViewController.dismiss(animated: true, completion: nil)
    }
    
    func update(screenId: String, title: String) {
        if let to = transition?.to  {
            guard to.screenId == screenId else {
                print("WARNING update \(String(describing: to.screenId)) != \(screenId)")
                return
            }
            to.screenId = screenId
            to.title = title
        } else {
            guard topViewController.screenId == screenId else {
                print("WARNING update \(screenId) while current screen is \(String(describing: topViewController.screenId))")
                return
            }
            topViewController.screenId = screenId
            topViewController.title = title
        }
    }
    
    func state(state: Any) {
        topViewController.state = state
    }
    
    func webReady(screenId: String) {
        print("web ready \(screenId)")
        guard let transition = transition else { webReadyWithoutTransition(screenId: screenId); return }
        guard screenId == transition.to?.screenId else {
            print("WARNING webReady \(screenId) while transition to \(transition.to?.screenId)");
            return
        }
        if transition.webReady() {
            self.transition = nil
        }
    }
    
    func webReadyWithoutTransition(screenId: String) {
        print("WARNING webReady \(screenId) without transition");
        let webView = webViewManager.startTransition(to: topViewController)
        webViewManager.endTransition(to: topViewController)
        topViewController.showWebView(webView: webView, animated: true)
        webViewManager.takeScreenshot()
    }

    func willBePopped(viewController: ViewController, fromScript: Bool) {
        if !fromScript {
            popToTop(from: viewController)
        }
    }

    func isPopped(viewController: ViewController) {
        webViewManager.releaseScreenshots(for: viewController)
        guard let transition = transition else { nativeReadyWithoutTransition(screenId: viewController.screenId); return }
        if transition.nativeReady() {
            self.transition = nil
        }
    }
    
    func nativeReadyWithoutTransition(screenId: String) {
        print("WARNING nativeReady \(screenId) isPopped without transition");
    }
        
    func isDismissed(modalViewController: ModalViewController, fromScript: Bool) {
        if !fromScript {
            modalViewControllers.removeLast()
            popToTop(from: modalViewController.topViewController as? ViewController)
        }
    }
        
    private func popToTop(from: ViewController?) {
        guard let from = from else { assertionFailure(); return }
        transition = transitionBuilder.build(from: from, to: topViewController, isPop: true) { [weak self] in
            self?.popToTopAction()
        }
    }
    
    private func popToTopAction() {
        guard let screenId = topViewController.screenId else { return }
        scriptWrapper.popToScreen(screenId: screenId, state: topViewController.state)
    }
}
