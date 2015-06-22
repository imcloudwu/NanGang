//
//  DetailViewCtrl.swift
//  NanGang
//
//  Created by Cloud on 04/09/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class WorksPreviewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var _data = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = UIColor.blackColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("workAlbumCell") as! WorkAlbumCell
        cell.ImageView.image = _data[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Detail") as! DetailViewCtrl
        nextView._currentIndex = indexPath.row
        nextView._ImageArray = _data
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
}

