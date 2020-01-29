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

protocol ImagePhoto: AnyObject {
    func getImageData(_ image: ImageObject)
}

class JournalController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    public var imageObjects = [ImageObject]() {
        didSet {
            
            collectionView.reloadData()
        }
    }
    
    public var selectedImage: ImageObject?
    
    public var persistence = DataPersistence<ImageObject>(filename: "images.plist")
    
    private var selectedIndex: IndexPath?
    
    weak var imageDelegate: ImagePhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        loadImageObjects()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addPhotoVC = segue.destination as? AddPhotoController,let Indexpath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        addPhotoVC.photosDelegate = self
        addPhotoVC.imageObject = imageObjects[Indexpath.row]
        print(imageObjects[Indexpath.row].description)
        
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
        createPhotoController.photosDelegate = self
        createPhotoController.imageObject = photo
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
        selectedImage = imageObject
        
        imageDelegate?.getImageData(imageObject)
        
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

        let imageObject = imageObjects[indexPath.row]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] alertAction in
            self?.showAddPhotoVC(imageObject)
//            print(self?.imageObjects[indexPath.row].description)
        }
        
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
        imageObjects.append(images)
        do {
            try persistence.createItem(images)
            
        } catch {
            print("could not create")
        }
    }
}



