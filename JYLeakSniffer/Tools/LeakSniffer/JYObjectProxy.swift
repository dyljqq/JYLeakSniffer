//
//  JYObjectProxy.swift
//  JYPerformanceSniffer
//
//  Created by 季勤强 on 2020/2/26.
//  Copyright © 2020 dyljqq. All rights reserved.
//

import UIKit

class JYObjectProxy {
  
  var weakTarget: NSObject? = nil
  var checkLeakFailNum = 0
  var hasNofified = false
  var weakHost: NSObject? = nil
  var weakResponder: NSObject? = nil
  
  func prepareProxy(_ target: NSObject) {
    self.weakTarget = target
    
    NotificationCenter.default.removeObserver(self, name: snifferPingNotificationName, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(detectSniffer), name: snifferPingNotificationName, object: nil)
  }
  
  @objc func detectSniffer() {
    guard let weakTarget = self.weakTarget, !hasNofified else {
      return
    }
    let alive = weakTarget.isAlive
    if !alive {
      checkLeakFailNum += 1
    }
    if checkLeakFailNum > 5 {
      self.notify()
    }
  }
  
  func notify() {
    if hasNofified {
      return
    }
    hasNofified = true
    DispatchQueue.main.async {
      NotificationCenter.default.post(name: snifferPongNotificationName, object: self.weakTarget)
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: snifferPingNotificationName, object: nil)
  }
  
}
