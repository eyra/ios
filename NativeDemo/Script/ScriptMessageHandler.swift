//
//  ScriptMessageHandler.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 17/05/2021.
//

import UIKit
import WebKit

class ScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    var delegate: ScriptMessageDelegate!
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if let type = ScriptMessage(message: message) {
            switch type {
            case .push(let screenId):
                delegate.push(screenId: screenId)
            case .present:
                delegate.present()
            case .dismiss:
                delegate.dismiss()
            case .update(let screenId, let title):
                delegate.update(screenId: screenId, title: title)
            case .state(let state):
                delegate.state(state: state)
            case .webReady(let screenId):
                delegate.webReady(screenId: screenId)
            }
        }
    }
}

enum ScriptMessage {
    case push(String)
    case present
    case dismiss
    case update(String, String)
    case state(Any)
    case webReady(String)

    init?(message: WKScriptMessage) {
        guard let userInfo = message.body as? NSDictionary else { return nil }
        let type = userInfo["type"] as? String
        
        switch (type) {
        case ("openScreen"):
            guard let screenId = userInfo["id"] as? String else { return nil }
            self = .push(screenId)
        case ("pushModal"):
            self = .present
        case ("popModal"):
            self = .dismiss
        case ("updateScreen"):
            guard
                let screenId = userInfo["id"] as? String,
                let title = userInfo["title"] as? String
            else { return nil }
            self = .update(screenId, title)
        case ("webReady"):
            guard
                let screenId = userInfo["id"] as? String
            else { return nil }
            self = .webReady(screenId)
        case ("setScreenState"):
            guard let state = userInfo["state"] else { return nil }
            self = .state(state)
        default: return nil
        }
    }
}

protocol ScriptMessageDelegate {
    func push(screenId: String)
    func present()
    func dismiss()
    func update(screenId: String, title: String)
    func state(state: Any)
    func webReady(screenId: String)
}
