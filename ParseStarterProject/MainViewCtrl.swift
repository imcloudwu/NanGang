//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class MainViewCtrl : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var chooseImg:UIImage!
    
    var actionSheet:UIActionSheet!
    
    @IBAction func selectClick(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
            
            var picker: UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .SavedPhotosAlbum
            
            self.presentViewController(picker, animated: true, completion: nil)

            }
    }
    
    @IBAction func takeClick(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            
            var picker: UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .Camera
            picker.showsCameraControls = true
            
            self.presentViewController(picker, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func uploadClick(sender: AnyObject) {
        
        actionSheet.showInView(self.view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionSheet = UIActionSheet(title: "請選擇要發送的群組", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
        
        for group in Global.MyGroups{
            actionSheet.addButtonWithTitle(group.GroupName)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imagePickerController(_picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        //var choseImage: UIImage = info[UIImagePickerControllerEditedImage] as UIImage
        var choseImage = info[UIImagePickerControllerOriginalImage] as UIImage
        
        //縮小一半尺寸
        var shrinkedImage = choseImage.GetResizeImage(0.5)
        
        imgView.image = shrinkedImage
        chooseImg = shrinkedImage
        
        _picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Called when a button is clicked. The view will be automatically dismissed after this call returns
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        
        if buttonIndex > 0{
            
            Global.Loading.showActivityIndicator(self.view)
            
            if let source = chooseImg{
                
                var imgData = UIImageJPEGRepresentation(source,0.8)
                var imgFile = PFFile(data: imgData)
                
                var pre_img_data = UIImageJPEGRepresentation(source.GetResizeImage(50,height: 50), 0.8)
                var pre_img_file = PFFile(data: pre_img_data)
                
                var object = PFObject(className: "PhotoData")
                object["preview"] = pre_img_file
                object["detail"] = imgFile
                object["channel"] = Global.MyGroups[buttonIndex - 1].ChannelName
                object["comment"] = "good photo"
                object["group"] = Global.MyGroups[buttonIndex - 1].GroupName
                
                object.saveInBackgroundWithBlock { (Bool, NSError) -> Void in
                    Global.Loading.hideActivityIndicator(self.view)
                    let alert = UIAlertView()
                    alert.title = "系統訊息"
                    alert.message = "上傳完成"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    
                    // Send a notification to all devices subscribed to the "Giants" channel.
                        
                    var data = [
                            "alert":"woops! you got a new message",
                            "badge":"Increment",
                            "sound":"n1.caf"
                    ];
                    
                    var pushQuery = PFInstallation.query()
                    pushQuery.whereKey("deviceToken", notEqualTo: Global.MyDeviceToken)
                    pushQuery.whereKey("channels", equalTo: Global.MyGroups[buttonIndex - 1].ChannelName)
                        
                    var push = PFPush()
                    push.setQuery(pushQuery)
                    //push.setChannel(Global.MyGroups[buttonIndex - 1].ChannelName)
                    push.setData(data)
                    //push.setMessage("新照片通知")
                        
                    push.sendPushInBackground()
                }
            }
            else{
                Global.Loading.hideActivityIndicator(self.view)
                let alert = UIAlertView()
                alert.title = "系統訊息"
                alert.message = "未選擇相片"
                alert.addButtonWithTitle("OK")
                alert.show()
            }
        }
    }
    
}

