//
//  UINavigation+Extension.swift
//  JYLeakSniffer
//
//  Created by 季勤强 on 2020/3/4.
//  Copyright © 2020 dyljqq. All rights reserved.
//

import UIKit

extension UINavigationController {
  
  override class func prepareForSniffer() {
    DispatchQueue.once(token: "com.dyljqq.navigation") {
      swizzleMethod(UINavigationController.self, origin: #selector(UINavigationController.pushViewController(_:animated:)), swizzled: #selector(UINavigationController.swizzeld_pushViewControlle(_:animated:)))
    }
  }
  
  @objc func swizzeld_pushViewControlle(_ viewController: UIViewController, animated: Bool) {
    self.swizzeld_pushViewControlle(viewController, animated: animated)
    
    viewController.markAlive()
  }
  
}
