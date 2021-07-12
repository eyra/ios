//
//  ViewController.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 14/05/2021.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {

    let screenshotProvider: ScreenshotProvider
    let navigationHandler: NavigationHandler
    var screenId: String!
    var state: Any?
    var id: String
    
    var onMenuButtonTapped: (()->Void)?

    let webViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    let screenshot: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let menuButton: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    init(id: String, screenId: String, screenshotProvider: ScreenshotProvider, navigationHandler: NavigationHandler) {
        self.id = id
        self.screenId = screenId
        self.screenshotProvider = screenshotProvider
        self.navigationHandler = navigationHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var willBePoppedFromScript: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        webViewContainer.frame = view.bounds
        view.addSubview(webViewContainer)

        screenshot.frame = view.bounds
        view.addSubview(screenshot)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "menu", style: .plain, target: self, action: #selector(menuButtonTapped))
    }
    
    @objc func menuButtonTapped() {
        print("menuButtonTapped")
        onMenuButtonTapped?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        showScreenshot()
        if isMovingFromParent { // pop from native UI
            navigationHandler.willBePopped(viewController: self, fromScript: willBePoppedFromScript)
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isMovingFromParent { // pop from native UI
            navigationHandler.isPopped(viewController: self)
        }
        super.viewDidDisappear(animated)
    }

        
    func showScreenshot() {
        screenshot.image = screenshotProvider.screenshot(for: self)
        screenshot.alpha = 1
    }
    
    func hideScreenshot(animated: Bool) {
        let duration = animated ? 0.3 : 0
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.screenshot.alpha = 0
        } completion: { _ in
            print("screenshot hidden")
        }
    }
    
    func showWebView(webView: WKWebView, animated: Bool) {
        if webView.superview != self.view {
            webView.frame = webViewContainer.bounds
            webViewContainer.addSubview(webView)
        }
        hideScreenshot(animated: animated)
    }
}

