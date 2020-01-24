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

class AddPhotoController: UIViewController {
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var libraryButton: UIBarButtonItem!
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    private let imagePickerController = UIImagePickerController()
    
    public var dataPersistence = PersistenceHelper(filename: "images.plist")
    
    public var persistence = DataPersistence<ImageObject>(filename: "images.plist")
    
    private var imageObjects = [ImageObject]()
    
    public var imageObject: ImageObject?
    
    public var imageDescription = String()
    
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let imageObject = imageObject, let image = UIImage(data: imageObject.imageData) else {
            return
        }
        photoImage.image = image
        dump(imageObjects)
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        do {
            imageObjects = try persistence.loadItems()
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
        
        print("original image size is \(image.size)")
        
        // the size for resizing
//        let size = UIScreen.main.bounds.size
        
        // we will maintain the aspect ratio of the image
//        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        
        // resize image
        let resizeImage = image//.resizeImage(to: rect.size.width, height: rect.size.height)
        
        
        guard let resizedImageData = resizeImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        print("original image size is \(resizeImage.size)")
        
        // create an image object
        let imageObject = ImageObject(imageData: resizedImageData, date: Date(), description: imageDescription)
        
        // insert new imageObject into imageObjects
        imageObjects.insert(imageObject, at: 0)
        
        // create an indexPath for insertion into collection view
//        let indexPath = IndexPath(row: 0, section: 0)
        
        // insert new cell into collection view
//        collectionView.insertItems(at: [indexPath])
        
        // persist imageObject to documents directory
        do {
            try persistence.createItem(imageObject)
        } catch {
            print("saving error")
        }
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
    }
    
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
        dismiss(animated: true)
    }
}
