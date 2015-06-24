//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 04/09/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class IntegrateDetailViewCtrl: UIViewController {
    
//    var content:String!
//    var date:String!
//    var type:String!
    
    var data:IntegrateData!
    
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
        
        aboutTextView.editable = false
        
        title1.layer.masksToBounds = true
        title1.layer.cornerRadius = 5
        
        title2.layer.masksToBounds = true
        title2.layer.cornerRadius = 5
        
        title3.layer.masksToBounds = true
        title3.layer.cornerRadius = 5
        
        title4.layer.masksToBounds = true
        title4.layer.cornerRadius = 5
        
        //var jsonResult = NSJSONSerialization.JSONObjectWithData(content.dataValue, options: nil, error: nil) as! NSDictionary!
        
        if count(data.Date) >= 10{
            if data.Date.rangeOfString("-") == nil{
                dateLabel.text = (data.Date as NSString).substringToIndex(8)
            }
            else{
                dateLabel.text = (data.Date as NSString).substringToIndex(10)
            }
        }
        else{
            dateLabel.text = "error date time format"
        }
        
        booknameLabel.text = data.BookName
        codeLabel.text = data.BookISBN
        
        if data.BookGroup != ""{
            let firstChar = (data.BookGroup as NSString).substringToIndex(1)
            
            if let int_key = firstChar.toInt(){
                aboutTextView.text = "查無此書籍簡介。(\(GetTypeName(int_key)))"
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func GetTypeName(code:Int) -> String{
        switch code{
        case 0:
            return "總類"
        case 1:
            return "哲學類"
        case 2:
            return "宗教類"
        case 3:
            return "自然科學類"
        case 4:
            return "應用科學類"
        case 5:
            return "社會科學類"
        case 6:
            return "中國史地類"
        case 7:
            return "外國史地類"
        case 8:
            return "語文類"
        case 9:
            return "美術類"
        default:
            return "查無分類資訊"
        }
    }
}

