//
//  ViewController.swift
//  SeeFood
//
//  Created by Antons Aleksandrovs on 29/01/2018.
//  Copyright © 2018 Antons Aleksandrovs. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    let foodArray = Food().foodArray
    
    let colours = Colours()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
      setColours(with: colours.lightPurpleColour, and: colours.darkPurpleColour)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIIMage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstResult = results.first {
                
                var isFood: Bool = false
                
                for food in self.foodArray {
                    
                    if firstResult.identifier.contains(food) {
                        isFood = true
                        self.setColours(with: self.colours.lightGreenColour, and: self.colours.darkGreenColour)
                        break
                    } else {
                        isFood = false
                        self.setColours(with: self.colours.lightRedColour, and: self.colours.darkRedColour)
                    }
                }
                
                self.navigationItem.title = isFood ? "Eatable" : "Uneatable"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("error")
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a new photo", style: .default) { (action) in
            
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let photoAction = UIAlertAction(title: "Choose from photo library", style: .default) { (action) in
            
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(photoAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func setColours(with lightColour: UIColor, and darkColour: UIColor) {
    
        navigationController?.navigationBar.tintColor = lightColour
        imageView.backgroundColor = lightColour
        navigationController?.navigationBar.barTintColor = darkColour
    
    }
}
