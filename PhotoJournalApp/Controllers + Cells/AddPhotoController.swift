//
//  AddPhotoController.swift
//  PhotoJournalApp
//
//  Created by Kelby Mittan on 1/23/20.
//  Copyright © 2020 Kelby Mittan. All rights reserved.
//

import UIKit

class AddPhotoController: UIViewController {
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var libraryButton: UIBarButtonItem!
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    private let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate;
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func libraryButtonPressed(_ sender: UIBarButtonItem) {
        photoLibrary()
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
}
