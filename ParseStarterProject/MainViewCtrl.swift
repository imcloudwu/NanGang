////
////  ViewController.swift
////
////  Copyright 2011-present Parse Inc. All rights reserved.
////
//
//import UIKit
//import Parse
//
//class MainViewCtrl : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate {
//    
//    @IBOutlet weak var imgView: UIImageView!
//    
//    var _chooseImg:UIImage!
//    var _comment:String!
//    
//    var actionSheet:UIActionSheet!
//    
//    @IBAction func selectClick(sender: AnyObject) {
//        
//        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("gallery") as myGallery
//        self.navigationController?.pushViewController(nextView, animated: true)
//        
////        if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
////            
////            var picker: UIImagePickerController = UIImagePickerController()
////            picker.delegate = self
////            picker.allowsEditing = false
////            picker.sourceType = .SavedPhotosAlbum
////            
////            self.presentViewController(picker, animated: true, completion: nil)
////            
////        }
//    }
//    
//    @IBAction func takeClick(sender: AnyObject) {
//        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
//            
//            var picker: UIImagePickerController = UIImagePickerController()
//            picker.delegate = self
//            picker.allowsEditing = false
//            picker.sourceType = .Camera
//            picker.showsCameraControls = true
//            
//            self.presentViewController(picker, animated: true, completion: nil)
//            
//        }
//    }
//    
//    @IBAction func uploadClick(sender: AnyObject) {
//        
//        if _chooseImg != nil{
//            actionSheet.showInView(self.view)
//        }
//        else{
//            let alert = UIAlertView()
//            alert.title = "系統訊息"
//            alert.message = "未選擇相片"
//            alert.addButtonWithTitle("OK")
//            alert.show()
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        println(self.navigationItem.title)
//        self.navigationItem.title = "主畫面"
//        
//        actionSheet = UIActionSheet(title: "請選擇要發送的群組", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
//        
//        for group in Global.MyGroups{
//            actionSheet.addButtonWithTitle(group.GroupName)
//        }
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func imagePickerController(_picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
//        //var choseImage: UIImage = info[UIImagePickerControllerEditedImage] as UIImage
//        var choseImage = info[UIImagePickerControllerOriginalImage] as UIImage
//        
//        //縮小一半尺寸
//        var shrinkedImage = choseImage.GetResizeImage(0.5)
//        
//        imgView.image = shrinkedImage
//        _chooseImg = shrinkedImage
//        
//        _picker.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    // Called when a button is clicked. The view will be automatically dismissed after this call returns
//    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
//        
//        if buttonIndex > 0{
//                let inputBox = UIAlertView()
//                inputBox.delegate = self
//                inputBox.alertViewStyle = UIAlertViewStyle.PlainTextInput
//                inputBox.title = "系統訊息"
//                inputBox.message = "給這張圖片一個註解吧"
//                inputBox.addButtonWithTitle("確認")
//                inputBox.tag = buttonIndex
//                inputBox.show()
//        }
//    }
//    
//    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
//        
//        let tag = alertView.tag
//        let textField = alertView.textFieldAtIndex(0)
//        
//        _comment = ""
//        
//        if let str = textField?.text{
//            _comment = str
//        }
//        
//        UploadPicture(tag)
//    }
//    
//    func UploadPicture(buttonIndex:Int){
//        
//        Global.Loading.showActivityIndicator(self.view)
//        
//        var imgData = UIImageJPEGRepresentation(_chooseImg,0.8)
//        var imgFile = PFFile(data: imgData)
//        
//        var pre_img_data = UIImageJPEGRepresentation(_chooseImg.GetResizeImage(0.1), 0.8)
//        var pre_img_file = PFFile(data: pre_img_data)
//        
//        var object = PFObject(className: "PhotoData")
//        object.ACL.setPublicWriteAccess(true)
//        object["preview"] = pre_img_file
//        object["detail"] = imgFile
//        object["channel"] = Global.MyGroups[buttonIndex - 1].ChannelName
//        object["comment"] = _comment
//        object["group"] = Global.MyGroups[buttonIndex - 1].GroupName
//        
//        object.saveInBackgroundWithBlock { (Bool, NSError) -> Void in
//            Global.Loading.hideActivityIndicator(self.view)
//            let alert = UIAlertView()
//            alert.title = "系統訊息"
//            alert.message = "上傳完成"
//            alert.addButtonWithTitle("OK")
//            alert.show()
//            
//            // Send a notification to all devices subscribed to the "Giants" channel.
//            
//            var data = [
//                "alert":"woops! you got a new message",
//                "badge":"Increment",
//                "sound":"n1.caf"
//            ];
//            
//            var pushQuery = PFInstallation.query()
//            pushQuery.whereKey("deviceToken", notEqualTo: Global.MyDeviceToken)
//            pushQuery.whereKey("channels", equalTo: Global.MyGroups[buttonIndex - 1].ChannelName)
//            
//            var push = PFPush()
//            push.setQuery(pushQuery)
//            //push.setChannel(Global.MyGroups[buttonIndex - 1].ChannelName)
//            push.setData(data)
//            //push.setMessage("新照片通知")
//            
//            push.sendPushInBackground()
//        }
//        
//        
//    }
//}
//
