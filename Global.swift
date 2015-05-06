//
//  Global.swift
//  NanGang
//
//  Created by Cloud on 3/26/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import UIKit
import Parse

struct Global {
    //static var MyUUID:String!
    static var connector:Connector!
    static var Loading = LoadingIndicator()
    static var LoginInstance:LoginViewCtrl!
    //static var SelectPicId:String!
    
    static var DSNSList = [String:Bool]()
    static var MyGroups:[GroupItem]!
    static var MyDeviceToken:String!
    
    static var Installation = PFInstallation.currentInstallation()
    static var LastNewsViewChanged = true
    static var PreviewViewChanged = true
    
    private static var callback:(() -> ())!
    
    static func SetCallback(set:() -> ()){
        callback = set
    }
    
    static func Callback(){
        if callback != nil{
            callback()
        }
    }
    
    static func GetGroupItem(name:String) -> GroupItem?{
        
        for group in MyGroups{
            if group.GroupName == name{
                return group
            }
        }
        
        return nil
    }
    
    static func TeacherGroups() -> [GroupItem]{
        
        var retVal = [GroupItem]()
        
        for group in MyGroups{
            if group.IsTeacher{
                retVal.append(group)
            }
        }
        
        return retVal
    }
    
    static func HasDSNS(name:String) -> Bool{
        for dsns in DSNSList{
            if dsns.0 == name{
                return true
            }
        }
        
        return false
    }
}

func GenerateUUIDChannel(uuid:String) -> String{
    return "uuid_\(uuid.sha1())"
}

func GenerateChannelString(dsns:String,groupId:String!) -> String{
    return "channel_\(dsns.sha1())_\(groupId)"
}

func GetDoorWayURL(dsns:String) -> String{
    return "http://dsns.ischool.com.tw/dsns/dsns/DS.NameService.GetDoorwayURL?content=%3Ca%3E\(dsns)%3C/a%3E"
}

func GetLogoutUrl(type:String) -> String{
    
    if type == "Google"{
        return "https://accounts.google.com/Logout"
    }else{
        return "https://auth.ischool.com.tw/logout.php"
    }
}

//回傳一張縮放後的圖片
extension UIImage{
    func GetResizeImage(scale:CGFloat) -> UIImage{
        
        var width = self.size.width
        var height = self.size.height
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width * scale, height * scale), false, 1)
        self.drawInRect(CGRectMake(0, 0, width * scale, height * scale))
        
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func GetResizeImage(width:CGFloat, height:CGFloat) -> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, 1)
        self.drawInRect(CGRectMake(0, 0, width, height))
        
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension String {
    func sha1() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in digest {
            output.appendFormat("%02x", byte)
        }
        return output as String
    }
}

extension String {
    
    public var dataValue: NSData {
        return dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
    
    public var UrlEncoding: String?{
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    }
}

extension NSData {
    public var stringValue: String {
        return NSString(data: self, encoding: NSUTF8StringEncoding)! as String
    }
}

extension NSDate {
    public var stringValue: String {
        
        let secondsAgo:NSTimeInterval = self.timeIntervalSinceNow
        
        let value = -1*secondsAgo
        
        let day = Int(value / (60*60*24))
        let hour = Int(value / (60*60))
        let min = Int(value / (60))
        let sec = Int(value)
        
        if day > 3 {
            let dateStr = "\(self)"
            
            return dateStr.substringToIndex(advance(dateStr.startIndex, 10))
        }
        else if day > 0 {
            return "\(day) 天以前"
        }
        else if hour > 0 {
            return "\(hour) 小時以前"
        }
        else if min > 0 {
            return "\(min) 分鐘以前"
        }
        else{
            return "\(sec) 秒以前"
        }

    }
}

class LoadingIndicator {
    
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    /*
    Show customized activity indicator,
    actually add activity indicator to passing view
    
    @param uiView - add activity indicator to this view
    */
    func showActivityIndicator(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)
        
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2, loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    /*
    Hide activity indicator
    Actually remove activity indicator from its super view
    
    @param uiView - remove activity indicator from this view
    */
    func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    /*
    Define UIColor from hex value
    
    @param rgbValue - hex color value
    @param alpha - transparency level
    */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}

struct GroupItem {
    var GroupId:String!
    var GroupName:String!
    var ChannelName:String!
    var IsTeacher:Bool
}