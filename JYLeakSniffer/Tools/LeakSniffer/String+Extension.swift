//
//  NSString+Extension.swift
//  JYLeakSniffer
//
//  Created by 季勤强 on 2020/3/3.
//  Copyright © 2020 dyljqq. All rights reserved.
//

import Foundation

extension String {
  
  var isSystemObject: Bool {
    let checks = ["UI", "NS", "_"]
    for prefix in checks {
      if self.hasPrefix(prefix) {
        return true
      }
    }
    return false
  }
  
}
