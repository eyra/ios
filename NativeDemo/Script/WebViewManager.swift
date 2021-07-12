//
//  ScreenshotManager.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 29/05/2021.
//

import WebKit

class WebViewManager: NSObject, ScreenshotProvider {
    let webView: WKWebView
    var screenshots: [String: UIImage] = [:]
    var current: ViewController?
    var next: ViewController?
    
    
    init(webView: WKWebView) {
        self.webView = webView
        super.init()
        webView.scrollView.delegate = self
    }
    
    func screenshot(for viewController: ViewController) -> UIImage? {
        return screenshots[viewController.id]
    }
    
    func startTransition(to viewController: ViewController?) -> WKWebView {
        next = viewController
        self.current = nil
        return webView
    }
    
    func endTransition(to viewController: ViewController?)  {
        assert(next == viewController)
        self.current = viewController
    }
    
    func releaseScreenshots(for viewController: ViewController) {
        if let index = screenshots.index(forKey: viewController.id) {
            screenshots.remove(at: index)
        }
    }
    
    func takeScreenshot() {
        print("take screenshot \(current?.id) - \(current?.screenId)")
        guard let id = current?.id else { return }
        screenshots[id] = webView.asImage()
        current?.screenshot.image = screenshots[id]
    }
}

extension WebViewManager: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        takeScreenshot()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        takeScreenshot()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        takeScreenshot()
    }    
}

