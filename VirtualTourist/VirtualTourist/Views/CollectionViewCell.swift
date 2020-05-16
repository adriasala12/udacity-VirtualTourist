//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Adrià Sala Roget on 12/05/2020.
//  Copyright © 2020 Adrià Sala Roget. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.image = UIImage(named: "placeholder")
        
    }
    
}
