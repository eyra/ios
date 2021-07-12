//
//  Transition.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 31/05/2021.
//

import WebKit

class Transition {
    let from: ViewController?
    let to: ViewController?
    let isPop: Bool
    let webViewManager: WebViewManager
    var webView: WKWebView?
    
    var isNativeReady: Bool = false
    var isWebReady: Bool = false
    
    var action: ()->Void
    
    init(from: ViewController?, to:ViewController?, isPop: Bool, webViewManager: WebViewManager, action: @escaping ()->Void) {
        self.from = from
        self.to = to
        self.isPop = isPop
        self.webViewManager = webViewManager
        self.action = action
    }
    
    func start() {
        webView = webViewManager.startTransition(to: to)
        from?.showScreenshot()
        if isPop {
            to?.showScreenshot()
            action() // start immediately
        } else {
            guard let webView = webView else { assertionFailure(); return  }
            to?.showWebView(webView: webView, animated: false)
            // and now.. wait to activate push untill webReady
        }
    }
    
    func end() {
        webViewManager.endTransition(to: to)
        
        if isPop {
            guard let webView = webView else { assertionFailure(); return }
            to?.showWebView(webView: webView, animated: true)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.webViewManager.takeScreenshot()
            }
        }
    }
    
    @discardableResult func webReady() -> Bool {
        if !isWebReady && !isPop {
            action() // start push on first webReady
        }
        isWebReady = true
        return endIfNeeded()
    }

    @discardableResult func nativeReady() -> Bool {
        isNativeReady = true
        return endIfNeeded()
    }

    @discardableResult func endIfNeeded() -> Bool {
        guard isNativeReady, isWebReady else { return false }
        end()
        return true
    }
}
