//
//  ScriptWrapper.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 18/05/2021.
//

import WebKit

class ScriptWrapper {

    enum Function {
        case popToScreen(String)
        
        func toScript() -> String {
            switch self {
            case .popToScreen(let screenId):
                return "window.setScreenFromNative('\(screenId)')"
            }
        }
    }
    
    let webView: WKWebView
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
    @objc func popToScreen(screenId: String) {
        execute(function: .popToScreen(screenId))
    }
        
    func execute(function: Function) {
        webView.evaluateJavaScript(function.toScript()) { (_, error) in
            if let error = error {
                print("Failed to execute script function '\(function.toScript())': \(error.localizedDescription)")
            }
        }
    }
}
