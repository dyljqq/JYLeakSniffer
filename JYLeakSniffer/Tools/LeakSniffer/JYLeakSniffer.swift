//
//  JYLeakSniffer.swift
//  JYLeakSniffer
//
//  Created by 季勤强 on 2020/2/26.
//  Copyright © 2020 dyljqq. All rights reserved.
//

import UIKit

class JYLeakSniffer {
  
  static let shared = JYLeakSniffer()
  
  private var timer: Timer?
  
  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(detectPong), name: snifferPongNotificationName, object: nil)
  }
  
  func startSniffer() {
    
    UINavigationController.prepareForSniffer()
    UIViewController.prepareForSniffer()
    UIView.prepareForSniffer()
    
    startTimer()
    
  }
  
  @objc func detectPong(notification: Notification) {
    guard let obj = notification.object as? NSObject else { return }
    let leakName = NSStringFromClass(obj.classForCoder)
    if obj.isKind(of: UIViewController.classForCoder()) {
      print("Detect Possible View Controller Leak: \(leakName)")
    } else {
      print("Detect Possible Leak: \(leakName)")
    }
  }
  
  private func startTimer() {
    if !Thread.isMainThread {
      self.startTimer()
      return
    }
    
    if self.timer != nil {
      return
    }
    
    self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(sendPing), userInfo: nil, repeats: true)
  }
  
  @objc func sendPing() {
    NotificationCenter.default.post(name: snifferPingNotificationName, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
}
