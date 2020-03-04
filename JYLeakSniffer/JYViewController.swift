//
//  JYViewController.swift
//  JYLeakSniffer
//
//  Created by 季勤强 on 2020/3/3.
//  Copyright © 2020 dyljqq. All rights reserved.
//

import UIKit

class JYViewController: UIViewController {
  
  var timer: Timer?

  override func viewDidLoad() {
    super.viewDidLoad()

    self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(test), userInfo: nil, repeats: true)
    
    let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
    button.setTitle("close", for: .normal)
    button.backgroundColor = .black
    button.titleLabel?.textColor = .white
    button.addTarget(self, action: #selector(close), for: .touchUpInside)
    view.addSubview(button)
  }
  
  @objc func close() {
    dismiss(animated: true, completion: nil)
  }
  
  @objc func test() {
    print("test...")
  }
  
  deinit {
    print("end...")
    if self.timer != nil {
      self.timer?.invalidate()
      self.timer = nil
    }
  }

}
