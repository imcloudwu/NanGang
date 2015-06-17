//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 04/09/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class IntegrateBrowserCtrl: UIViewController {
    
    var content:String!
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var error : NSError?
        
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(content.dataValue, options: nil, error: &error) as? NSDictionary{
            if let decodeUrl = jsonResult["pub_url"] as? String{
                //var url = decodeUrl.UrlDecoding
                
                //載入登入頁面
                var urlobj = NSURL(string: decodeUrl)
                var request = NSURLRequest(URL: urlobj!)
                webView.loadRequest(request)
            }
        }
        else{
            println(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

