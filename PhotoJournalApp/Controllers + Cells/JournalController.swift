//
//  ViewController.swift
//  PhotoJournalApp
//
//  Created by Kelby Mittan on 1/23/20.
//  Copyright © 2020 Kelby Mittan. All rights reserved.
//

import UIKit
import AVFoundation
import DataPersistence

class JournalController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!

    private var imageObjects = [ImageObject]()
    
    public var persistence = DataPersistence<ImageObject>(filename: "images.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadImageObjects()
    }
    
    private func loadImageObjects() {
        do {
            imageObjects = try persistence.loadItems()
        } catch {
            print("could not get photos")
        }
    }


}

extension JournalController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? JournalCell else {
            fatalError("could not downcast to Journal Cell")
        }
        let imageObject = imageObjects[indexPath.row]
        
        cell.configureCell(for: imageObject)
        return cell
    }
}

extension JournalController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.80
        return CGSize(width: itemWidth, height: itemWidth)  }
}

