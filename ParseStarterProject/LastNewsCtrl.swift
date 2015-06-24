//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 04/09/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class LastNewsCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate {
    
    var _data = [NewsObj]()
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = "最新動態"
        
        let logoutBtn = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: self, action: "AskForLogout")
        logoutBtn.image = UIImage(named: "Exit-25.png")
        self.navigationItem.rightBarButtonItem  = logoutBtn
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "Refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if Global.Installation.badge != 0 || Global.LastNewsViewChanged{
            Global.Installation.badge = 0
            Global.Installation.saveEventually()
            Global.LastNewsViewChanged = false
            Refresh()
        }
        
        Global.SetCallback { () -> () in
            Global.PreviewViewChanged = true
            self.Refresh()
        }
    }
    
    func AskForLogout(){
        
        let confirmAlert = UIAlertView()
        //confirmAlert.title = "系統訊息"
        confirmAlert.message = "確認要登出？"
        confirmAlert.addButtonWithTitle("確認")
        confirmAlert.addButtonWithTitle("取消")
        confirmAlert.delegate = self
        confirmAlert.show()
        
    }
    
    func Logout(){
        
        var storage : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies as! [NSHTTPCookie]
        {
            storage.deleteCookie(cookie)
        }
        NSUserDefaults.standardUserDefaults()
        
//        HttpClient.Get(GetLogoutUrl("Greening")) { (data) -> () in
//            println("Greening logout")
//        }
//        
//        HttpClient.Get(GetLogoutUrl("Google")) { (data) -> () in
//            println("Google logout")
//        }
//        
        Keychain.delete("refreshToken")
        
        let installation = PFInstallation.currentInstallation()
        installation.removeObjectForKey("user")
        installation.saveInBackground()
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("loginView") as! UIViewController
        self.presentViewController(nextView, animated: true, completion: nil)
    }
    
    func Refresh(){
        
        Global.Loading.showActivityIndicator(self.view)
        
        var query = PFQuery(className: "PhotoData")
        
        var myChannelList = [String]()
        
        for group in Global.MyGroups{
            myChannelList.append(group.ChannelName)
        }
        
        query.whereKey("channel",containedIn: myChannelList)
        //昨天以後
        //query.whereKey("createdAt", greaterThan: before_today)
        //今天以前
        //query.whereKey("createdAt", lessThan: today)
        
        query.orderByDescending("createdAt")
        query.limit = 10
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            self._data.removeAll(keepCapacity: false)
            
            let array = objects as! [PFObject]
            
            //loop結果
            for object in array{
                
                let date:NSDate = object.createdAt!
                
                //println(date)
                
                let id = object.objectId
                let groupName = object["group"] as! String
                let comment = object["comment"] as! String
                //將pffile轉成image
                let file = object["preview"] as! PFFile
                
                var imgData = file.getData()
                
                if let img = UIImage(data: imgData!){
                    self._data.append(NewsObj(ID: id!, Group: groupName, Comment: comment, Image: img,Date: date))
                }
            }
            
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            Global.Loading.hideActivityIndicator(self.view)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("lastNewsCell") as! LastNewsCell
        cell.ImageView.image = _data[indexPath.row].Image
        cell.GroupName.text = "來自 \(_data[indexPath.row].Group) 群組的相片         \(_data[indexPath.row].Date.stringValue)"
        cell.Comment.text = _data[indexPath.row].Comment
        cell.Icon.hidden = _data[indexPath.row].Comment == ""
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        var dataArray = [String]()
        
        for item in _data{
            dataArray.append(item.ID)
        }
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Detail") as! DetailViewCtrl
        nextView._SelectPicId = _data[indexPath.row].ID
        nextView._currentIndex = indexPath.row
        nextView._DataArray = dataArray
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
        if alertView.buttonTitleAtIndex(buttonIndex) == "確認"{
            Logout()
        }
    }
}

struct NewsObj{
    var ID:String
    var Group:String
    var Comment:String
    var Image:UIImage
    var Date:NSDate
}

