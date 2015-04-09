//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 04/09/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class UploadCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,ELCImagePickerControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var _data = [PhotoObj]()
    
    var sourceActionSheet:UIActionSheet!
    var groupActionSheet:UIActionSheet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationItem.title = "上傳相片"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let selectBtn = UIBarButtonItem(title: "選取相片", style: UIBarButtonItemStyle.Bordered, target: self, action: "selectBtnClick")
        let uploadBtn = UIBarButtonItem(title: "開始上傳", style: UIBarButtonItemStyle.Plain, target: self, action: "uploadBtnClick")
        self.navigationItem.leftBarButtonItem  = uploadBtn
        self.navigationItem.rightBarButtonItem  = selectBtn
        
        sourceActionSheet = UIActionSheet(title: "", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil,otherButtonTitles: "從相簿...","從相機...")
        
        groupActionSheet = UIActionSheet(title: "請選擇要上傳的群組", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
        
        for group in Global.MyGroups{
            groupActionSheet.addButtonWithTitle(group.GroupName)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        if editingStyle == UITableViewCellEditingStyle.Delete{
            self._data.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("photoCell") as PhotoCell
        cell.Image.image = _data[indexPath.row].Image
        cell.Comment.text = _data[indexPath.row].Comment == "" ? "點選增加註解" : _data[indexPath.row].Comment
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let inputBox = UIAlertView()
        inputBox.delegate = self
        inputBox.alertViewStyle = UIAlertViewStyle.PlainTextInput
        inputBox.title = "系統訊息"
        inputBox.message = "給這張圖片一個註解吧"
        inputBox.addButtonWithTitle("確認")
        inputBox.tag = indexPath.row
        inputBox.textFieldAtIndex(0)?.text = self._data[indexPath.row].Comment
        inputBox.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        let tag = alertView.tag
        let textField = alertView.textFieldAtIndex(0)
        
        if let str = textField?.text{
            self._data[tag].Comment = str
        }
        
        self.tableView.reloadData()
    }
    
    func selectBtnClick(){
        sourceActionSheet.showInView(self.view)
    }
    
    func uploadBtnClick(){
        groupActionSheet.showInView(self.view)
    }
    
    func uploadPhoto(groupIndex:Int){
        
        if self._data.count == 0{
            let alert = UIAlertView()
            alert.title = "系統訊息"
            alert.message = "上傳清單目前是空的"
            alert.addButtonWithTitle("OK")
            alert.show()
            return
        }
        
        Global.Loading.showActivityIndicator(self.view)
        
        var uploadData = [PFObject]()
        
        for data in self._data{
            
            var detail_file = PFFile(data: UIImageJPEGRepresentation(data.Image,0.8))
            var preview_file = PFFile(data: UIImageJPEGRepresentation(data.Image.GetResizeImage(0.1), 0.8))
            
            var object = PFObject(className: "PhotoData")
            object.ACL.setPublicWriteAccess(true)
            object["preview"] = preview_file
            object["detail"] = detail_file
            object["channel"] = Global.MyGroups[groupIndex].ChannelName
            object["comment"] = data.Comment
            object["group"] = Global.MyGroups[groupIndex].GroupName
            
            uploadData.append(object)
        }
        
        //上傳照片
        PFObject.saveAllInBackground(uploadData) { (succeed, error) -> Void in
            
            self._data.removeAll(keepCapacity: false)
            self.tableView.reloadData()
            
            Global.Loading.hideActivityIndicator(self.view)
            
            let alert = UIAlertView()
            alert.title = "系統訊息"
            alert.message = "上傳完成"
            alert.addButtonWithTitle("OK")
            alert.show()
            
            var data = [
                "alert":"woops! there's \(uploadData.count) has been uploaded",
                "badge":"Increment",
                "sound":"n1.caf"
            ];
            
            var pushQuery = PFInstallation.query()
            pushQuery.whereKey("deviceToken", notEqualTo: Global.MyDeviceToken)
            pushQuery.whereKey("channels", equalTo: Global.MyGroups[groupIndex].ChannelName)
            
            var push = PFPush()
            push.setQuery(pushQuery)
            //push.setChannel(Global.MyGroups[buttonIndex - 1].ChannelName)
            push.setData(data)
            //push.setMessage("新照片通知")
            
            push.sendPushInBackground()
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        
        if actionSheet == sourceActionSheet{//選照片來源
            if buttonIndex == 1{
                if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
                    
                    var customPicker = ELCImagePickerController(imagePicker: ())
                    customPicker.maximumImagesCount = 5 //Set the maximum number of images to select, defaults to 4
                    customPicker.returnsOriginalImage = true //Only return the fullScreenImage, not the fullResolutionImage
                    customPicker.returnsImage = true //Return UIimage if YES. If NO, only return asset location information
                    customPicker.onOrder = true //For multiple image selection, display and return selected order of images
                    customPicker.imagePickerDelegate = self
                    
                    self.presentViewController(customPicker, animated: true, completion: nil)
                }
            }
            else if buttonIndex == 2{
                if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
                    
                    var picker: UIImagePickerController = UIImagePickerController()
                    picker.delegate = self
                    picker.allowsEditing = false
                    picker.sourceType = .Camera
                    picker.showsCameraControls = true
                    
                    self.presentViewController(picker, animated: true, completion: nil)
                }
            }
        }
        else{//選上傳群組
            if buttonIndex > 0{
                uploadPhoto(buttonIndex-1)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        
        var choseImage = info[UIImagePickerControllerOriginalImage] as UIImage
        
        //縮小一半尺寸
        var shrinkedImage = choseImage.GetResizeImage(0.5)
        
        self._data.append(PhotoObj(Image: shrinkedImage, Comment: ""))
        
        tableView.reloadData()
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func elcImagePickerController(picker:ELCImagePickerController, didFinishPickingMediaWithInfo info:[AnyObject]) -> (){
        
        for each in info{
            var img = each[UIImagePickerControllerOriginalImage] as UIImage
            //縮小一半尺寸
            var shrinkedImage = img.GetResizeImage(0.5)
            
            self._data.append(PhotoObj(Image: shrinkedImage, Comment: ""))
        }
        
        tableView.reloadData()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func elcImagePickerControllerDidCancel(picker:ELCImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

struct PhotoObj{
    var Image:UIImage
    var Comment:String
}

