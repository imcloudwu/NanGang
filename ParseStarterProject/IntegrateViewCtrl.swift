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

class IntegrateViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var _data:[IntegrateData]!
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func segment_select(sender: AnyObject) {
        if segment.selectedSegmentIndex == 0{
            self._data.removeAll(keepCapacity: false)
            self.tableView.reloadData()
        }
        else if segment.selectedSegmentIndex == 1{
            GetData("library")
        }
        else if segment.selectedSegmentIndex == 2{
            GetData("health")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _data = [IntegrateData]()
        
        Global.IntegrateMain.tabBarItem.badgeValue = nil
        self.navigationItem.title = "整合服務"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        segment_select(self)
        
        //self.navigationController?.tabBarItem.title = "系統整合"
        //self.navigationController?.tabBarItem.badgeValue = "999"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self._data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
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
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("IntegrateDetail") as! IntegrateDetailViewCtrl
        nextView.date = self._data[indexPath.row].Date
        nextView.type = self._data[indexPath.row].Type
        nextView.content = self._data[indexPath.row].Content
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func GetData(type:String){
        
        Global.Loading.showActivityIndicator(self.view)
        
        _data.removeAll(keepCapacity: false)
        
        var con = Global.connector.Clone()
        
        HttpClient.Get(GetDoorWayURL("nkps.tp.edu.tw"), callback: { (data) -> () in
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            var xml = SWXMLHash.parse(data)
            
            if let url = xml["Envelope"]["Body"]["DoorwayURL"].element?.text{
                con.AccessPoint = url
            }
            
            con.GetSessionID()
            
            con.Contract = "QueryNotification.Parent"
            
            con.SendRequest("Query", body: "<Request><Condition><SystemType>\(type)</SystemType></Condition></Request>", function: { (response) -> () in
                //println(NSString(data: response, encoding: NSUTF8StringEncoding))
                
                xml = SWXMLHash.parse(response)
                
                for elem in xml["Envelope"]["Body"]["Response"]["Pushnotification.content"]{
                    let lastUpdate = elem["LastUpdate"].element?.text
                    let systemType = elem["SystemType"].element?.text
                    let messageContent = elem["MessageContent"].element?.text
                    let messageTitle = elem["MessageTitle"].element?.text
                    
                    self._data.append(IntegrateData(Date: lastUpdate, Title: messageTitle, Content: messageContent, Type: systemType))
                }
                
                self.tableView.reloadData()
                
                Global.Loading.hideActivityIndicator(self.view)
            })
        })
    }
}

struct IntegrateData{
    var Date:String!
    var Title:String!
    var Content:String!
    var Type:String!
}

