//
//  UIViewController+Extension.swift
//  JYLeakSniffer
//
//  Created by 季勤强 on 2020/2/27.
//  Copyright © 2020 dyljqq. All rights reserved.
//

import UIKit

extension UIViewController {
  
  override class func prepareForSniffer() {
    DispatchQueue.once(token: "com.dyl.vc") {
      swizzleMethod(UIViewController.self, origin: #selector(UIViewController.present(_:animated:completion:)), swizzled: #selector(UIViewController.swizzledPresent(_:animated:completion:)))
      swizzleMethod(UIViewController.self, origin: #selector(UIViewController.viewDidAppear(_:)), swizzled: #selector(UIViewController.swizzledViewDidApear(_:)))
    }
  }
  
  @objc func swizzledPresent(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
    self.swizzledPresent(viewControllerToPresent, animated: flag, completion: completion)
    
    let _ = viewControllerToPresent.markAlive()
  }
  
  @objc func swizzledViewDidApear(_ animated: Bool) {
    self.swizzledViewDidApear(animated)
    
    watchAllRetainedProperties(0)
  }

  override var isAlive: Bool {
    get {
      return self._isAlive()
    }
  }
  
  private func _isAlive() -> Bool {

    var alive = true
    var isVisibleOnScreen = false
    
    var v = self.view
    while v?.superview != nil {
      v = v?.superview
    }
    
    isVisibleOnScreen = v?.isKind(of: UIWindow.classForCoder()) ?? false
    
    var beingHeld = false
    if self.navigationController != nil || self.presentingViewController != nil {
      beingHeld = true
    }
    
    // not visible & not in view stack
    alive = isVisibleOnScreen || beingHeld
    
    return alive
  }
  
}
