//
//  AddPhotoController.swift
//  PhotoJournalApp
//
//  Created by Kelby Mittan on 1/23/20.
//  Copyright © 2020 Kelby Mittan. All rights reserved.
//

import UIKit
import DataPersistence
import AVFoundation

protocol AddPhotoToCollection {
    func updateCollectionView(images: ImageObject)
}

class AddPhotoController: UIViewController {
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var libraryButton: UIBarButtonItem!
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    private let imagePickerController = UIImagePickerController()
    
//    public var dataPersistence: DataPersistence<ImageObject>!
    
    public var dataPersistence = DataPersistence<ImageObject>(filename: "images.plist")
    
    private var imageObjects = [ImageObject]()
    
    public var imageObject: ImageObject?
    
    public var imageDescription = String()
    
    private var selectedImage: UIImage?
    
    var photosDelegate: AddPhotoToCollection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        loadImageObjects()
    }
    
    private func loadImageObjects() {
        do {
            imageObjects = try dataPersistence.loadItems()
        } catch {
            print("could not get photos")
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        do {
            imageObjects = try dataPersistence.loadItems()
            dump(imageObjects)
        } catch {
            print("oops")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        guard let image = selectedImage else {
            print("image is nil")
            return
        }
        
//        print("original image size is \(image.size)")
        
        // the size for resizing
        let size = UIScreen.main.bounds.size
        
        // we will maintain the aspect ratio of the image
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        
        // resize image
        let resizeImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
        
        
        guard let resizedImageData = resizeImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        print("original image size is \(resizeImage.size)")
        
        let imageObject = ImageObject(imageData: resizedImageData, date: Date(), description: imageDescription)
        
        imageObjects.insert(imageObject, at: 0)
        
        do {
            try dataPersistence.createItem(imageObject)
        } catch {
            print("saving error")
        }
//        showJournalVC()
        loadImageObjects()
        
        photosDelegate?.updateCollectionView(images: imageObject)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func libraryButtonPressed(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            
            imagePickerController.sourceType = .photoLibrary
            
            self.present(imagePickerController, animated: true)//, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            
            imagePickerController.sourceType = .camera
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
//        persistence.removeAll()
        
    }
    
//    private func showJournalVC(_ photos: [ImageObject]? = nil) {
//
//        guard let journalController = storyboard?.instantiateViewController(identifier: "JournalController") as? JournalController else {
//            fatalError("could not downcast to JournalController")
//        }
//
//        guard let photos = photos else { return }
//        loadImageObjects()
//        journalController.imageObjects = photos
//
//        present(journalController, animated: true)
//    }
    
}

extension AddPhotoController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        imageDescription = textField.text ?? "no event name"
        
        textField.text = ""
        
        return true
    }
}

extension AddPhotoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image selected not found")
            return
        }
        selectedImage = image
        photoImage.image = image
        dismiss(animated: true)
    }
}

extension UIImage {
    func resizeImage(to width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
