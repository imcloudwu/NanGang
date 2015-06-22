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
    var _DataArray:[String]!
    var _currentIndex:Int!
    var _ImageArray:[UIImage]!
    
    func left_swip(){
        //向左滑動代表要看右邊的,index要變大
        if _DataArray.count > 0 && _currentIndex != nil && _currentIndex < _DataArray.count - 1{
            _currentIndex = _currentIndex + 1
            _SelectPicId = _DataArray[_currentIndex]
            GetImg(_SelectPicId)
            
            showAminationOnAdvert(kCATransitionFromRight)
        }
        
        if _ImageArray.count > 0 && _currentIndex != nil && _currentIndex < _ImageArray.count - 1{
            _currentIndex = _currentIndex + 1
            imageView.image = _ImageArray[_currentIndex]
            showAminationOnAdvert(kCATransitionFromRight)
        }
    }
    
    func right_swip(){
        //向右滑動代表要看左邊的,index要變小
        if _DataArray.count > 0 && _currentIndex != nil && _currentIndex != 0{
            _currentIndex = _currentIndex - 1
            _SelectPicId = _DataArray[_currentIndex]
            GetImg(_SelectPicId)
            
            showAminationOnAdvert(kCATransitionFromLeft)
        }
        
        if _ImageArray.count > 0 && _currentIndex != nil && _currentIndex != 0{
            _currentIndex = _currentIndex - 1
            imageView.image = _ImageArray[_currentIndex]
            showAminationOnAdvert(kCATransitionFromLeft)
        }
    }
    
    func tap_action(){
        if scrView.zoomScale < 4.0{
            scrView.zoomScale = 4.0
        }
        else{
            scrView.zoomScale = 1.0
        }
    }
    
    func showAminationOnAdvert(subtype :String){
        var transitionAnimation = CATransition();
        transitionAnimation.type = kCATransitionPush;
        transitionAnimation.subtype = subtype;
        
        transitionAnimation.duration = 0.5;
        
        transitionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        transitionAnimation.fillMode = kCAFillModeBoth;
        
        imageView.layer.addAnimation(transitionAnimation, forKey: "fadeAnimation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressBar.hidden = true
        
        if _DataArray == nil {
            _DataArray = [String]()
        }
        
        if _ImageArray == nil{
            _ImageArray = [UIImage]()
        }
        
        //self.automaticallyAdjustsScrollViewInsets = false
        
        scrView.delegate = self
        scrView.maximumZoomScale = 4.0
        scrView.minimumZoomScale = 1.0
        scrView.showsHorizontalScrollIndicator = false
        scrView.showsVerticalScrollIndicator = false
        
        let leftGesture = UISwipeGestureRecognizer(target: self, action: "left_swip")
        leftGesture.direction = UISwipeGestureRecognizerDirection.Left
        
        let rightGesture = UISwipeGestureRecognizer(target: self, action: "right_swip")
        rightGesture.direction = UISwipeGestureRecognizerDirection.Right
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tap_action")
        tapGesture.numberOfTapsRequired = 2
        
        scrView.addGestureRecognizer(leftGesture)
        scrView.addGestureRecognizer(rightGesture)
        scrView.addGestureRecognizer(tapGesture)
        
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
        
        if _SelectPicId != nil{
            GetImg(_SelectPicId)
        }
        else if _currentIndex < _ImageArray.count{
            imageView.image = _ImageArray[_currentIndex]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?{
        return self.imageView
    }
    
    func GetImg(id:String){
        
        Global.Loading.showActivityIndicator(self.view)
        
        progressBar.hidden = false
        progressBar.progress = 0
        
        var query = PFQuery(className: "PhotoData")
        
        //指定條件
        query.whereKey("objectId", equalTo: id)
        
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
        
        //有刪除權限
        let canDelete = pfObject?.ACL?.getWriteAccessForUser(PFUser.currentUser()!)
        let file = pfObject?["detail"] as! PFFile
        let picComment = pfObject?["comment"] as! String
        let groupName = pfObject?["group"] as! String
        
        file.getDataInBackgroundWithBlock({ (NSData, NSError) -> Void in
            if let img = UIImage(data: NSData!){
                self.imageView.image = img
                self.comment.text = picComment
                
                let saveBtn = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: self, action: "SaveImg")
                saveBtn.image = UIImage(named: "Download From Cloud-25.png")
                self.navigationItem.rightBarButtonItems = [saveBtn]
                
                //有權限者新增刪除按鈕
                if canDelete == true {
                    let deleteBtn = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: self, action: "AskForDelete")
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
    
    func DeleteImg(id:String){
        
        var query = PFQuery(className: "PhotoData")
        
        //指定條件
        //query.whereKey("objectId", equalTo: _SelectPicId)
        
        //var pfObject = query.getFirstObject()
        
        query.getObjectInBackgroundWithId(id) { (PFObject, NSError) -> Void in
            
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
            DeleteImg(_SelectPicId)
        }
    }
}

