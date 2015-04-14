//
//  KeyinViewCtrl.swift
//  oneAdminParent
//
//  Created by Cloud on 11/24/14.
//  Copyright (c) 2014 ischool. All rights reserved.
//

import UIKit

class KeyinViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate {
    
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
        
        server.delegate = self
        code.delegate = self
        relationship.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        self.view.endEditing(true)
        
        if autoView.hidden == false{
            autoView.hidden = true
        }
        
        return true
    }
    
    // called when screen touch
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent){
        self.view.endEditing(true)
        if autoView.hidden == false{
            autoView.hidden = true
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        if textField == server{
            if string != "" && !isBusy{
                isBusy = true
                self.search()
            }
        }
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _display.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "auto")
        cell.textLabel?.text = _display[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        autoView.hidden = true
        server.text = _display[indexPath.row]
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        Global.LoginInstance.GetDSNSList(self)
    }
    
    func search() {
        
        _con.AccessPoint = "http://dsns.ischool.com.tw/dsns/dsns"
        _con.Contract = "dsns"
        
        _con.SendRequestWithPublic("DS.NameService.GetTop10", body: "<a>\(self.server.text)</a>"){ data in
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            self._DSNSDic.removeAll(keepCapacity: false)
            
            self._display.removeAll(keepCapacity: false)
            
            var xml = SWXMLHash.parse(data)
            for app in xml["Envelope"]["Body"]["Response"]["Application"] {
                if let dsns = app.element?.attributes["Name"]{
                    
                    if dsns.hasPrefix("ta."){
                        continue;
                    }else if dsns.hasPrefix("sa."){
                        continue;
                    }
                    
                    if let cdata = app.element?.text {
                        var temp = SWXMLHash.parse(cdata)
                        
                        for title in temp["StructMemo"]["Title"]{
                            if let name = title.element?.text{
                                self._DSNSDic[name] = dsns
                            }
                        }
                    }
                }
            }
            
            for dsns in self._DSNSDic{
                self._display.append(dsns.0)
            }
            
            if self._display.count > 0{
                self.autoView.reloadData()
                self.autoView.hidden = false
            }
            else{
                self.autoView.hidden = true
            }
            
            self.isBusy = false
        }
    }
    
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
                        var str = NSString(data: response, encoding: NSUTF8StringEncoding)
                        //println(str)
                        
                        var xml = SWXMLHash.parse(response)
                        var success = false
                        
                        for elem in xml["Envelope"]["Body"]["Success"]{
                            success = true
                        }
                        
                        if success{
                            let alert = UIAlertView()
                            alert.delegate = self
                            alert.title = "系統提示"
                            alert.message = "加入成功"
                            alert.addButtonWithTitle("OK")
                            alert.show()
                        }
                        else{
                            let alert = UIAlertView()
                            alert.title = "系統提示"
                            alert.message = "加入失敗"
                            alert.addButtonWithTitle("OK")
                            alert.show()
                        }
                        
                        //                        println(Global.ChildList)
                        //                        self.dismissViewControllerAnimated(false, completion: nil)
                    }
                }
                else{
                    let alert = UIAlertView()
                    alert.title = "呼叫伺服器錯誤"
                    alert.message = "連線異常或者伺服器名稱不正確"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }
        }
    }
}