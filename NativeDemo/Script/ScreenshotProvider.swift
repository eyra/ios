//
//  ScreenshotProvider.swift
//  NativeDemo
//
//  Created by Emiel van der Veen on 31/05/2021.
//

import UIKit

protocol ScreenshotProvider {
    func screenshot(for viewController: ViewController) -> UIImage?
}
