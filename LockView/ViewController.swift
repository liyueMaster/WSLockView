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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        lockView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func lockView(lockView: WSLockView, didFinishPath path: String) {
        print(path)
    }

}

