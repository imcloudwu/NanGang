////
////  DetailViewCtrl.swift
////  NanGang
////
////  Created by Cloud on 3/27/15.
////  Copyright (c) 2015 Parse. All rights reserved.
////
//
//import UIKit
//import MobileCoreServices
//import MediaPlayer
//
//class myGallery: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,ELCImagePickerControllerDelegate  {
//    
//    var _data:[UIImage]!
//    
//    @IBOutlet weak var _collection: UICollectionView!
//    
//    @IBAction func selectBtn(sender: AnyObject) {
//        
//        var picker: UIImagePickerController = UIImagePickerController()
//        
//        var x = ELCImagePickerController(imagePicker: ())
//        x.maximumImagesCount = 10; //Set the maximum number of images to select, defaults to 4
//        x.returnsOriginalImage = false; //Only return the fullScreenImage, not the fullResolutionImage
//        x.returnsImage = true; //Return UIimage if YES. If NO, only return asset location information
//        x.onOrder = true; //For multiple image selection, display and return selected order of images
//        x.imagePickerDelegate = self;
//        
////        MAPickerController* vc = [[MAPickerController alloc] initWithDelegate: self maxSel: 3];
////        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController: vc];
////        [self presentViewController: nav animated: YES completion: nil];
//        
//        //let pickerController = DKImagePickerController()
//        //pickerController.pickerDelegate = self
//        self.presentViewController(x, animated: true) {}
//    }
//    
//    @IBAction func takeBtn(sender: AnyObject) {
//        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
//            
//            var picker: UIImagePickerController = UIImagePickerController()
//            picker.delegate = self
//            picker.allowsEditing = false
//            picker.sourceType = .Camera
//            picker.showsCameraControls = true
//            
//            self.presentViewController(picker, animated: true, completion: nil)
//            
//        }
//    }
//    
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        _data = [UIImage]()
//        
//        _collection.delegate = self
//        _collection.dataSource = self
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
//        return _data.count
//    }
//    
//    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell100", forIndexPath: indexPath) as UICollectionViewCell
//        //cell.layer.cornerRadius = 5
//        
//        var imgView = cell.viewWithTag(100) as UIImageView
//        imgView.image = _data[indexPath.row]
//        
//        //let groupName = _groupList[indexPath.section]
//        
//        //if let list:[CustomImg] = _mappingData[groupName]{
//          //  var imgView = cell.viewWithTag(100) as UIImageView
//            //imgView.image = _data[indexPath.row].Img
//          //  imgView.image = list[indexPath.row].Img
//            
//            //var label = cell.viewWithTag(101) as UILabel
//            //label.text = _data[indexPath.row].Group
//            //label.text = list[indexPath.row].Group
//        //}
//        
//        return cell
//    }
//    
//    func elcImagePickerController(picker:ELCImagePickerController, didFinishPickingMediaWithInfo info:[AnyObject]) -> (){
//        //println(info.count)
//        self._data.removeAll(keepCapacity: false)
//        for each in info{
//            var img = each[UIImagePickerControllerOriginalImage] as UIImage
//            self._data.append(img)
//        }
//        
//        _collection.reloadData()
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    /**
//    * Called when image selection was cancelled, by tapping the 'Cancel' BarButtonItem.
//    */
//    func elcImagePickerControllerDidCancel(picker:ELCImagePickerController){
//        picker.dismissViewControllerAnimated(true, completion: nil)
//    }
//}
//
