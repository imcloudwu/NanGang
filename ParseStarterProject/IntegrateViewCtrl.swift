//
//  IntegrateViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 5/7/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 04/09/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class IntegrateViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIActionSheetDelegate {
    
    enum SystemType:Int{
        case Bulletin,Library,Health
    }
    
    var _data:[IntegrateData]!
    
    var _queryConnector:Connector!
    
    var _childItems:[ChildItem]!
    
    var _currentChild:ChildItem?
    
    var _currentSystemType:SystemType!
    
    var childActionSheet:UIActionSheet!
    
    @IBOutlet weak var childLabel: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func segment_select(sender: AnyObject) {
        if segment.selectedSegmentIndex == 0{
            _currentSystemType = SystemType.Bulletin
        }
        else if segment.selectedSegmentIndex == 1{
            _currentSystemType = SystemType.Library
        }
        else if segment.selectedSegmentIndex == 2{
            _currentSystemType = SystemType.Health
        }
        
        GetData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _data = [IntegrateData]()
        _childItems = [ChildItem]()
        
        Global.IntegrateMain.tabBarItem.badgeValue = nil
        self.navigationItem.title = "整合服務"
        //self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        //self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        
        let changeUserBtn = UIBarButtonItem(title: " ", style: UIBarButtonItemStyle.Plain, target: self, action: "changeUser")
        changeUserBtn.image = UIImage(named: "Change User-25.png")
        self.navigationItem.rightBarButtonItem  = changeUserBtn
        
        self.childActionSheet = UIActionSheet(title: "請選擇小孩", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        ConnectorInit({ () -> () in
            self.GetChildItem()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ConnectorInit(completed:() -> ()){
        
        Global.Loading.showActivityIndicator(self.view)
        
        _queryConnector = Global.connector.Clone()
        
        //南港專用
        HttpClient.Get(GetDoorWayURL("nkps.tp.edu.tw"), callback: { (data) -> () in
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            var xml = SWXMLHash.parse(data)
            
            if let url = xml["Envelope"]["Body"]["DoorwayURL"].element?.text{
                self._queryConnector.AccessPoint = url
            }
            
            self._queryConnector.Contract = "QueryNotification.Parent"
            self._queryConnector.GetSessionID()
            
            Global.Loading.hideActivityIndicator(self.view)
            
            completed()
        })
    }
    
    func GetChildItem(){
        
        _currentChild = nil
        _childItems.removeAll(keepCapacity: false)
        childActionSheet = UIActionSheet(title: "請選擇小孩", delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
        
        var con = self._queryConnector.Clone()
        con.Contract = "iLink.Parent"
        con.GetSessionID()
        
        con.SendRequest("GetMyChildren", body: "", function: { (response) -> () in
            //println(NSString(data: response, encoding: NSUTF8StringEncoding))
            
            var xml = SWXMLHash.parse(response)
            
            for student in xml["Envelope"]["Body"]["Response"]["Student"]{
                let id = student["Id"].element?.text
                let name = student["Name"].element?.text
                let id_number = student["IdNumber"].element?.text
                
                self._childItems.append(ChildItem(Id: id, Name: name, IdNumber: id_number))
            }
            
            for child in self._childItems{
                self.childActionSheet.addButtonWithTitle(child.Name)
            }
            
            if self._childItems.count > 0{
                self._currentChild = self._childItems[0]
                self.childLabel.text = self._currentChild?.Name
            }
            
            self.segment_select(self)
            
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self._data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        if self._data[indexPath.row].Type == "這是分析圖"{
            let cell = tableView.dequeueReusableCellWithIdentifier("analyticsCell") as! AnalyticsCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("integrateCell") as! IntegrateCell
        
        let date = self._data[indexPath.row].Date
        
        if count(date) >= 10{
            cell.Datetime.text = (self._data[indexPath.row].Date as NSString).substringToIndex(10)
        }
        else{
            cell.Datetime.text = "error date time format"
        }
        
        cell.Title.text = self._data[indexPath.row].Title
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if self._data[indexPath.row].Type == "這是分析圖"{
            //nothing here now...
            println("nothing here now...")
        }
        else if _currentSystemType == SystemType.Library{
            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("IntegrateDetail") as! IntegrateDetailViewCtrl
            nextView.date = self._data[indexPath.row].Date
            nextView.type = self._data[indexPath.row].Type
            nextView.content = self._data[indexPath.row].Content
            
            self.navigationController?.pushViewController(nextView, animated: true)
        }
        else{
            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("IntegrateBrowser") as! IntegrateBrowserCtrl
            nextView.content = self._data[indexPath.row].Content
            
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func GetData(){
        
        Global.Loading.showActivityIndicator(self.view)
        
        _data.removeAll(keepCapacity: false)
        
        var StudentIdNumber = ""
        var systemType = ""
        
        if let studentIdNumber = _currentChild?.IdNumber{
            StudentIdNumber = studentIdNumber
        }
        
        if _currentSystemType == SystemType.Bulletin{
            systemType = "bulletin"
        }
        else if _currentSystemType == SystemType.Library{
            systemType = "library"
        }
        else if _currentSystemType == SystemType.Health{
            systemType = "health"
        }
        
        _queryConnector.SendRequest("Query", body: "<Request><Condition><StudentIdNumber>\(StudentIdNumber)</StudentIdNumber><SystemType>\(systemType)</SystemType></Condition></Request>", function: { (response) -> () in
            //println(NSString(data: response, encoding: NSUTF8StringEncoding))
            
            var xml = SWXMLHash.parse(response)
            
            for elem in xml["Envelope"]["Body"]["Response"]["Pushnotification.content"]{
                let lastUpdate = elem["LastUpdate"].element?.text
                let systemType = elem["SystemType"].element?.text
                let messageContent = elem["MessageContent"].element?.text
                let messageTitle = elem["MessageTitle"].element?.text
                
                self._data.append(IntegrateData(Date: lastUpdate, Title: messageTitle, Content: messageContent, Type: systemType))
            }
            
            self._data.insert(IntegrateData(Date: "", Title: "分析圖", Content: "有個圖", Type: "這是分析圖"), atIndex: 0)
            
            self.tableView.reloadData()
            
            Global.Loading.hideActivityIndicator(self.view)
        })
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView){
        segment.enabled = false
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool){
        if decelerate{
            segment.enabled = false
        }
        else{
            segment.enabled = true
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        segment.enabled = true
    }
    
    func changeUser(){
        childActionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex > 0{
            let index = buttonIndex - 1
            _currentChild = _childItems[index]
            childLabel.text = _currentChild?.Name
            segment_select(self)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if self._data[indexPath.row].Type == "這是分析圖"{
            return 167.0
        }
        
        return 67.0
    }
}

struct IntegrateData{
    var Date:String!
    var Title:String!
    var Content:String!
    var Type:String!
}

struct ChildItem{
    var Id:String!
    var Name:String!
    var IdNumber:String!
}

