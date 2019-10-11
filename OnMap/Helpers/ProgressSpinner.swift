//
//  ProgressSpinner.swift
//  OnMap
//
//  Created by Varosyan, Anna on 28.08.19.
//  Copyright © 2019 Varosyan, Anna. All rights reserved.
//

import Foundation
import UIKit

class ProgressSpinner {
    //MARK: Properties
    
    var viewBlur: UIVisualEffectView? = nil
    var viewSpinner: UIActivityIndicatorView? = nil
    
    //MARK: Public Functions
    public func show(_ viewController: UIViewController) {
        //add blur view to blur the screen content
        createBlurView(viewController)
        //now add a spinner to be able to show the progress
       createSpinnerView(viewController)
    }
    
    public func hide() {
        removeView(spinner:true)
        removeView(spinner:false)
    }
    
    //MARK: Private Functions
    private func createBlurView(_ viewController: UIViewController) {
        viewBlur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        viewBlur!.frame = viewController.view.bounds
        viewController.view.addSubview(viewBlur!)
    }
    
    private func createSpinnerView(_ viewController: UIViewController) {
        //now add a spinner to be able to show the progress
        viewSpinner = UIActivityIndicatorView(style: .whiteLarge)
        viewSpinner?.center = viewController.view.center
        viewSpinner?.startAnimating()
        viewController.view.addSubview(viewSpinner!)
    }
    
    private func removeView(spinner: Bool) {
        var view = (spinner ? viewSpinner : viewBlur)
        if (view != nil) {
            view!.removeFromSuperview()
            view = nil
        }
    }
}
