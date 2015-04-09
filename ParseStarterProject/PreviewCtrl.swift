//
//  ViewController.swift
//  UICollectionView
//
//  Created by Brian Coleman on 2014-09-04.
//  Copyright (c) 2014 Brian Coleman. All rights reserved.
//

import UIKit
import Parse
import Foundation

class PreviewCtrl: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    //var _data:[CustomImg]!
    
    var _groupList:[String]!
    var _mappingData:[String:[CustomImg]]!
    
    var _UICollectionReusableView : HeaderCell!
    
    @IBOutlet weak var _collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "相片瀏覽"
        
        _collectionView.dataSource = self
        _collectionView.delegate = self
        
        _groupList = [String]()
        _mappingData = [String:[CustomImg]]()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        Global.Loading.showActivityIndicator(self.view)
        
        _groupList.removeAll(keepCapacity: false)
        _mappingData.removeAll(keepCapacity: false)
        
        var query = PFQuery(className: "PhotoData")
        
        //指定條件
        //query.whereKey("channels", equalTo: "fykSf2roCq")
        //query.whereKey("channel", containedIn: Global.MyChannels)
        
        var myChannelList = [String]()
        
        for group in Global.MyGroups{
            myChannelList.append(group.ChannelName)
            //_mappingData[group.GroupName] = [CustomImg]()
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
                    
                    //self._data.append(cimg)
                    
                    //第一次遇到不同的groupName時
                    if !contains(self._groupList, groupName){
                        self._groupList.append(groupName)
                        self._mappingData[groupName] = [CustomImg]()
                    }
                    
                    self._mappingData[groupName]?.append(cimg)
                }
            }
            
            Global.Loading.hideActivityIndicator(self.view)
            
            if objects.count == 0{
                let alert = UIAlertView()
                alert.title = "系統訊息"
                alert.message = "查無資料"
                alert.addButtonWithTitle("OK")
                alert.show()
            }
            
            self._collectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self._groupList.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let groupName = _groupList[section]
        
        if let list:[CustomImg] = _mappingData[groupName]{
            return list.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell1", forIndexPath: indexPath) as UICollectionViewCell
        //cell.layer.cornerRadius = 5
        
        let groupName = _groupList[indexPath.section]
        
        if let list:[CustomImg] = _mappingData[groupName]{
            var imgView = cell.viewWithTag(100) as UIImageView
            //imgView.image = _data[indexPath.row].Img
            imgView.image = list[indexPath.row].Img
            
            //var label = cell.viewWithTag(101) as UILabel
            //label.text = _data[indexPath.row].Group
            //label.text = list[indexPath.row].Group
        }
        
        return cell
    }
    
    //call when item is clicked
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        //let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell1", forIndexPath: indexPath) as UICollectionViewCell
        
        //Global.SelectPicId = _data[indexPath.row].Id
        
        let groupName = _groupList[indexPath.section]
        
        if let list:[CustomImg] = _mappingData[groupName]{
            
            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Detail") as DetailViewCtrl
            nextView._SelectPicId = list[indexPath.row].Id
            
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    //Get Header
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView{
        
        _UICollectionReusableView = nil
        
        if kind == UICollectionElementKindSectionHeader{
            _UICollectionReusableView = _collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as HeaderCell
            
            _UICollectionReusableView.title.text = " \(_groupList[indexPath.section])"
        }
        
        return _UICollectionReusableView
    }
}

struct CustomImg{
    var Id:String
    var Img:UIImage
    var Group:String
}