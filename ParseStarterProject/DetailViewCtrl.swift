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
    
    @IBOutlet weak var comment: UILabel!
    
    var _SelectPicId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.automaticallyAdjustsScrollViewInsets = false
        
        scrView.delegate = self
        scrView.maximumZoomScale = 2.0
        scrView.minimumZoomScale = 1.0
        
        Global.Loading.showActivityIndicator(self.view)
        
        var query = PFQuery(className: "PhotoData")
        
        //指定條件
        query.whereKey("objectId", equalTo: _SelectPicId)
        
        var pfObject = query.getFirstObject()
        
        let file = pfObject["detail"] as PFFile
        let picComment = pfObject["comment"] as String
        let groupName = pfObject["group"] as String
        
        file.getDataInBackgroundWithBlock { (NSData, NSError) -> Void in
            if let img = UIImage(data: NSData){
                self.imageView.image = img
                self.comment.text = picComment
                
                //老師身份新增刪除按鈕
                if Global.GetGroupItem(groupName)?.IsTeacher == true {
                    var button = UIBarButtonItem(title: "刪除", style: UIBarButtonItemStyle.Plain, target: self, action: "DeleteImg")
                    self.navigationItem.rightBarButtonItem  = button
                }
                
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
    
    func DeleteImg(){
        
        var query = PFQuery(className: "PhotoData")
        
        //指定條件
        //query.whereKey("objectId", equalTo: _SelectPicId)
        
        //var pfObject = query.getFirstObject()
        
        query.getObjectInBackgroundWithId(_SelectPicId) { (PFObject, NSError) -> Void in
            PFObject.deleteInBackgroundWithBlock({ (succeed, error) -> Void in
                if succeed{
                    
                    Global.LastNewsViewUpdate = true
                    Global.PreviewViewUpdate = true
                    
                    let alert = UIAlertView()
                    alert.title = "系統訊息"
                    alert.message = "刪除成功"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else{
                    let alert = UIAlertView()
                    alert.title = "系統訊息"
                    alert.message = "刪除失敗:\(error.userInfo)"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            })
        }
        
    }
}

