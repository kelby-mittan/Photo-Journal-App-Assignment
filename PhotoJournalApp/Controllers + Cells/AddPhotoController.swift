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
import CoreImage

protocol AddPhotoToCollection: AnyObject {
    func updateCollectionView(images: ImageObject)
    func editPhoto(original: ImageObject, newPhoto: ImageObject)
}

struct Filter {
    var filterName: String
    var filterEffectValue: Any?
    var filterEffectValueName: String?
    
    init(filterName: String, filterEffectValue: Any?, filterEffectValueName: String?) {
        self.filterName = filterName
        self.filterEffectValue = filterEffectValue
        self.filterEffectValueName = filterEffectValueName
    }
}

class AddPhotoController: UIViewController, ImagePhoto {
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var libraryButton: UIBarButtonItem!
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    private let imagePickerController = UIImagePickerController()
    
    public var dataPersistence = DataPersistence<ImageObject>(filename: "images.plist")
    
    public var imageObjects = [ImageObject]()
    
    public var originalPhoto: ImageObject?
    
    public var imageDescription = String()
    
    public var selectedImage: UIImage?
    
    weak var photosDelegate: AddPhotoToCollection?
    
    public var isEditingPhoto = false
    
    public var originalImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        saveButton.isEnabled = false
        updateUI()
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//    }
    
    private func updateUI() {
        guard let image = originalPhoto?.imageData else {
            return
        }
        
        print("here \(originalPhoto?.description ?? "")")
        
        textField.text = originalPhoto?.description
        photoImage.image = UIImage(data: image)
        if imageDescription.isEmpty {
            cameraButton.isEnabled = false
            libraryButton.isEnabled = false
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
        
        let size = UIScreen.main.bounds.size
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        let resizeImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
        
        guard let resizedImageData = resizeImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        let imageObject = ImageObject(imageData: resizedImageData, date: Date(), description: imageDescription)
        
        if cameraButton.isEnabled {
            photosDelegate?.updateCollectionView(images: imageObject)
        } else {
            guard let original = originalPhoto else {
                print("original not there")
                return
            }
            photosDelegate?.editPhoto(original: original, newPhoto: imageObject)
        }
        
        
        
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
        
    }
    
    private func applyFilter(image: UIImage, filterEffect: Filter) -> UIImage? {
        
        guard let cgImage = image.cgImage, let openGLContext = EAGLContext(api: .openGLES3) else {
            return nil
        }
        
        let context = CIContext(eaglContext: openGLContext)
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter(name: filterEffect.filterName)
        
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let filterEffectValue = filterEffect.filterEffectValue,
           let filterEffectValueName = filterEffect.filterEffectValueName {
            
            filter?.setValue(filterEffectValue, forKey: filterEffectValueName)
        }
        
        var filteredImage: UIImage?
        
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage,
           let cgiImageResult = context.createCGImage(output, from: output.extent) {
            
            filteredImage = UIImage(cgImage: cgiImageResult)
        }
        
        return filteredImage
    }
    
    
    @IBAction func applySepia(_ sender: UIButton) {
        guard let image = photoImage.image else {
            return
        }
        
        photoImage.image = applyFilter(image: image, filterEffect: Filter(filterName: "CISepiaTone", filterEffectValue: 0.9, filterEffectValueName: kCIInputIntensityKey))
    }
    
    @IBAction func applyBlur(_ sender: UIButton) {
        guard let image = photoImage.image else {
            return
        }
        
        photoImage.image = applyFilter(image: image, filterEffect: Filter(filterName: "CIGaussianBlur", filterEffectValue: 9.0, filterEffectValueName: kCIInputRadiusKey))
    }
    
    @IBAction func applyNoir(_ sender: UIButton) {
        guard let image = photoImage.image else {
            return
        }
        
        photoImage.image = applyFilter(image: image, filterEffect: Filter(filterName: "CIPhotoEffectNoir", filterEffectValue: nil, filterEffectValueName: nil))
    }
    
    @IBAction func applyProcess(_ sender: UIButton) {
        guard let image = photoImage.image else {
            return
        }
        
        photoImage.image = applyFilter(image: image, filterEffect: Filter(filterName: "CIPhotoEffectProcess", filterEffectValue: 14.0, filterEffectValueName: nil))
    }
    
    @IBAction func resetImage(_ sender: UIButton) {
        photoImage.image = originalImage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let journalVC = segue.destination as? JournalController else { return }
        
        journalVC.imageDelegate = self
        getImageData(originalPhoto!)
    }
    
    func getImageData(_ image: ImageObject) {
        self.photoImage.image = UIImage(data: image.imageData)
        print(image.description)
    }
    
}

extension AddPhotoController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        if textField.text != "" && photoImage.image != nil {
            saveButton.isEnabled = true
        }
        imageDescription = textField.text ?? "no photo description"
//        print(photoImage.image?.description)
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
        originalImage = image
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
