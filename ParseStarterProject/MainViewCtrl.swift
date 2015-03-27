//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class MainViewCtrl : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    @IBOutlet weak var imgView: UIImageView!
    
    @IBAction func selectClick(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
            
            var picker: UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .SavedPhotosAlbum
    
            self.presentViewController(picker, animated: true, completion: nil)

            }
    }
    
    @IBAction func takeClick(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            
            var picker: UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .Camera
            picker.showsCameraControls = true
            
            self.presentViewController(picker, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func uploadClick(sender: AnyObject) {
        
        Global.Loading.showActivityIndicator(self.view)
        
        if let source = imgView.image{
            var image = source
            var imgData = UIImagePNGRepresentation(image)
            var imgFile = PFFile(data: imgData)
            
            var pre_img_data = UIImageJPEGRepresentation(source, 0.25)
            var pre_img_file = PFFile(data: pre_img_data)
            
            var object = PFObject(className: "PhotoData")
            object["preview"] = pre_img_file
            object["detail"] = imgFile
            
            object.saveInBackgroundWithBlock { (Bool, NSError) -> Void in
                Global.Loading.hideActivityIndicator(self.view)
                let alert = UIAlertView()
                alert.title = "系統訊息"
                alert.message = "上傳完成"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                // Send a notification to all devices subscribed to the "Giants" channel.
                var push = PFPush()
                push.setChannel("V")
                push.setMessage("有新的照片通知")
                push.sendPushInBackground()
            }
        }
        else{
            Global.Loading.hideActivityIndicator(self.view)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imagePickerController(_picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        var choseImage: UIImage = info[UIImagePickerControllerEditedImage] as UIImage
        imgView.image = choseImage
        
        _picker.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func push(sender: AnyObject) {
        
    }
    
    
}

