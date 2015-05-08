//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 04/09/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class IntegrateDetailViewCtrl: UIViewController {
    
    var content:String!
    var date:String!
    var type:String!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var booknameLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    
    
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title2: UILabel!
    @IBOutlet weak var title3: UILabel!
    @IBOutlet weak var title4: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title1.layer.masksToBounds = true
        title1.layer.cornerRadius = 5
        
        title2.layer.masksToBounds = true
        title2.layer.cornerRadius = 5
        
        title3.layer.masksToBounds = true
        title3.layer.cornerRadius = 5
        
        title4.layer.masksToBounds = true
        title4.layer.cornerRadius = 5
        
        var jsonResult = NSJSONSerialization.JSONObjectWithData(content.dataValue, options: nil, error: nil) as! NSDictionary!
        
        if count(date) >= 19{
            dateLabel.text = (date as NSString).substringToIndex(19)
        }
        else{
            dateLabel.text = "error date time format"
        }
        
        if let book = jsonResult["book"] as? String{
            booknameLabel.text = book
        }
        
        if let isbm = jsonResult["isbm"] as? String{
            codeLabel.text = isbm
        }
        
        aboutTextView.editable = false
        aboutTextView.text = "查無此書籍相關簡介"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

