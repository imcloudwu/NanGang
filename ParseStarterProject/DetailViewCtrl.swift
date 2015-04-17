//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 3/27/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class DetailViewCtrl: UIViewController, UIScrollViewDelegate,UIAlertViewDelegate {
    
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
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
        
        if pfObject == nil{
            
            Global.LastNewsViewChanged = true
            Global.PreviewViewChanged = true
            
            let alert = UIAlertView()
            //alert.title = "系統訊息"
            alert.message = "該相片已被刪除"
            alert.addButtonWithTitle("OK")
            alert.show()
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        let file = pfObject?["detail"] as! PFFile
        let picComment = pfObject?["comment"] as! String
        let groupName = pfObject?["group"] as! String
        
        file.getDataInBackgroundWithBlock({ (NSData, NSError) -> Void in
            if let img = UIImage(data: NSData!){
                self.imageView.image = img
                self.comment.text = picComment
                
                let saveBtn = UIBarButtonItem(title: "儲存", style: UIBarButtonItemStyle.Plain, target: self, action: "SaveImg")
                saveBtn.image = UIImage(named: "Download From Cloud-25.png")
                self.navigationItem.rightBarButtonItems = [saveBtn]
                
                //老師身份新增刪除按鈕
                if Global.GetGroupItem(groupName)?.IsTeacher == true {
                    let deleteBtn = UIBarButtonItem(title: "刪除", style: UIBarButtonItemStyle.Plain, target: self, action: "AskForDelete")
                    deleteBtn.image = UIImage(named: "Trash-25.png")
                    self.navigationItem.rightBarButtonItems?.append(deleteBtn)
                }
                
                Global.Loading.hideActivityIndicator(self.view)
                self.progressBar.hidden = true
            }
        }, progressBlock: { (percent) -> Void in
            self.progressBar.progress = Float(percent) / 100
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?{
        return self.imageView
    }
    
    func SaveImg(){
        //儲存圖片到本機相簿
        UIImageWriteToSavedPhotosAlbum(imageView.image, self, nil, nil)
        let alert = UIAlertView()
        //alert.title = "系統訊息"
        alert.message = "儲存完成"
        alert.addButtonWithTitle("OK")
        alert.show()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func DeleteImg(){
        
        var query = PFQuery(className: "PhotoData")
        
        //指定條件
        //query.whereKey("objectId", equalTo: _SelectPicId)
        
        //var pfObject = query.getFirstObject()
        
        query.getObjectInBackgroundWithId(_SelectPicId) { (PFObject, NSError) -> Void in
            PFObject!.deleteInBackgroundWithBlock({ (succeed, error) -> Void in
                if succeed{
                    
                    Global.LastNewsViewChanged = true
                    Global.PreviewViewChanged = true
                    
                    let alert = UIAlertView()
                    //alert.title = "系統訊息"
                    alert.message = "刪除成功"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else{
                    let alert = UIAlertView()
                    //alert.title = "系統訊息"
                    alert.message = "刪除失敗:\(error!.userInfo)"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            })
        }
    }
    
    func AskForDelete(){
        
        let confirmAlert = UIAlertView()
        //confirmAlert.title = "系統訊息"
        confirmAlert.message = "確認刪除？"
        confirmAlert.addButtonWithTitle("確認")
        confirmAlert.addButtonWithTitle("取消")
        confirmAlert.delegate = self
        confirmAlert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        //執行刪除
        if alertView.buttonTitleAtIndex(buttonIndex) == "確認"{
            DeleteImg()
        }
    }
}

