//
//  NSObject+Extension.swift
//  JYPerformanceSniffer
//
//  Created by 季勤强 on 2020/2/26.
//  Copyright © 2020 dyljqq. All rights reserved.
//

import UIKit

func swizzleMethod(_ cls: AnyClass, origin: Selector, swizzled: Selector) {
   guard let originMethod = class_getInstanceMethod(cls, origin),
    let swizzledMethod = class_getInstanceMethod(cls, swizzled) else {
        return
    }

    let didAddMethod = class_addMethod(cls, origin, method_getImplementation(originMethod), method_getTypeEncoding(originMethod))
    if didAddMethod {
      class_replaceMethod(cls, swizzled, method_getImplementation(originMethod), method_getTypeEncoding(originMethod))
    } else {
      method_exchangeImplementations(originMethod, swizzledMethod)
    }
}

public extension DispatchQueue {
    private static var _onceTracker = [String]()

    class func once(token: String, block: @escaping () -> Void) {
      objc_sync_enter(self)
      defer {
        objc_sync_exit(self)
      }

      if _onceTracker.contains(token) {
          return
      }
      _onceTracker.append(token)
      block()
    }
}


extension NSObject: Snifferable {

  fileprivate struct AssociatedKeys {
    static var proxy = "JYObjectProxy"
  }

  var pProxy: JYObjectProxy? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.proxy) as? JYObjectProxy
    }

    set {
      objc_setAssociatedObject(self, &AssociatedKeys.proxy, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  var isAlive: Bool {
    return true
  }

  class func prepareForSniffer() {

  }

  func markAlive() -> Bool {

    if self.pProxy != nil {
      return false;
    }

    // skip system class
    let className = NSStringFromClass(self.classForCoder)
    if (className.isSystemObject) {
      return false;
    }

    // view object needs a super view to be alive
    if let v = self as? UIView, v.superview == nil {
      return false
    }

    // controller object needs a parent to be alive
    if let vc = self as? UIViewController,
      vc.navigationController == nil && vc.presentingViewController == nil {
      return false
    }

    let proxy = JYObjectProxy()
    self.pProxy = proxy
    proxy.prepareProxy(self)

    return true
  }

}

extension NSObject {
  
  func watchAllRetainedProperties(_ level: Int) {
    
    guard level < 5 else {
      return
    }
    let arr: [AnyClass?] = [self.classForCoder, self.superclass, self.superclass?.superclass()]
    let watchedProperties = arr.reduce([String]()) { result, cls in
      result + getValidNames(cls)
    }
    
    for name in watchedProperties {
      guard let value = self.value(forKey: name) as? NSObject, !value.markAlive() else {
        continue
      }
      value.pProxy?.weakHost = self
      value.watchAllRetainedProperties(level + 1)
    }
  }
  
  private func getValidNames(_ cls: AnyClass?) -> [String] {
    guard let cls = cls, isvalidClassName(cls) else {
      return []
    }
    return getPropertyNames(cls)
  }
  
  private func isvalidClassName(_ cls: AnyClass) -> Bool {
    let className = NSStringFromClass(cls)
    return !className.isSystemObject
  }
  
  private func getPropertyNames(_ cls: AnyClass) -> [String] {
    var names: [String] = []
    var count: UInt32 = 0
    let properties = class_copyPropertyList(cls, &count)
    
    guard count > 0 else {
      free(properties)
      return names
    }
    
    for i in 0..<count {
      let property = properties?[Int(i)]
      guard let name = getPropertyName(property),
        let typeName = getTypeName(property),
        isvalidTypeName(typeName),
        !isStrongProperty(typeName) else {
        continue
      }
      names.append(name)
    }
    return names
  }
  
  private func getPropertyName(_ property: objc_property_t?) -> String? {
    guard let property = property else { return nil }
    let str = property_getName(property)
    return String(utf8String: str)
  }
  
  private func getTypeName(_ property: objc_property_t?) -> String? {
    /**
     属性类型  name值：T  value：变化
     编码类型  name值：C(copy) &(strong) W(weak) 空(assign) 等 value：无
     非/原子性 name值：空(atomic) N(Nonatomic)  value：无
     变量名称  name值：V  value：变化
     */
    guard let property = property else { return nil }
    guard let typeName = property_getAttributes(property) else {
      return nil
    }
    return String(utf8String: typeName)
  }
  
  private func isvalidTypeName(_ name: String) -> Bool {
    let checkPrefixArray = ["T@\"PObjectProxy\"", "T@\"UI", "T@\"NS", "KVO"]
    for prefix in checkPrefixArray {
      if name.contains(prefix) {
        return false
      }
    }
    return true
  }
  
  private func isStrongProperty(_ typeName: String?) -> Bool {
    guard let typeName = typeName else {
      return false
    }
    return typeName.range(of: ",&,") != nil
  }
  
}
