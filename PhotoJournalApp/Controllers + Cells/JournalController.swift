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
    
    public var imageObjects = [ImageObject]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public var persistence = DataPersistence<ImageObject>(filename: "images.plist")
    
    private var selectedIndex: IndexPath?
    
//    private lazy var addPhotoController: UIViewController = {
//        guard let photoController = storyboard?.instantiateViewController(identifier: "AddPhotoController") as? AddPhotoController else {
//            fatalError("could not load nav controller")
//        }
//        photoController.dataPersistence = persistence
//        return photoController
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        loadImageObjects()
    }
    @IBAction func addPhotoButton(_ sender: UIBarButtonItem) {
        showAddPhotoVC()
    }
    
    private func loadImageObjects() {
        do {
            imageObjects = try persistence.loadItems()
        } catch {
            print("could not get photos")
        }
    }
    
    private func showAddPhotoVC(_ photo: ImageObject? = nil) {
        
        guard let createPhotoController = storyboard?.instantiateViewController(identifier: "AddPhotoController") as? AddPhotoController else {
            fatalError("could not downcast to CreateEventController")
        }
        
        createPhotoController.imageObject = photo
        createPhotoController.photosDelegate = self
        
        present(createPhotoController, animated: true)
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

extension JournalController: AddPhotoToCollection {
    func updateCollectionView(images: ImageObject) {
//        imageObjects.insert(images, at: 0)
        do {
            try persistence.createItem(images)
        } catch {
            print("could not create")
        }
    }
}



