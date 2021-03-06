//
//  CustomCell.swift
//  App
//
//  Created by Cloud on 10/23/14.
//  Copyright (c) 2014 Cloud. All rights reserved.
//

import UIKit

class HeaderCell: UICollectionReusableView {
    
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title.text = "this is a header"
        title.layer.cornerRadius = 5
        title.layer.masksToBounds = true
        // Initialization code
    }
}

class FooterCell: UICollectionReusableView {
    
    
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title.text = "test footer!!!"
        // Initialization code
    }
}

class PhotoCell: UITableViewCell {
    
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var Comment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //        cellView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        //        absenceType.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        //absenceType.layer.cornerRadius = 5
        //absenceType.layer.masksToBounds = true
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class LastNewsCell: UITableViewCell {
    
    @IBOutlet weak var GroupName: UILabel!
    @IBOutlet weak var Comment: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var Icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Comment.sizeToFit()
//        self.layer.masksToBounds = true
//        self.layer.cornerRadius = 5
//        self.backgroundColor = UIColor(red: 217.0/255.0, green: 1, blue: 196.0/255.0, alpha: 0.8)
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class IntegrateCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Content: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Comment.sizeToFit()
        //        self.layer.masksToBounds = true
        //        self.layer.cornerRadius = 5
        //        self.backgroundColor = UIColor(red: 217.0/255.0, green: 1, blue: 196.0/255.0, alpha: 0.8)
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class AnalyticsCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Comment.sizeToFit()
        //        self.layer.masksToBounds = true
        //        self.layer.cornerRadius = 5
        //        self.backgroundColor = UIColor(red: 217.0/255.0, green: 1, blue: 196.0/255.0, alpha: 0.8)
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class FaceDetectCell: UITableViewCell {
    
    @IBOutlet weak var Face: UIImageView!
    @IBOutlet weak var Name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        // Configure the view for the selected state
    }
}

class TitleOnlyCell: UITableViewCell {
    
    @IBOutlet weak var Title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        // Configure the view for the selected state
    }
}

class WorkAlbumCell: UITableViewCell {
    
    @IBOutlet weak var ImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        // Configure the view for the selected state
    }
}


