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
    
    lazy var scriptWrapper: ScriptWrapper = {
        ScriptWrapper(webView: webView)
    }()
    
    lazy var mainViewController: ModalViewController = {
        createModalViewController(rootViewController: createViewController())
    }()
    
    lazy var viewControllerManager: ViewControllerManager = {
        ViewControllerManager()
    }()
    
    lazy var handler: ScriptMessageHandler = {
        ScriptMessageHandler()
    }()
    
    lazy var webView: WKWebView = {
        let controller = WKUserContentController()
        
        controller.add(handler, name: "Push")
        controller.add(handler, name: "Pop")
        controller.add(handler, name: "UpdateScreen")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller

        let webView =  WKWebView(frame: CGRect.zero, configuration: configuration)
        
        var request = URLRequest(url: URL(string: "http://localhost:4000")!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        webView.load(request)
        return webView
    }()
    
    func createViewController(screenId: String? = nil) -> ViewController {
        let viewController = ViewController(webView: webView, viewControllerManager: viewControllerManager)
        viewController.screenId = screenId
        return viewController
    }
    
    func createModalViewController(rootViewController: ViewController) -> ModalViewController {
        ModalViewController(rootViewController: rootViewController, viewControllerManager: viewControllerManager)
    }
    
    func setup() {
        viewControllerManager.rootModalViewController = mainViewController
        viewControllerManager.scriptWrapper = scriptWrapper
        
        handler.delegate = viewControllerManager
    }
}
