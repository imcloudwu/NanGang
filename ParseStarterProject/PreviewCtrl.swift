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
    
    var _UICollectionReusableView : UICollectionReusableView!
    
    @IBOutlet weak var _collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Global.Loading.showActivityIndicator(self.view)
        
        _collectionView.dataSource = self
        _collectionView.delegate = self
        
        _data = [CustomImg]()
        
        _data.removeAll(keepCapacity: false)
        
        var query = PFQuery(className: "PhotoData")
        
        //指定條件
        //query.whereKey("channels", equalTo: "fykSf2roCq")
        //query.whereKey("channel", containedIn: Global.MyChannels)
        
        var myChannelList = [String]()
        
        for group in Global.MyGroups{
            myChannelList.append(group.ChannelName)
        }
        
        query.whereKey("channel",containedIn: myChannelList)
        
        query.findObjectsInBackgroundWithBlock { (objects, NSError) -> Void in
            
            //loop結果
            for object in objects{
                
                let id = object.objectId
                let groupName = object["group"] as String
                //將pffile轉成image
                let file = object["preview"] as PFFile
                
                var imgData = file.getData()
                
                if let img = UIImage(data: imgData){
                    
                    var cimg = CustomImg(Id: id, Img: img, Group: groupName)
                    
                    self._data.append(cimg)
                }
            }
            
            Global.Loading.hideActivityIndicator(self.view)
            self._collectionView.reloadData()
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
        cell.layer.cornerRadius = 5
        
        var imgView = cell.viewWithTag(100) as UIImageView
        imgView.image = _data[indexPath.row].Img
        
        var label = cell.viewWithTag(101) as UILabel
        label.text = _data[indexPath.row].Group
        
        println(indexPath.section)
        
        return cell
    }
    
    //call when item is clicked
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        //let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell1", forIndexPath: indexPath) as UICollectionViewCell
        
        Global.SelectPicId = _data[indexPath.row].Id
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Detail") as UIViewController
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        
        _UICollectionReusableView = nil
        
        if kind == UICollectionElementKindSectionHeader{
            _UICollectionReusableView = _collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as HeaderCell
        }
        
        return _UICollectionReusableView
    }
}

struct CustomImg{
    var Id:String
    var Img:UIImage
    var Group:String
}