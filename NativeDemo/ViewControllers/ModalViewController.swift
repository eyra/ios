//
//  ModalViewController.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 17/05/2021.
//

import UIKit

class ModalViewController: UINavigationController {
    
    let viewControllerManager: ViewControllerManager
    var willBeDismissedFromScript: Bool = false
    
    init(rootViewController: ViewController, viewControllerManager: ViewControllerManager) {
        self.viewControllerManager = viewControllerManager
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let topViewController = topViewController as? ViewController {
            topViewController.showWebView()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        viewControllerManager.isDismissed(modalViewController: self, fromScript: willBeDismissedFromScript)
    }
}
