//
//  UIView+Extension.swift
//  JYLeakSniffer
//
//  Created by 季勤强 on 2020/3/4.
//  Copyright © 2020 dyljqq. All rights reserved.
//

import UIKit

extension UIView {
  
  override class func prepareForSniffer() {
    DispatchQueue.once(token: "com.dyljqq.view") {
      swizzleMethod(UIView.self, origin: #selector(UIView.didMoveToSuperview), swizzled: #selector(UIView.swizzled_didMoveToSuperView))
    }
  }
  
  @objc func swizzled_didMoveToSuperView() {
    self.swizzled_didMoveToSuperView()
    
    var hasAliveParent = false
    var r: UIResponder? = self.next
    while r != nil {
      if r?.pProxy != nil {
        hasAliveParent = true
        break
      }
      r = r?.next
    }
    if hasAliveParent {
      self.markAlive()
    }
  }
  
  override var isAlive: Bool {
    get {
      return self._isAlive()
    }
  }
  
  private func _isAlive() -> Bool {
    
    var alive = true

    var v: UIView? = self
    while v?.superview != nil {
      v = v?.superview
    }
    let onUIStack = v?.isKind(of: UIWindow.classForCoder()) ?? false
    
    if self.pProxy?.weakResponder == nil {
      var r = self.next
      while r != nil {
        guard let a = r?.next, !a.isKind(of: UIViewController.classForCoder()) else { break }
        r = r?.next
      }
      self.pProxy?.weakResponder = r
    }
    
    if !onUIStack {
      alive = false
      // if controller is active, view should be considered alive too
      if self.pProxy?.weakResponder?.isKind(of: UIViewController.classForCoder()) ?? false {
        alive = true
      }
    }
    
    return alive
  }
  
}
