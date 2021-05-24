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
            case .push:
                delegate.push()
            case .present:
                delegate.present()
            case .dismiss:
                delegate.dismiss()
            case .update(let title):
                delegate.update(title: title)
            }
        }
    }
}

enum ScriptMessage {
    case push
    case present
    case dismiss
    case update(String)
    
    init?(message: WKScriptMessage) {
        guard let userInfo = message.body as? NSDictionary else { return nil }
        let type = userInfo["type"] as? String
        let title = userInfo["title"] as? String
        
        switch (message.name, type) {
        case ("Push", "open"): self = .push
        case ("Push", "modal"): self = .present
        case ("Pop", "modal"): self = .dismiss
        case ("UpdateScreen", _): self = .update(title ?? "?")
        default: return nil
        }
    }
}

protocol ScriptMessageDelegate {
    func push()
    func present()
    func dismiss()
    func update(title: String)
}
