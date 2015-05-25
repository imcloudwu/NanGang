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
    @IBOutlet weak var progressBar: UIProgressView!
    
    var _data = [PhotoObj]()
    var _group:[GroupItem]!
    
    var _faces = [UIImage]()
    
    var sourceActionSheet:UIActionSheet!
    var groupActionSheet:UIActionSheet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        KairosSDK.initWithAppId("554468cd", appKey: "8b1523aad38b4cd8fe13c18bd469ea64")
        
        progressBar.hidden = true
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationItem.title = "上傳照片(\(self._data.count))"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let selectBtn = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: self, action: "selectBtnClick")
        selectBtn.image = UIImage(named: "Add File-25.png")
        let uploadBtn = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: self, action: "uploadBtnClick")
        uploadBtn.image = UIImage(named: "Upload To Cloud-25.png")
        self.navigationItem.leftBarButtonItem  = uploadBtn
        self.navigationItem.rightBarButtonItem  = selectBtn
        
        sourceActionSheet = UIActionSheet(title: "", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil,otherButtonTitles: "從相簿...","從相機...")
        
        groupActionSheet = UIActionSheet(title: "請選擇要上傳的群組", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
        
        _group = Global.TeacherGroups()
        for group in _group{
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
            self.navigationItem.title = "上傳照片(\(self._data.count))"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("photoCell") as! PhotoCell
        cell.ImageView.image = _data[indexPath.row].Image
        cell.Comment.text = _data[indexPath.row].Comment == "" ? "點選增加註解" : _data[indexPath.row].Comment
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let inputBox = UIAlertView()
        inputBox.delegate = self
        inputBox.alertViewStyle = UIAlertViewStyle.PlainTextInput
        //inputBox.title = "系統訊息"
        inputBox.message = "編輯註解"
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
        //清除要傳給人臉辨識的照片清單
        self._faces.removeAll(keepCapacity: false)
        
        let currentGroup = _group[groupIndex]
        let groupID = currentGroup.GroupId
        let groupChannel = currentGroup.ChannelName
        let groupName = currentGroup.GroupName
        
        if self._data.count == 0{
            let alert = UIAlertView()
            //alert.title = "系統訊息"
            alert.message = "上傳清單目前是空的"
            alert.addButtonWithTitle("OK")
            alert.show()
            return
        }
        
        progressBar.hidden = false
        
        Global.Loading.showActivityIndicator(self.view)
        
        var uploadData = [PFObject]()
        
        for data in self._data{
            
            //加入人臉辨識照片清單
            self._faces.append(data.Image)
            
            var detail_file = PFFile(data: UIImageJPEGRepresentation(data.Image,0.8))
            var preview_file = PFFile(data: UIImageJPEGRepresentation(data.Image.GetResizeImage(0.5), 0.1))
            
            var object = PFObject(className: "PhotoData")
            //object.ACL!.setPublicWriteAccess(true)
            object["preview"] = preview_file
            object["detail"] = detail_file
            object["channel"] = groupChannel
            object["comment"] = data.Comment
            object["group"] = groupName
            
            uploadData.append(object)
        }
        
        var count = 0
        var percent = 1 / Float(uploadData.count)
        progressBar.progress = 0
        
        for each in uploadData{
            
            each.saveInBackgroundWithBlock({ (succeed, error) -> Void in
                
                //已經回來的總數
                count++
                self.progressBar.progress = Float(count) * percent
                
                self._data.removeAtIndex(0)
                self.tableView.reloadData()
                self.navigationItem.title = "上傳照片(\(self._data.count))"
                
                Global.LastNewsViewChanged = true
                Global.PreviewViewChanged = true
                
                //傳到最後一個完成後執行
                if count == uploadData.count{
                    //轉到人臉辨識及推播畫面
                    self.progressBar.progress = 1
                    
                    Global.Loading.hideActivityIndicator(self.view)
                    
                    Global.CurrentGroup = currentGroup
                    
                    self.progressBar.hidden = true
                    
                    //跳到人臉偵測的畫面
                    let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("faceView") as! FaceDetectViewCtrl
                    nextView._data = self._faces
                    self.navigationController?.pushViewController(nextView, animated: true)
                }
            })
        }
        
        /*
        //上傳照片
        PFObject.saveAllInBackground(uploadData) { (succeed, error) -> Void in
        
        self._data.removeAll(keepCapacity: false)
        self.tableView.reloadData()
        self.navigationItem.title = "上傳照片(\(self._data.count))"
        
        Global.Loading.hideActivityIndicator(self.view)
        
        Global.LastNewsViewChanged = true
        Global.PreviewViewChanged = true
        
        let alert = UIAlertView()
        alert.title = "系統訊息"
        alert.message = "上傳完成"
        alert.addButtonWithTitle("OK")
        alert.show()
        
        var data = [
        "alert":"\(groupName) 新增了 \(uploadData.count) 張照片",
        "badge":"Increment",
        "sound":"n1.caf"
        ];
        
        //推播訊息
        var pushQuery = PFInstallation.query()
        pushQuery!.whereKey("deviceToken", notEqualTo: Global.MyDeviceToken)
        pushQuery!.whereKey("channels", equalTo: groupChannel)
        
        var push = PFPush()
        push.setQuery(pushQuery)
        //push.setChannel(Global.MyGroups[buttonIndex - 1].ChannelName)
        push.setData(data)
        //push.setMessage("新照片通知")
        
        push.sendPushInBackground()
        }
        */
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        
        if actionSheet == sourceActionSheet{//選照片來源
            if buttonIndex == 1{
                if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
                    
                    var customPicker = ELCImagePickerController(imagePicker: ())
                    customPicker.maximumImagesCount = 10 //Set the maximum number of images to select, defaults to 4
                    customPicker.returnsOriginalImage = false //Only return the fullScreenImage, not the fullResolutionImage
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
    
    //相機使用
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        
        var choseImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //縮小一半尺寸
        var shrinkedImage = choseImage.GetResizeImage(0.5)
        
        self._data.append(PhotoObj(Image: shrinkedImage, Comment: ""))
        
        tableView.reloadData()
        self.navigationItem.title = "上傳照片(\(self._data.count))"
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //相簿使用
    func elcImagePickerController(picker:ELCImagePickerController, didFinishPickingMediaWithInfo info:[AnyObject]) -> (){
        
        for each in info{
            var img = each[UIImagePickerControllerOriginalImage] as! UIImage
            //縮小一半尺寸
            //var shrinkedImage = img.GetResizeImage(0.5)
            
            self._data.append(PhotoObj(Image: img, Comment: ""))
        }
        
        tableView.reloadData()
        self.navigationItem.title = "上傳照片(\(self._data.count))"
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

