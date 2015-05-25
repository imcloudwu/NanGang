//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 04/09/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class FaceDetectViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate {
    
    var _data:[UIImage]!
    var _persons:[Person]!
    var _students:[Student]!
    
    var _currentPersonIndex:Int!
    
    var studentActionSheet:UIActionSheet!
    
    var _pushConnector:Connector!
    var _queryConnector:Connector!
    
    var _currentGroup:GroupItem!
    
    var _studentButtonCompleted = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Global.Loading.showActivityIndicator(self.view)
        
        _currentGroup = Global.CurrentGroup
        
        _pushConnector = _currentGroup.connector.Clone()
        _pushConnector.Contract = "PushNotification.Teacher"
        _pushConnector.GetSessionID()
        _queryConnector = _currentGroup.connector.Clone()
        _queryConnector.Contract = "iLink.Teacher"
        _queryConnector.GetSessionID()
        
        _persons = [Person]()
        _students = [Student]()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        studentActionSheet = UIActionSheet(title: "請選擇學生", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
        
        let sentBtn = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: self, action: "sendBtnClick")
        sentBtn.image = UIImage(named: "Online-25.png")
        
        self.navigationItem.rightBarButtonItem = sentBtn
        
        AddStudentButtonItem()
        Detect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //加入學生清單按鈕
    func AddStudentButtonItem(){
        HttpClient.Get("http://dsns.1campus.net/\(self._currentGroup.connector.DSNS)/sakura/GetGroupMember?stt=PassportAccessToken&AccessToken=\(self._currentGroup.connector.AccessToken)&parser=spliter&content=GroupId:\(self._currentGroup.GroupId)"){ (nsData) -> () in
            
            //println(NSString(data: nsData, encoding: NSUTF8StringEncoding))
            
            var xml = SWXMLHash.parse(nsData)
            
            for student in xml["Body"]["Group"]["Student"]{
                if let id = student["StudentId"].element?.text{
                    if let name = student["StudentName"].element?.text{
                        
                        self.studentActionSheet.addButtonWithTitle(name)
                        
                        self._students.append(Student(ID: id,Name: name,Number: nil))
                    }
                }
            }
            
            self._studentButtonCompleted = true
        }
    }
    
    //人臉辨識
    func Detect(){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            println("This is run on the background queue")
            
            var ciDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [
                CIDetectorAccuracy: CIDetectorAccuracyHigh
                ])
            
            var count = 0
            
            //抓出人臉
            for img in self._data{
                
                count++
                
                var ciImage = CIImage(CGImage: img.CGImage)
                
                var features = ciDetector.featuresInImage(ciImage)
                
                for feature in features {
                    //face
                    var faceRect = (feature as! CIFaceFeature).bounds
                    faceRect.origin.y = img.size.height - faceRect.origin.y - faceRect.size.height
                    
                    let rect: CGRect = CGRectMake(faceRect.origin.x, faceRect.origin.y, faceRect.width, faceRect.height)
                    
                    // Create bitmap image from context using the rect
                    let imageRef = CGImageCreateWithImageInRect(img.CGImage, rect)
                    
                    // Create a new image based on the imageRef and rotate back to the original orientation
                    let face_img = UIImage(CGImage: imageRef, scale: img.scale, orientation: img.imageOrientation)
                    
                    self._persons.append(Person(Name: "辨識中...",Number: nil,Face: face_img,IsNewFace: false))
                }
                
                //last one
                if count == self._data.count{
                    
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        
                        self.tableView.reloadData()
                        Global.Loading.hideActivityIndicator(self.view)
                        
                        var index = -1
                        
                        for person in self._persons{
                            
                            index++
                            var current_index = index
                            
                            self.RecognizeFace(person.Face, galleryName: self._currentGroup.ChannelName, callback: { (subjectID) -> () in
                                
                                if subjectID != nil{
                                    
                                    self._persons[current_index].Number = subjectID
                                    
                                    self.GetStudentName(subjectID, callback: { (name) -> () in
                                        self._persons[current_index].Name = name
                                        self.tableView.reloadData()
                                    })
                                }
                                else{
                                    self._persons[current_index].Name = "請點擊作標註"
                                    self.tableView.reloadData()
                                }
                                
                            })
                        }
                    }
                }
                
            }
        })
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if alertView.message == "推播通知發送完成"{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func sendBtnClick(){
        
        var body = ""
        
        for person in _persons{
            
            body += "<ID>\(person.Number)</ID>"
            
            if person.IsNewFace == true && person.Number != nil{
                EnrollFace(person.Face, subjectId: person.Number, galleryName: _currentGroup.ChannelName)
            }
        }
        
        var message = "\(_currentGroup.GroupName) 新增了有您孩子在內的照片"
        
        Global.Loading.showActivityIndicator(self.view)
        
        _pushConnector.SendRequest("SendMessageByIDs", body: "<Request><IDs>\(body)</IDs><Message>\(message)</Message></Request>", function: { (response) -> () in
            
            Global.Loading.hideActivityIndicator(self.view)
            
            let alert = UIAlertView()
            alert.message = "推播通知發送完成"
            alert.addButtonWithTitle("OK")
            alert.delegate = self
            alert.show()
        })
        
    }
    
    func RecognizeFace(image:UIImage,galleryName:String,callback:(subjectID:String!) -> ()){
        
        var replace_str = galleryName.stringByReplacingOccurrencesOfString("_",withString: "underLine")
        
        KairosSDK.recognizeWithImage(image, threshold: "0.5", galleryName: replace_str, maxResults: "", success: { (response) -> Void in
            //
            var subjectID:String!
            if let images = (response["images"] as? NSArray){
                if let transaction = images[0]["transaction"] as? NSDictionary{
                    if let subject = transaction["subject"] as? String{
                        subjectID = subject
                    }
                }
            }
            
            if subjectID != nil{
                callback(subjectID: subjectID)
            }
            else{
                callback(subjectID: nil)
            }
            
            }) { (response) -> Void in
                callback(subjectID: nil)
        }
    }
    
    func EnrollFace(image:UIImage,subjectId:String,galleryName:String){
        
        var replace_str = galleryName.stringByReplacingOccurrencesOfString("_",withString: "underLine")
        
        KairosSDK.enrollWithImage(image, subjectId: subjectId, galleryName: replace_str, success: { (response) -> Void in
            println("subjectId=\(subjectId) enroll success...")
            }) { (response) -> Void in
            println(response)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _persons.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("faceCell") as! FaceDetectCell
        cell.Name.text = "\(_persons[indexPath.row].Name)"
        cell.Face.image = _persons[indexPath.row].Face
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if _studentButtonCompleted {
            self.studentActionSheet.showInView(self.view)
            _currentPersonIndex = indexPath.row
        }
        else{
            let alert = UIAlertView()
            alert.message = "學生清單產生中,請稍候再試"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex > 0{
            
            var index = buttonIndex - 1
            
            self._persons[self._currentPersonIndex].Name = _students[index].Name
            self._persons[self._currentPersonIndex].IsNewFace = true
            
            if _students[index].Number == nil{
                
                GetStudentIdNumber(_students[index].ID, callback: { (idNumber) -> () in
                    
                    self._students[index].Number = idNumber
                    self._persons[self._currentPersonIndex].Number = idNumber
                    self.tableView.reloadData()
                })
            }
            else{
                
                self._persons[_currentPersonIndex].Number = _students[index].Number
                self.tableView.reloadData()
            }
        }
    }
    
    //用學生ID查詢身分證號
    func GetStudentIdNumber(id:String,callback:(idNumber:String!) -> ()){
        
        Global.Loading.showActivityIndicator(self.view)
        
        _queryConnector.SendRequest("GetStudentIdNumber", body: "<Request><StudentID>\(id)</StudentID></Request>", function: { (response) -> () in
            //println(NSString(data: response, encoding: NSUTF8StringEncoding))
            
            Global.Loading.hideActivityIndicator(self.view)
            
            var xml = SWXMLHash.parse(response)
            
            var idnumber:String!
            
            if let id_number = xml["Envelope"]["Body"]["Response"]["id_number"].element?.text{
                idnumber = id_number
            }
            
            if idnumber != nil{
                callback(idNumber: idnumber)
            }
            else{
                callback(idNumber: nil)
            }
        })
    }
    
    //用學生身分證號查詢學生名字
    func GetStudentName(number:String,callback:(name:String) -> ()){
        
        Global.Loading.showActivityIndicator(self.view)
        
        _queryConnector.SendRequest("GetStudentName", body: "<Request><Condition><IdNumber>\(number)</IdNumber></Condition></Request>", function: { (response) -> () in
            //println(NSString(data: response, encoding: NSUTF8StringEncoding))
            
            Global.Loading.hideActivityIndicator(self.view)
            
            var xml = SWXMLHash.parse(response)
            
            var student_name:String!
            
            if let name = xml["Envelope"]["Body"]["Response"]["Student"]["Name"].element?.text{
                student_name = name
            }
            
            if student_name != nil{
                callback(name: student_name)
            }
            else{
                callback(name: "請點擊作標註")
            }
        })
    }
    
    func Push(){
        
        var data = [
            "alert":"\(_currentGroup.GroupName) 新增了有您小孩在內的照片",
            "badge":"Increment",
            "sound":"n9.caf"
        ];
        
        /*送推播到指定user的裝置
        var userQuery = PFUser.query()!
        userQuery.whereKey("channels", containedIn: [groupChannel])
        
        var deviceQuery = PFInstallation.query()!
        deviceQuery.whereKey("user", matchesQuery: userQuery)
        deviceQuery.whereKey("user", notEqualTo: PFUser.currentUser()!)
        
        var push = PFPush()
        push.setQuery(deviceQuery)
        push.setData(data)
        push.sendPushInBackground()
        */
        
        //推播訊息
        //var pushQuery = PFInstallation.query()
        //pushQuery?.whereKey("deviceToken", notEqualTo: "\(Global.MyDeviceToken)")
        //pushQuery?.whereKey("channels", equalTo: groupChannel)
        
        
        
        //let users = userQuery?.findObjects()
        
        //                    var uuids = [String]()
        //
        //                    for user in users!{
        //                        let uuid = user["username"] as? String
        //                        if uuid != nil && uuid != Global.MyUUID{
        //                            uuids.append(GenerateUUIDChannel(uuid!))
        //                        }
        //                    }
        
        
        //pushQuery?.whereKey("channels", containedIn: uuids)
        
        
        
        //push.setChannel(Global.MyGroups[buttonIndex - 1].ChannelName)
        
        //push.setMessage("新照片通知")
    }
}

struct Person{
    var Name:String!
    var Number:String!
    var Face:UIImage!
    var IsNewFace:Bool!
}

struct Student{
    var ID:String!
    var Name:String!
    var Number:String!
}

