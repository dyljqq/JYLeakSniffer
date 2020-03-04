//
//  ViewController.swift
//  JYLeakSniffer
//
//  Created by 季勤强 on 2020/2/26.
//  Copyright © 2020 dyljqq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
      let vc = JYViewController()
      self?.present(vc, animated: true, completion: nil)
    }
  }
  
}

