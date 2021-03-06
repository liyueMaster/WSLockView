//
//  ViewController.swift
//  LockView
//
//  Created by 李越 on 15/12/25.
//  Copyright © 2015年 liyue. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WSLockViewDelegate {
    
    @IBOutlet weak var lockView: WSLockView!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        lockView.delegate = self
        
        print(TARGET_OS_IOS)
        print(TARGET_OS_SIMULATOR)
        print(TARGET_IPHONE_SIMULATOR)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func lockView(_ lockView: WSLockView, didFinishPath path: String) {
        print(path)
    }
    
    func lockView(_ lockView: WSLockView, didFinishImage image: UIImage!) {
        imageView.image = image
    }

}

