//
//  TransitionBuilder.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 31/05/2021.
//

import Foundation

struct TransitionBuilder {
    let webViewManager: WebViewManager
    
    func build(from: ViewController, to: ViewController, isPop: Bool, action: @escaping ()->Void) -> Transition {
        let transition = Transition(from: from, to: to, isPop: isPop, webViewManager: webViewManager, action: action)
        transition.start()
        return transition
    }
}
