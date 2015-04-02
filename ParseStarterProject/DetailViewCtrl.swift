//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 3/27/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class DetailViewCtrl: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrView: UIScrollView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.automaticallyAdjustsScrollViewInsets = false
        
        scrView.delegate = self
        scrView.maximumZoomScale = 2.0
        scrView.minimumZoomScale = 1.0
        
        Global.Loading.showActivityIndicator(self.view)
        
        var query = PFQuery(className: "PhotoData")
        
        //指定條件
        query.whereKey("objectId", equalTo: Global.SelectPicId)
        
        var pfObject = query.getFirstObject()
        
        let file = pfObject["detail"] as PFFile
        
        file.getDataInBackgroundWithBlock { (NSData, NSError) -> Void in
            if let img = UIImage(data: NSData){
                self.imageView.image = img
                
                Global.Loading.hideActivityIndicator(self.view)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?{
        return self.imageView
    }
}

