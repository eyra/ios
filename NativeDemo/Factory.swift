//
//  Factory.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 17/05/2021.
//

import Foundation
import WebKit

let factory = Factory()

class Factory {
    
    lazy var transitionBuilder: TransitionBuilder = {
       TransitionBuilder(webViewManager: webViewManager)
    }()
    
    lazy var scriptWrapper: ScriptWrapper = {
        ScriptWrapper(webView: webView)
    }()
    
    lazy var rootViewController: ViewController = {
        createViewController(id: "-1", screenId: "http://localhost:4000/?")
    }()
    
    lazy var mainViewController: ModalViewController = {
        createModalViewController(rootViewController: rootViewController)
    }()
    
    lazy var navigationHandler: NavigationHandler = {
        NavigationHandler(transitionBuilder: transitionBuilder, webViewManager: webViewManager)
    }()
    
    lazy var handler: ScriptMessageHandler = ScriptMessageHandler()
    lazy var webViewManager: WebViewManager = WebViewManager(webView: webView)
    
    lazy var webView: WKWebView = {
        let controller = WKUserContentController()
        
        controller.add(handler, name: "Native")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        configuration.applicationNameForUserAgent = "NativeWrapper"

        let webView =  WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.scrollView.showsVerticalScrollIndicator = false
        
        var request = URLRequest(url: URL(string: "http://localhost:4000")!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        webView.load(request)
        return webView
    }()
    
    func createViewController(id: String, screenId: String) -> ViewController {
        ViewController(id: id, screenId: screenId, screenshotProvider: webViewManager, navigationHandler: navigationHandler)
    }
    
    func createModalViewController(rootViewController: ViewController) -> ModalViewController {
        ModalViewController(rootViewController: rootViewController, navigationHandler: navigationHandler)
    }
    
    
    func setup() {
        navigationHandler.rootModalViewController = mainViewController
        navigationHandler.rootViewController = rootViewController
        navigationHandler.scriptWrapper = scriptWrapper
        
        handler.delegate = navigationHandler
    }
}
