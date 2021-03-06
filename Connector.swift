//
//  Connector.swift
//  App
//
//  Created by Cloud on 10/8/14.
//  Copyright (c) 2014 Cloud. All rights reserved.
//

import Foundation

public enum ConnectType: Int {
    case Facebook,Code,RefreshToken
}

public class Connector{
    
    var AccessToken:String!
    var RefreshToken:String!
    var SessionID:String!
    var ClientID:String!
    var ClientSecret:String!
    var UserName:String!
    var Password:String!
    var AccessPoint:String!
    var Contract:String!
    var FBToken:String!
    var Code:String!
    var DSNS:String!
    var AuthUrl:String!
    
    init(authUrl:String,accessPoint:String,contract:String){
        AuthUrl = authUrl
        AccessPoint = accessPoint
        Contract = contract
    }
    
    public func Clone() -> Connector{
        var con = Connector(authUrl: AuthUrl,accessPoint: AccessPoint,contract: Contract)
        con.AccessToken = AccessToken
        con.RefreshToken = RefreshToken
        con.SessionID = SessionID
        con.ClientID = ClientID
        con.ClientSecret = ClientSecret
        con.UserName = UserName
        con.Password = Password
        con.AccessPoint = AccessPoint
        con.Contract = Contract
        con.DSNS = DSNS
        return con
    }
    
    //取得DSNS的url
    func SetAccessPointWithCallback(callback:() -> ()){
        HttpClient.Get(GetDoorWayURL(DSNS)){data in
            var xml = SWXMLHash.parse(data)
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            for elem in xml["Envelope"]["Body"]["DoorwayURL"]{
                if let DoorwayURL = elem.element?.text{
                    self.AccessPoint = DoorwayURL
                    callback()
                }
            }
        }
    }
    
    private func GetDoorWayURL(dsns:String) -> String{
        return "http://dsns.ischool.com.tw/dsns/dsns/DS.NameService.GetDoorwayURL?content=%3Ca%3E\(dsns)%3C/a%3E"
    }
    
    private func getAuthUrl(type:ConnectType) -> String {
        if type == ConnectType.Facebook {
            return "https://auth.ischool.com.tw/c/servicem/fbtoken.php?fbtoken=\(FBToken)&client_id=\(ClientID)&client_secret=\(ClientSecret)"
        }
        else if type == ConnectType.Code {
            return "\(AuthUrl)?client_id=\(ClientID)&client_secret=\(ClientSecret)&redirect_uri=http%3A%2F%2Fblank&code=\(Code)&grant_type=authorization_code"
        }
        else if type == ConnectType.RefreshToken {
            return "\(AuthUrl)?client_id=\(ClientID)&client_secret=\(ClientSecret)&redirect_uri=http%3A%2F%2Fblank&code=\(Code)&refresh_token=\(RefreshToken)&grant_type=refresh_token"
        }
        else{
            return "\(AuthUrl)?grant_type=password&client_id=\(ClientID)&client_secret=\(ClientSecret)&username=\(UserName)&password=\(Password)"
        }
    }
    
    func SendRequest(service:String,body:String,function:(response:NSData) -> ()){
        
        if SessionID == nil {
            GetSessionID()
        }
        
        if SessionID == nil{
            function(response: NSData())
        }
        else{
            
            var httpBody = "<Envelope><Header><TargetContract>\(self.Contract)</TargetContract><TargetService>\(service)</TargetService><SecurityToken Type='Session'><SessionID>\(self.SessionID)</SessionID></SecurityToken></Header><Body>\(body)</Body></Envelope>"
            
            HttpClient.POST(self.AccessPoint, body: httpBody, callback: { data in
                function(response: data)
            })
        }
    }
    
    func SendRequestWithPublic(service:String,body:String,function:(response:NSData) -> ()){
        
        //<TargetContract>\(self.Contract)</TargetContract>
        var httpBody = "<Envelope><Header><SecurityToken Type='Public'/><TargetService>\(service)</TargetService></Header><Body>\(body)</Body></Envelope>"
        
        HttpClient.POST(self.AccessPoint, body: httpBody, callback: { data in
            function(response: data)
        })
    }
    
    /*
    func IsValidated(type:ConnectType) -> Bool {
    GetAccessToken(type)
    GetSessionID()
    
    if self.SessionID == nil{
    //println("SessionID is nil")
    return false
    }
    else{
    //println("SessionID is not nil")
    return true
    }
    }
    */
    
    public func GetAccessToken(type:ConnectType) -> Bool {
        
        let url = self.getAuthUrl(type)
        self.AccessToken = nil
        self.RefreshToken = nil
        
        var response:AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var error: NSErrorPointer = nil
        
        var request = NSMutableURLRequest()
        
        //request.URL = NSURL.URLWithString(self.getAuthUrl(type))
        request.URL = NSURL(string: url)
        
        // Sending Synchronous request using NSURLConnection
        
        var tokenData = NSURLConnection.sendSynchronousRequest(request,returningResponse: response, error: error)
        
        //println(AccessToken)
        
        if error != nil
        {
            // You can handle error response here
            println("Get AccessToken error: \(error)")
        }
        else
        {
            if let data = tokenData as NSData?{
                //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                var jsonResult = NSJSONSerialization.JSONObjectWithData(tokenData!, options: nil, error: nil) as! NSDictionary!
                //println(jsonResult)
                
                //var wrapping_accessToken = jsonResult["access_token"] as String?
                //var wrapping_refreashToken = jsonResult["refresh_token"] as String?
                
                if let accessToken = jsonResult["access_token"] as? String{
                    self.AccessToken = accessToken
                    //println(self.AccessToken)
                }
                
                if let refreashToken = jsonResult["refresh_token"] as? String{
                    self.RefreshToken = refreashToken
                    //println(self.RefreshToken)
                }
            }
        }
        
        if self.AccessToken != nil && self.RefreshToken != nil{
            return true
        }
        else{
            return false
        }
    }
    
    public func GetSessionID() -> Bool {
        
        self.SessionID = nil
        
        var response:AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var error: NSErrorPointer = nil
        
        var request = NSMutableURLRequest()
        
        var body = "<Envelope><Header><TargetContract>\(self.Contract)</TargetContract><TargetService>DS.Base.Connect</TargetService><SecurityToken Type='PassportAccessToken'><AccessToken>\(self.AccessToken)</AccessToken></SecurityToken></Header><Body><RequestSessionID/></Body></Envelope>"
        
        //request.URL = NSURL.URLWithString(self.AccessPoint)
        request.URL = NSURL(string: self.AccessPoint)
        request.HTTPMethod = "POST"
        request.HTTPBody = body.dataUsingEncoding( NSUTF8StringEncoding, allowLossyConversion: true)
        
        var sessionData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: error)
        
        if error != nil{
            // You can handle error response here
            println("Get SessionID error: \(error)")
        }
        else{
            if let data = sessionData as NSData?{
                //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                var xml = SWXMLHash.parse(data)
                //var wrapping_sessionid = xml["Envelope"]["Body"]["SessionID"].element?.text
                //println(xml)
                if let sessionid = xml["Envelope"]["Body"]["SessionID"].element?.text{
                    self.SessionID = sessionid
                    //println("sessionid: \(sessionid)")
                }
            }
        }
        
        if self.SessionID != nil{
            return true
        }
        else{
            return false
        }
    }
}
