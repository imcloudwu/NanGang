//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 04/09/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class LoginViewCtrl: UIViewController,UIWebViewDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var _con:Connector!
    var _registerGroups = [GroupItem]()
    var _dsnsList = [String:Bool]()
    
    //let target = "https://auth.ischool.com.tw/logout.php?next=oauth%2Fauthorize.php%3Fclient_id%3D8e306edeffab96c8bdc6c8635cd54b9e%26response_type%3Dcode%26state%3Dredirect_uri%253A%252F%26redirect_uri%3Dhttp%3A%2F%2Fblank%26lang%3Dzh-tw"
    
    //2015.05.04
    //let target = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=8e306edeffab96c8bdc6c8635cd54b9e&response_type=code&state=redirect_uri%3A%2F&redirect_uri=http://blank&lang=zh-tw&scope=User.Mail,User.BasicInfo,*:auth.guest,*:sakura#tologin"
    
    let target = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=8e306edeffab96c8bdc6c8635cd54b9e&response_type=code&state=redirect_uri%3A%2F&redirect_uri=http://blank&lang=zh-tw"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let GobackBtn =  UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: self, action: "GoBack")
        self.navigationItem.title = "登入"
        self.navigationItem.leftBarButtonItem = GobackBtn
        self.navigationItem.leftBarButtonItem?.enabled = false
        
        Global.LastNewsViewChanged = true
        Global.PreviewViewChanged = true
        
        Global.LoginInstance = self
        
        _con = Connector(authUrl: "https://auth.ischool.com.tw/oauth/token.php", accessPoint: "https://auth.ischool.com.tw:8443/dsa/greening", contract: "user")
        
        _con.ClientID = "8e306edeffab96c8bdc6c8635cd54b9e"
        _con.ClientSecret = "b6b23657bfc3fc7dbf1014712308b005cae629b62376fac5f5a01632df91574e"
        
        //處理事件
        webView.delegate=self
        
        //禁止縮放
        //webView.scrollView.delegate = self
        
        //var target = "https://auth.ischool.com.tw/logout.php?next=oauth%2Fauthorize.php%3Fclient_id%3D8e306edeffab96c8bdc6c8635cd54b9e%26response_type%3Dcode%26state%3Dredirect_uri%253A%252F%26redirect_uri%3Dhttp%3A%2F%2Fblank%26lang%3Dzh-tw%26scope%3DUser.Mail%2CUser.BasicInfo"
        
        if let refreshToken = Keychain.load("refreshToken")?.stringValue{
            Auth(ConnectType.RefreshToken, value: refreshToken)
        }
        else{
            showLoginView()
        }
        
    }
    
    func showLoginView(){
        //載入登入頁面
        var urlobj = NSURL(string: target)
        var request = NSURLRequest(URL: urlobj!)
        webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        if webView.canGoBack{
            self.navigationItem.leftBarButtonItem?.enabled = true
        }
        else{
            self.navigationItem.leftBarButtonItem?.enabled = false
        }
    }
    
    func GoBack(){
        if self.webView.canGoBack{
            self.webView.goBack()
        }
        else{
            self.navigationItem.leftBarButtonItem?.enabled = false
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError){
        
        //取得code
        if error.domain == "NSURLErrorDomain" && error.code == -1003{
            if let url = error.userInfo?["NSErrorFailingURLStringKey"] as? String{
                if let range = url.rangeOfString("http://blank/?state=redirect_uri%3A%2F&code="){
                    var code = url
                    code.removeRange(range)
                    
                    //println(code)
                    Auth(ConnectType.Code,value: code)
                }
            }
        }
    }
    
    func Auth(type:ConnectType,value:String){
        
        Global.Loading.showActivityIndicator(self.view)
        
        if type == ConnectType.Code{
            _con.Code = value
        }
        else if type == ConnectType.RefreshToken{
            _con.RefreshToken = value
        }
        
        if !_con.GetAccessToken(type){
            showLoginView()
            Global.Loading.hideActivityIndicator(self.view)
            return
        }
        
        _con.GetSessionID()
        
        Global.connector = _con
        
        Keychain.save("refreshToken", data: _con.RefreshToken.dataValue)
        
        GetDSNSList(self)
        
        //        _con.GetAccessToken("Code")
        //        _con.GetSessionID()
    }
    
    func GetDSNSList(sender:UIViewController){
        
        Global.Loading.showActivityIndicator(sender.view)
        
        //清空DSNS清單
        _dsnsList.removeAll(keepCapacity: false)
        //清空準備要註冊的頻道
        _registerGroups.removeAll(keepCapacity: false)
        
        //取得DSNS清單
        _con.SendRequest("GetApplicationListRef", body: "<Request><Type>dynpkg</Type></Request>") { (response) -> () in
            //println(NSString(data: response, encoding: NSUTF8StringEncoding))
            var xml = SWXMLHash.parse(response)
            
            //User
            for elem in xml["Envelope"]["Body"]["Response"]["User"]["App"]{
                if let dsns = elem.element?.attributes["AccessPoint"]{
                    self._dsnsList[dsns] = false
                }
            }
            
            //Domain
            for elem in xml["Envelope"]["Body"]["Response"]["Domain"]["App"]{
                if let dsns = elem.element?.attributes["AccessPoint"]{
                    self._dsnsList[dsns] = false
                }
            }
            
            for dsns in self._dsnsList{
                var con = self._con.Clone()
                con.DSNS = dsns.0
                
                con.SetAccessPointWithCallback({ () -> () in
                    
                    //取得群組
                    self.GetMyGroup(con, complete: { () -> () in
                        
                        //callback有回來就設定為完成
                        self._dsnsList[con.DSNS] = true
                        
                        self.MoveToNextView(sender)
                    })
                })
            }
            
            if self._dsnsList.count == 0{
                self.MoveToNextView(sender)
            }
        }
    }
    
    func GetMyGroup(con:Connector,complete:() -> ()){
        
        HttpClient.Get("http://dsns.1campus.net/\(con.DSNS)/sakura/GetMyGroup?stt=PassportAccessToken&AccessToken=\(con.AccessToken)"){ (nsData) -> () in
            
            //println("=======\(con.DSNS)======")
            //println(NSString(data: nsData, encoding: NSUTF8StringEncoding))
            
            if let data = nsData as NSData?{
                
                var xml = SWXMLHash.parse(data)
                
                //不支援的DSNS在這邊就不會繼續做下去
                for group in xml["Body"]["Group"]{
                    
                    let groupDSNS = con.DSNS
                    let groupId = group["GroupId"].element?.text
                    let groupName = group["GroupName"].element?.text
                    let isTeacher = group["IsTeacher"].element?.text == "true" ? true : false
                    
                    var channelName = GenerateChannelString(groupDSNS, groupId)
                    
                    var item = GroupItem(connector: con,GroupId: groupId, GroupName: groupName, ChannelName: channelName, IsTeacher: isTeacher)
                    
                    self._registerGroups.append(item)
                }
            }
            
            complete()
        }
        
    }
    
    //註冊推播頻道
    func RegisterGroup(callback:() -> ()){
        
        HttpClient.Get("https://auth.ischool.com.tw/services/me2.php?access_token=\(_con.AccessToken)", callback: { (data) -> () in
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! NSDictionary!
            
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            
            if let uuid = jsonResult["uuid"] as? String {
                if let email = jsonResult["userID"] as? String {
                    //Global.MyUUID = uuid
                    //Global.MyEmail = email
                    
                    //嘗試登入使用者
                    PFUser.logInWithUsernameInBackground(uuid, password: "", block: { (user, error) -> Void in
                        
                        //未註冊的話
                        if user == nil{
                            let newUser = PFUser()
                            newUser.username = uuid
                            newUser.password = ""
                            newUser.email = email
                            
                            //註冊新使用者
                            newUser.signUp()
                        }
                        
                        //成功登入後已不為nil
                        let currentUser = PFUser.currentUser()
                        //user可能會換email,所以每次登入都覆寫email
                        currentUser?.email = email
                        
                        //準備訂閱的頻道
                        var channels = [String]()
                        
                        if(self._registerGroups.count > 0){
                            
                            for group in self._registerGroups{
                                if !contains(channels,group.ChannelName){
                                    channels.append(group.ChannelName)
                                }
                            }
                        }
                        
                        currentUser?.setObject(channels, forKey: "channels")
                        
                        currentUser?.saveInBackground()
                        
                        //Device紀錄使用者
                        let installation = PFInstallation.currentInstallation()
                        
                        installation["user"] = currentUser
                        
                        installation.saveInBackground()
                        
                        //呼叫回調
                        callback()
                    })
                }
            }
        })
    }
    
    func MoveToNextView(sender:UIViewController){
        
        var complete = true
        
        //println(self._dsnsList)
        
        for dsns in self._dsnsList{
            if !dsns.1{
                complete = false
            }
        }
        
        //等全部的DSNS訪問都回來後執行
        if complete{
            
            RegisterGroup({ () -> () in
                Global.DSNSList = self._dsnsList
                Global.MyGroups = self._registerGroups
                
                Global.Loading.hideActivityIndicator(sender.view)
                
                if sender == self{
                    let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Main") as! UIViewController
                    self.presentViewController(nextView, animated: true, completion: nil)
                    
                }
                else{
                    Global.LastNewsViewChanged = true
                    Global.PreviewViewChanged = true
                    sender.navigationController?.popViewControllerAnimated(true)
                }
            })
        }
    }
    
}

