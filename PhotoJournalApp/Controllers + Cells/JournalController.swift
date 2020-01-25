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
    
    private var selectedIndex: IndexPath?
    
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
        cell.cellDelegate = self
        
        cell.index = indexPath
        selectedIndex = indexPath
        
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

extension JournalController: JournalCollection {
    
    func onClickCell(index: Int, photoCell: JournalCell) {
        print("\(index) is clicked")
        
        guard let indexPath = photoCell.index else { return }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default)
        let shareAction = UIAlertAction(title: "Share", style: .default)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] alertAction in
            self?.deletePhoto(indexPath: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(editAction)
        alertController.addAction(shareAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
        
    }
    
    private func deletePhoto(indexPath: IndexPath) {
        do {
            try persistence.deleteItem(at: indexPath.row)
            
            imageObjects.remove(at: indexPath.row)
            
            collectionView.deleteItems(at: [indexPath])
            
        } catch {
            print("Error deleting")
        }
        
    }
}

