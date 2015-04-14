////
////  ViewController.swift
////
////  Copyright 2011-present Parse Inc. All rights reserved.
////
//
//import UIKit
//import Parse
//
//class oldLoginViewCtrl : UIViewController,UIWebViewDelegate,UIScrollViewDelegate {
//    
//    var _con:Connector!
//    
//    var isValidated = false
//    
//    @IBOutlet weak var webView: UIWebView!
//    
//    @IBOutlet weak var account: UITextField!
//    
//    @IBOutlet weak var password: UITextField!
//    
//    @IBOutlet weak var btnLogin: UIButton!
//    
//    @IBAction func btnClick(sender: AnyObject) {
//        
//        Global.Loading.showActivityIndicator(self.view)
//        
//        let aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        
//        dispatch_async(aQueue) { () -> Void in
//            self.LoginWithGreening()
//            
//            dispatch_async(dispatch_get_main_queue()){
//                Global.Loading.hideActivityIndicator(self.view)
//                
//                if self.isValidated{
//                    
//                    Keychain.save("account", data: self.account.text.dataValue)
//                    Keychain.save("password", data: self.password.text.dataValue)
//                    
//                    let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Main") as UIViewController
//                    self.presentViewController(nextView, animated: true, completion: nil)
//                }
//                else{
//                    let alert = UIAlertView()
//                    alert.title = "登入失敗"
//                    alert.message = "帳號密碼可能錯誤"
//                    alert.addButtonWithTitle("OK")
//                    alert.show()
//                }
//            }
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        if let accountValue = Keychain.load("account")?.stringValue{
//            if let passwordValue = Keychain.load("password")?.stringValue{
//                account.text = accountValue
//                password.text = passwordValue
//            }
//        }
//        
//        //處理事件
//        webView.delegate=self
//        
//        //禁止縮放
//        //webView.scrollView.delegate = self;
//        
//        //載入登入頁面
////        var target = "https://auth.ischool.com.tw/logout.php?next=oauth%2Fauthorize.php%3Fclient_id%3D8e306edeffab96c8bdc6c8635cd54b9e%26response_type%3Dcode%26state%3Dredirect_uri%253A%252F%26redirect_uri%3Dhttp%3A%2F%2Fblank%26lang%3Dzh-tw%26scope%3DUser.Mail%2CUser.BasicInfo"
//        var target = "https://auth.ischool.com.tw/logout.php?next=oauth%2Fauthorize.php%3Fclient_id%3D8e306edeffab96c8bdc6c8635cd54b9e%26response_type%3Dcode%26state%3Dredirect_uri%253A%252F%26redirect_uri%3Dhttp%3A%2F%2Fblank%26lang%3Dzh-tw"
//        var urlobj = NSURL(string: target)
//        var request = NSURLRequest(URL: urlobj!)
//        webView.loadRequest(request)
//        
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//    
//    func webView(webView: UIWebView, didFailLoadWithError error: NSError){
//        
//        if error.domain == "NSURLErrorDomain" && error.code == -1003{
//            if let url = error.userInfo?["NSErrorFailingURLStringKey"] as? String{
//                if let range = url.rangeOfString("http://blank/?state=redirect_uri%3A%2F&code="){
//                    var code = url
//                    code.removeRange(range)
//                    
//                    println(code)
//                    Auth(code)
//                }
//            }
//        }
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func RegisterGroup(con:Connector){
//        var response:AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
//        var error: NSErrorPointer = nil
//        
//        var request = NSMutableURLRequest()
//        
//        //request.URL = NSURL.URLWithString(self.getAuthUrl(type))
//        request.URL = NSURL(string: "http://dsns.1campus.net/\(con.AccessPoint)/sakura/GetMyGroup?stt=PassportAccessToken&AccessToken=\(con.AccessToken)")
//        
//        println(request.URL)
//        
//        // Sending Synchronous request using NSURLConnection
//        
//        var tokenData = NSURLConnection.sendSynchronousRequest(request,returningResponse: response, error: error)
//        //println(AccessToken)
//        
//        if error != nil
//        {
//            // You can handle error response here
//            println("Get AccessToken error: \(error)")
//        }
//        else
//        {
//            if let data = tokenData as NSData?{
//                
//                var register_groups = [GroupItem]()
//                
//                //println(tokenData)
//                var str = NSString(data: data, encoding: NSUTF8StringEncoding)
//                println(str)
//                
//                var xml = SWXMLHash.parse(data)
//                
//                for group in xml["Body"]["Group"]{
//                    if let groupId = group["GroupId"].element?.text{
//                        if let groupName = group["GroupName"].element?.text{
//                            
//                            var channelName = Global.GenerateChannelString(con.AccessPoint, groupId: groupId)
//                            
//                            var item = GroupItem(GroupId: groupId,GroupName: groupName,ChannelName: channelName)
//                            
//                            register_groups.append(item)
//                        }
//                    }
//                }
//                
//                if(register_groups.count > 0){
//                    
//                    let installation = PFInstallation.currentInstallation()
//                    
//                    installation.channels = [""]
//                    //installation.removeObject("xyz_abc", forKey: "channels")
//                    
//                    var channelList = [String]()
//                    
//                    for group in register_groups{
//                        channelList.append(group.ChannelName)
//                    }
//                    
//                    installation.addUniqueObjectsFromArray(channelList, forKey: "channels")
//                    installation.saveInBackground()
//                }
//                
//                Global.MyGroups = register_groups
//                
//                let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Main") as UIViewController
//                self.presentViewController(nextView, animated: true, completion: nil)
//            }
//        }
//    }
//    
//    func LoginWithGreening(){
//        _con = Connector(authUrl: "https://auth.ischool.com.tw/oauth/token.php", accessPoint: "https://auth.ischool.com.tw:8443/dsa/greening", contract: "user")
//        _con.ClientID = "5e89bdfbf971974e3b53312384c0013a"
//        _con.ClientSecret = "855b8e05afadc32a7a2ecbf0b09011422e5e84227feb5449b1ad60078771f979"
//        _con.UserName = self.account.text
//        _con.Password = self.password.text
//        
//        if _con.IsValidated("greening"){
//            
//            isValidated = true
//            
//            Global.connector = _con
//            
//            var cloneCon = _con.Clone()
//            cloneCon.AccessPoint = "demo.ischool.j"
//            
//            RegisterGroup(cloneCon)
//        }
//    }
//    
//    func Auth(code:String){
//        
//        var response:AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
//        var error: NSErrorPointer = nil
//        
//        var request = NSMutableURLRequest()
//        
//        //request.URL = NSURL.URLWithString(self.getAuthUrl(type))
//        var url = "https://auth.ischool.com.tw/oauth/token.php?client_id=8e306edeffab96c8bdc6c8635cd54b9e&client_secret=b6b23657bfc3fc7dbf1014712308b005cae629b62376fac5f5a01632df91574e&redirect_uri=http%3A%2F%2Fblank&code=\(code)&grant_type=authorization_code"
//        
//        //println(url)
//        
//        request.URL = NSURL(string: url)
//        
//        // Sending Synchronous request using NSURLConnection
//        
//        var tokenData = NSURLConnection.sendSynchronousRequest(request,returningResponse: response, error: error)
//        
//        //println(AccessToken)
//        
//        if error != nil
//        {
//            // You can handle error response here
//            println("Get AccessToken error: \(error)")
//        }
//        else
//        {
//            if let data = tokenData as NSData?{
//                println(NSString(data: data, encoding: NSUTF8StringEncoding))
//                var jsonResult = NSJSONSerialization.JSONObjectWithData(tokenData!, options: nil, error: nil) as NSDictionary!
//                println(jsonResult)
//                
//                //var wrapping_accessToken = jsonResult["access_token"] as String?
//                //var wrapping_refreashToken = jsonResult["refresh_token"] as String?
//                
//                if let accessToken = jsonResult["access_token"] as String?{
//                    //self.AccessToken = accessToken
//                    println(accessToken)
//                    
//                    _con = Connector(authUrl: "https://auth.ischool.com.tw/oauth/token.php", accessPoint: "demo.ischool.j", contract: "user")
//                    _con.AccessToken = accessToken
//                    
//                    RegisterGroup(_con)
//                }
//                
//                if let refreashToken = jsonResult["refresh_token"] as String?{
//                    //self.RefreshToken = refreashToken
//                    //println(self.RefreshToken)
//                    println(refreashToken)
//                }
//            }
//        }
//    }
//}
