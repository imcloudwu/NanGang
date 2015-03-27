//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class LoginViewCtrl : UIViewController {

    var _con:Connector!
    
    @IBOutlet weak var account: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var btnLogin: UIButton!
    
    
    @IBAction func btnClick(sender: AnyObject) {
        LoginWithGreening()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account.text = "imcloudwu@gmail.com"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func LoginWithGreening(){
        //Global.Loading.showActivityIndicator(self.view)
        //self.status.text = "登入驗證"
        _con = Connector(authUrl: "https://auth.ischool.com.tw/oauth/token.php", accessPoint: "https://auth.ischool.com.tw:8443/dsa/greening", contract: "user")
        _con.ClientID = "5e89bdfbf971974e3b53312384c0013a"
        _con.ClientSecret = "855b8e05afadc32a7a2ecbf0b09011422e5e84227feb5449b1ad60078771f979"
        _con.UserName = self.account.text
        _con.Password = self.password.text
        
        if _con.IsValidated("greening"){
            //Global.connector = _con
            //GetChildList(nil)
            Global.connector = _con
            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Main") as UIViewController
            self.presentViewController(nextView, animated: true, completion: nil)
        }
        else{
            //self.status.text = "登入失敗"
            let alert = UIAlertView()
            alert.title = "登入失敗"
            alert.message = "帳號密碼可能錯誤"
            alert.addButtonWithTitle("OK")
            alert.show()
            //Global.Loading.hideActivityIndicator(self.view)
        }
        
    }
}

