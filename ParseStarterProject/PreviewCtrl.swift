//
//  ViewController.swift
//  UICollectionView
//
//  Created by Brian Coleman on 2014-09-04.
//  Copyright (c) 2014 Brian Coleman. All rights reserved.
//

import UIKit
import Parse

class PreviewCtrl: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var _data:[CustomImg]!
    
    @IBOutlet weak var _collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _collectionView.dataSource = self
        _collectionView.delegate = self
        
        _data = [CustomImg]()
        
        var query = PFQuery(className: "PhotoData")
        
        //指定條件
        //query.whereKey("objectId", equalTo: "fykSf2roCq")
        
        //loop結果
        for object in query.findObjects(){
            
            let id = object.objectId
            //將pffile轉成image
            let file = object["preview"] as PFFile
            
            var imgData = file.getData()
            
            if let img = UIImage(data: imgData){
                var cimg = CustomImg(id: id, img: img)
                _data.append(cimg)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell1", forIndexPath: indexPath) as UICollectionViewCell
        var imgView = cell.viewWithTag(100) as UIImageView
        imgView.image = _data[indexPath.row].img
        
        return cell
    }
    
    //call when item is clicked
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell1", forIndexPath: indexPath) as UICollectionViewCell
        
        Global.SelectPicId = _data[indexPath.row].id
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Detail") as UIViewController
        
        self.navigationController?.pushViewController(nextView, animated: true)
        
        //println("\(_array[indexPath.row])")
        
        //println("\(indexPath.section):\(indexPath.row)")
    }
}

struct CustomImg{
    var id:String
    var img:UIImage
}