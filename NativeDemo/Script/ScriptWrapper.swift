//
//  ScriptWrapper.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 18/05/2021.
//

import WebKit

class ScriptWrapper {

    enum Function {
        case popToScreen(String, String)
        
        func toScript() -> String {
            switch self {
            case .popToScreen(let screenId, let state):
                return "window.setScreenFromNative('\(screenId)', \(state))"
            }
        }
    }
    
    let webView: WKWebView
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
    @objc func popToScreen(screenId: String, state: Any?) {
        let data = try! JSONSerialization.data(withJSONObject: state ?? [], options: .prettyPrinted)
        let dataString = String(decoding: data, as: UTF8.self)
        print("popToScreen: \(screenId)")
        execute(function: .popToScreen(screenId, dataString))
    }
        
    func execute(function: Function) {
        webView.evaluateJavaScript(function.toScript()) { (_, error) in
            if let error = error {
                print("Failed to execute script function '\(function.toScript())': \(error.localizedDescription)")
            }
        }
    }
}
