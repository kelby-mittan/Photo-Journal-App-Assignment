//
//  JournalCell.swift
//  PhotoJournalApp
//
//  Created by Kelby Mittan on 1/23/20.
//  Copyright © 2020 Kelby Mittan. All rights reserved.
//

import UIKit

protocol JournalCollection {
    func onClickCell(index: Int, photoCell: JournalCell)
}

class JournalCell: UICollectionViewCell {
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
//    public var imageObject: ImageObject?
    
    var cellDelegate: JournalCollection?
    var index: IndexPath?
    
    func configureCell(for photo: ImageObject) {
        layer.cornerRadius = 20
        descriptionLabel.text = photo.description
        dateLabel.text = photo.date.description
        
        guard let image = UIImage(data: photo.imageData) else {
            return
        }
        photoImage.image = image
        
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        cellDelegate?.onClickCell(index: (index?.row)!, photoCell: self)
    }
}
