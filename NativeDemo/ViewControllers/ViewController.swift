//
//  ViewController.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 14/05/2021.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {

    let webView: WKWebView
    let viewControllerManager: ViewControllerManager
    var screenId: String?
    
    let screenshot: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .red
        return view
    }()

    init(webView: WKWebView, viewControllerManager: ViewControllerManager) {
        self.webView = webView
        self.viewControllerManager = viewControllerManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var willBePoppedFromScript: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isMovingToParent { // push from native UI
            showWebView()
        }
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showWebView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        showScreenshot()
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        if isMovingFromParent { // pop from native UI
            viewControllerManager.isPopped(viewController: self, fromScript: willBePoppedFromScript)
        }
        showScreenshot()
        super.viewWillDisappear(animated)
    }

    func showScreenshot() {
        if screenshot.image == nil {
            screenshot.image =  webView.asImage()
        }
        screenshot.frame = view.bounds
        view.addSubview(screenshot)
    }
    
    func showWebView() {
        if webView.superview != self.view {
            webView.frame = self.view.bounds
            view.addSubview(webView)
        }
        screenshot.removeFromSuperview()
    }    
}

