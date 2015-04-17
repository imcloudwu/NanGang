//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 04/09/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class TabBarCtrl: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //如果沒有一個群組屬於老師身份,將上傳照片的功能拿掉
        let indexToRemove = 2
        if indexToRemove < self.viewControllers?.count && Global.TeacherGroups().count == 0{
            var viewControllers = self.viewControllers
            viewControllers?.removeAtIndex(indexToRemove)
            self.viewControllers = viewControllers
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}