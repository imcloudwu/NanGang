//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 3/27/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class DetailViewCtrl: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Global.Loading.showActivityIndicator(self.view)
        
        var query = PFQuery(className: "PhotoData")
        
        //指定條件
        query.whereKey("objectId", equalTo: Global.SelectPicId)
        
        var pfObject = query.getFirstObject()
        
        let file = pfObject["detail"] as PFFile
        
        file.getDataInBackgroundWithBlock { (NSData, NSError) -> Void in
            if let img = UIImage(data: NSData){
                self.imgView.image = img
                Global.Loading.hideActivityIndicator(self.view)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

