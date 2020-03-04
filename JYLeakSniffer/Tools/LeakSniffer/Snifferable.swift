//
//  Snifferable.swift
//  JYPerformanceSniffer
//
//  Created by 季勤强 on 2020/2/26.
//  Copyright © 2020 dyljqq. All rights reserved.
//

import UIKit

@objc protocol Snifferable {
  
  var isAlive: Bool { get }
  
  static func prepareForSniffer()
  
  func markAlive() -> Bool
  
}
