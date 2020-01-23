//
//  JournalCell.swift
//  PhotoJournalApp
//
//  Created by Kelby Mittan on 1/23/20.
//  Copyright © 2020 Kelby Mittan. All rights reserved.
//

import UIKit

class JournalCell: UICollectionViewCell {
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
//    public var imageObject: ImageObject?
    
    func configureCell(for photo: ImageObject) {
        
        descriptionLabel.text = photo.description
        dateLabel.text = photo.date.description
        
        guard let image = UIImage(data: photo.imageData) else {
            return
        }
        photoImage.image = image
        
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        
    }
}
