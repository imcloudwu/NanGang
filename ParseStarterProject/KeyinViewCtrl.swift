//
//  KeyinViewCtrl.swift
//  oneAdminParent
//
//  Created by Cloud on 11/24/14.
//  Copyright (c) 2014 ischool. All rights reserved.
//

import UIKit

class KeyinViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate {
    
    var _DSNSDic:Dictionary<String,String>!
    var _display:[String]!
    
    var _con:Connector!
    
    var isBusy = false
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var autoView: UITableView!
    @IBOutlet weak var server: UITextField!
    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var relationship: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _con = Global.connector.Clone()
        
        _DSNSDic = Dictionary<String,String>()
        _display = [String]()
        
        //Global.AdjustView(contentView)
        
        submitBtn.layer.cornerRadius = 5
        
        autoView.delegate = self
        autoView.dataSource = self
        autoView.hidden = true
        
        //server.delegate = self
        //code.delegate = self
        //relationship.delegate = self
        
        server.addTarget(self, action: "GetServerName", forControlEvents: UIControlEvents.EditingChanged)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func GetServerName(){
        let mark = self.server.markedTextRange
        if mark == nil && !isBusy{
            isBusy = true
            let serverName = self.server.text.UrlEncoding
            newSearch(serverName!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        
        if autoView.hidden == false{
            autoView.hidden = true
        }
        
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
        if autoView.hidden == false{
            autoView.hidden = true
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _display.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "auto")
        cell.textLabel?.text = _display[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        autoView.hidden = true
        server.text = _display[indexPath.row]
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        //Global.LoginInstance.GetDSNSList(self)
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("loginView") as! UIViewController
        self.presentViewController(nextView, animated: true, completion: nil)
    }
    
    func newSearch(matchName:String){
        
            HttpClient.Get("http://dsns.1campus.net/campusman.ischool.com.tw/config.public/GetSchoolList?content=%3CRequest%3E%3CMatch%3E\(matchName)%3C/Match%3E%3CPagination%3E%3CPageSize%3E10%3C/PageSize%3E%3CStartPage%3E1%3C/StartPage%3E%3C/Pagination%3E%3C/Request%3E", callback: { (data) -> () in
                
                self._DSNSDic.removeAll(keepCapacity: false)
                
                self._display.removeAll(keepCapacity: false)
                
                var xml = SWXMLHash.parse(data)
                for school in xml["Body"]["Response"]["School"] {
                    
                    if let title = school["Title"].element?.text{
                        if let dsns = school["DSNS"].element?.text{
                            self._DSNSDic[title] = dsns
                        }
                    }
                }
                
                self._display = self._DSNSDic.keys.array
                
                if self._display.count > 0{
                    self.autoView.reloadData()
                    self.autoView.hidden = false
                }
                else{
                    self.autoView.hidden = true
                }
                
                self.isBusy = false
            })
    }
    
//    func search(matchName:String) {
//        
//        _con.AccessPoint = "http://dsns.ischool.com.tw/dsns/dsns"
//        _con.Contract = "dsns"
//        
//        _con.SendRequestWithPublic("DS.NameService.GetTop10", body: "<a>\(matchName)</a>"){ data in
//            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
//            
//            self._DSNSDic.removeAll(keepCapacity: false)
//            
//            self._display.removeAll(keepCapacity: false)
//            
//            var xml = SWXMLHash.parse(data)
//            for app in xml["Envelope"]["Body"]["Response"]["Application"] {
//                if let dsns = app.element?.attributes["Name"]{
//                    
//                    if dsns.hasPrefix("ta."){
//                        continue;
//                    }else if dsns.hasPrefix("sa."){
//                        continue;
//                    }
//                    
//                    if let cdata = app.element?.text {
//                        var temp = SWXMLHash.parse(cdata)
//                        
//                        for title in temp["StructMemo"]["Title"]{
//                            if let name = title.element?.text{
//                                self._DSNSDic[name] = dsns
//                            }
//                        }
//                    }
//                }
//            }
//            
//            for dsns in self._DSNSDic{
//                self._display.append(dsns.0)
//            }
//            
//            if self._display.count > 0{
//                self.autoView.reloadData()
//                self.autoView.hidden = false
//            }
//            else{
//                self.autoView.hidden = true
//            }
//            
//            self.isBusy = false
//        }
//    }
    
    @IBAction func submit(sender: AnyObject) {
        
        var serverName = ""
        
        if let dsns = _DSNSDic[server.text]{
            serverName = dsns
        }
        else{
            serverName = server.text
        }
        
        //println(Global.ChildList)
        var con = Global.connector.Clone()
        
        //Join Domain List
        if !contains(Global.DSNSList.keys,serverName){
            con.Contract = "user"
            con.SendRequest("AddApplicationRef", body: "<Request><Applications><Application><AccessPoint>\(serverName)</AccessPoint><Type>dynpkg</Type></Application></Applications></Request>"){ resp in
                //println(NSString(data: resp, encoding: NSUTF8StringEncoding))
            }
        }
        
        HttpClient.Get(GetDoorWayURL(serverName)){data in
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var xml = SWXMLHash.parse(data)
            for elem in xml["Envelope"]["Body"]["DoorwayURL"]{
                if let DoorwayURL = elem.element?.text{
                    //println(DoorwayURL)
                    con.AccessPoint = DoorwayURL
                    con.Contract = "auth.guest"
                    con.GetSessionID()
                    
                    con.SendRequest("Join.AsParent", body: "<Request><ParentCode>\(self.code.text)</ParentCode><Relationship>\(self.relationship.text)</Relationship></Request>") { (response) -> () in
                        //var str = NSString(data: response, encoding: NSUTF8StringEncoding)
                        //println(str)
                        
                        var xml = SWXMLHash.parse(response)
                        var success = false
                        
                        for elem in xml["Envelope"]["Body"]["Success"]{
                            success = true
                        }
                        
                        if success{
                            let alert = UIAlertView()
                            alert.delegate = self
                            //alert.title = "系統提示"
                            alert.message = "加入成功"
                            alert.addButtonWithTitle("OK")
                            alert.show()
                        }
                        else{
                            
                            let errorMsg = xml["Envelope"]["Header"]["Status"]["Message"].element?.text
                            let alert = UIAlertView()
                            //alert.title = "系統提示"
                            alert.message = "加入失敗:\(errorMsg!)"
                            alert.addButtonWithTitle("OK")
                            alert.show()
                        }
                        
                        //                        println(Global.ChildList)
                        //                        self.dismissViewControllerAnimated(false, completion: nil)
                    }
                }
                else{
                    let alert = UIAlertView()
                    //alert.title = "呼叫伺服器錯誤"
                    alert.message = "連線異常或者伺服器名稱不正確"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }
        }
    }
}