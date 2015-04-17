//
//  ScanViewCtrl.swift
//  oneAdminParent
//
//  Created by Cloud on 11/24/14.
//  Copyright (c) 2014 ischool. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewCtrl: UIViewController,AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate {
    
    var _captureSession: AVCaptureSession? = nil
    var _videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    var _isReading: Bool = false
    
    @IBOutlet var _videoPreview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Global.AdjustView(contentView)
        
        _videoPreview.layer.cornerRadius = 5
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        startReading()
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopReading()
    }
    
    func startReading() -> Bool{
        
        //lblResult.text = "Scanning..."
        
        var error: NSError?
        
        let captureDevice: AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        let input: AVCaptureDeviceInput = AVCaptureDeviceInput(device: captureDevice, error: &error)
        
        var output: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
        
        _captureSession = AVCaptureSession()
        _captureSession?.addInput(input)
        _captureSession?.addOutput(output)
        
        var dispatchQueue: dispatch_queue_t = dispatch_queue_create("myQueue", nil);
        
        output.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        _videoPreviewLayer = AVCaptureVideoPreviewLayer(session: _captureSession)
        _videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        _videoPreviewLayer?.frame = _videoPreview.layer.bounds
        
        _videoPreview.layer.addSublayer(_videoPreviewLayer)
        
        _captureSession?.startRunning()
        
        return true
    }
    
    func stopReading() {
        _captureSession?.stopRunning()
        _captureSession = nil
        
        _videoPreviewLayer?.removeFromSuperlayer()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        Global.LoginInstance.GetDSNSList(self)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
        
        if metadataObjects != nil && metadataObjects.count > 0 {
            var metadataObj: AVMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            
            dispatch_async(dispatch_get_main_queue()) {() -> Void in
                
                let fullNameArr = metadataObj.stringValue.componentsSeparatedByString("@")
                
                if fullNameArr.count != 2{
                    let alert = UIAlertView()
                    //alert.title = "系統提示"
                    alert.message = "QRcode不正確"
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    return
                }
                
                var code: String = fullNameArr[0]
                var server:String = fullNameArr[1]
                
                var con = Global.connector.Clone()
                
                //Join Domain List
                if !contains(Global.DSNSList.keys,server){
                    con.Contract = "user"
                    con.SendRequest("AddApplicationRef", body: "<Request><Applications><Application><AccessPoint>\(server)</AccessPoint><Type>dynpkg</Type></Application></Applications></Request>"){ resp in
                        //println(NSString(data: resp, encoding: NSUTF8StringEncoding))
                    }
                }
                
                HttpClient.Get(GetDoorWayURL(server)){data in
                    //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                    var xml = SWXMLHash.parse(data)
                    for elem in xml["Envelope"]["Body"]["DoorwayURL"]{
                        if let DoorwayURL = elem.element?.text{
                            //println(DoorwayURL)
                            con.AccessPoint = DoorwayURL
                            con.Contract = "auth.guest"
                            con.GetSessionID()
                            
                            con.SendRequest("Join.AsParent", body: "<Request><ParentCode>\(code)</ParentCode><Relationship>iOS Parent</Relationship></Request>") { (response) -> () in
                                
                                println(NSString(data: response, encoding: NSUTF8StringEncoding))
                                
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
                                    let alert = UIAlertView()
                                    //alert.title = "系統提示"
                                    alert.message = "加入失敗"
                                    alert.addButtonWithTitle("OK")
                                    alert.show()
                                }
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
            
            stopReading()
            _isReading = !_isReading
        }
        
    }
}