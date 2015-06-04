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
    
    internal enum SystemType:Int{
        case Bulletin,Library,Health
    }
    
    var _data:[IntegrateData]!
    
    var _queryConnector:Connector!
    
    var _childItems:[ChildItem]!
    
    var _currentChild:ChildItem?
    
    var _currentSystemType:SystemType!
    
    var childActionSheet:UIActionSheet!
    
    var _chartData = [String:Int]()
    
    let BulletinIcon = UIImage(named: "bulletin.png")
    let LibraryIcon = UIImage(named: "library.png")
    let HealthIcon = UIImage(named: "health.png")
    
    let ScreenWidth = UIScreen.mainScreen().bounds.size.width
    
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
    
    override func viewWillAppear(animated: Bool) {
        segment.enabled = true
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
        
        if self._data[indexPath.row].Title == "chart"{
            let cell = tableView.dequeueReusableCellWithIdentifier("analyticsCell") as! AnalyticsCell
            
            for sub in cell.contentView.subviews{
                sub.removeFromSuperview()
            }
            
            if self._data[indexPath.row].Type == "library"{
                
                var chartData = [CGPoint]()
                
                for index in 0...9{
                    chartData.append(CGPoint(x: index,y: 0))
                }
                
                for key in self._chartData{
                    chartData[key.0.toInt()!].y = CGFloat(key.1)
                }
                
                var dataItem: PDBarChartDataItem = PDBarChartDataItem()
                dataItem.xMax = 10
                dataItem.xInterval = 1
                dataItem.yMax = 100
                dataItem.yInterval = 50
                //dataItem.barPointArray = [CGPoint(x:1.0,y:100.0),CGPoint(x:9.0,y:90.0)]
                dataItem.barPointArray = chartData
                dataItem.xAxesDegreeTexts = ["總", "哲", "宗", "自", "應", "社", "中", "世", "語", "美"]
                dataItem.yAxesDegreeTexts = ["50","100"]
                
                let width = cell.contentView.frame.width
                let swidth = cell.contentView.frame.size.width
                let height = cell.contentView.frame.height
                let sheight = cell.contentView.frame.size.height
                
                var barChart: PDBarChart = PDBarChart(frame: CGRectMake(0, -40, ScreenWidth, 200), dataItem: dataItem)
                
                cell.contentView.addSubview(barChart)
                barChart.strokeChart()
            }
            else if self._data[indexPath.row].Type == "health"{
                var dataItem: PDLineChartDataItem = PDLineChartDataItem()
                dataItem.xMax = 6.0
                dataItem.xInterval = 1.0
                dataItem.yMax = 30.0
                dataItem.yInterval = 10.0
                dataItem.pointArray = [CGPoint(x: 1.0, y: CGFloat(arc4random_uniform(30))), CGPoint(x: 2.0, y: CGFloat(arc4random_uniform(30))), CGPoint(x: 3.0, y: CGFloat(arc4random_uniform(30))), CGPoint(x: 4.0, y:CGFloat(arc4random_uniform(30))), CGPoint(x: 5.0, y: CGFloat(arc4random_uniform(30))), CGPoint(x: 6.0, y: CGFloat(arc4random_uniform(30)))]
                dataItem.xAxesDegreeTexts = ["99", "100", "101", "102", "103", "104"]
                dataItem.yAxesDegreeTexts = ["10", "20", "30"]
                
                var lineChart: PDLineChart = PDLineChart(frame: CGRectMake(0, -40, ScreenWidth, 200), dataItem: dataItem)
                
                cell.contentView.addSubview(lineChart)
                lineChart.strokeChart()
            }
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("integrateCell") as! IntegrateCell
            
            let date = self._data[indexPath.row].Date
            
            if count(date) >= 10{
                cell.Date.text = (self._data[indexPath.row].Date as NSString).substringToIndex(10)
            }
            else{
                cell.Date.text = "error date time format"
            }
            
            switch self._data[indexPath.row].Type{
                
            case "bulletin":
                
                cell.icon.image = BulletinIcon
                cell.Content.text = self._data[indexPath.row].Title
                
            case "library":
                
                cell.icon.image = LibraryIcon
                cell.Content.text = "書籍名稱 : \(self._data[indexPath.row].Book)"
                
            default:
                
                cell.icon.image = HealthIcon
                cell.Content.text = self._data[indexPath.row].Title
                
            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if self._data[indexPath.row].Title == "chart"{
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if self._data[indexPath.row].Title == "chart"{
            return 150
        }
        
        return 80.0
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
            StudentIdNumber = "public"
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
                
                var data : IntegrateData = IntegrateData(Date: lastUpdate, Title: messageTitle, Content: messageContent, Type: systemType)
                data.LoadData(self._currentSystemType)
                
                self._data.append(data)
                
                //self._data.append(IntegrateData(Date: lastUpdate, Title: messageTitle, Content: messageContent, Type: systemType))
            }
            
            if self._currentSystemType != SystemType.Bulletin{
                
                self._chartData.removeAll(keepCapacity: false)
                
                for each in self._data{
                    var data : IntegrateData = each as IntegrateData
                    if data.Isbn != ""{
                        let key = (data.Isbn as NSString).substringToIndex(1)
                        
                        if self._chartData[key] == nil{
                            self._chartData[key] = 0
                        }
                        
                        self._chartData[key] = self._chartData[key]! + 1
                    }
                }
                
                self._data.insert(IntegrateData(Date: "", Title: "chart", Content: "有個圖", Type: systemType), atIndex: 0)
            }
            
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
    
}

class IntegrateData{
    
    var Date:String!
    var Title:String!
    var Content:String!
    var Type:String!
    var Book:String!
    var Isbn:String!
    
    init(Date:String?,Title:String?,Content:String?,Type:String?){
        self.Date = Date
        self.Title = Title == nil ? "" : Title
        self.Content = Content
        self.Type = Type
        self.Book = ""
        self.Isbn = ""
    }
    
    func LoadData(type:IntegrateViewCtrl.SystemType){
        
        switch type{
            
        case IntegrateViewCtrl.SystemType.Library:
            
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(Content.dataValue, options: nil, error: nil) as? NSDictionary{
                if let bookName = jsonResult["book"] as? String{
                    Book = bookName
                }
                
                if let bookNumber = jsonResult["isbm"] as? String{
                    Isbn = bookNumber
                }
            }
            
        default:
            println("load other type data")
        }
    }
}

struct ChildItem{
    var Id:String!
    var Name:String!
    var IdNumber:String!
}

