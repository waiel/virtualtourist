//
//  PhotosCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Waiel Eid on 22/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import UIKit


class PhotosCollectionViewCell:  UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    func initWithPhoto(_ photo: Photo) {
        
        if photo.image != nil {
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: photo.image! as Data)
                self.activityIndicator.stopAnimating()
            }
            
        } else {
            
            downloadImage(photo)
        }
    }

    func downloadImage(_ photo: Photo) {
        URLSession.shared.dataTask(with: URL(string: photo.imageURL!)!) { (data, response, error) in
            if error == nil {
                
                DispatchQueue.main.async {
                    
                    self.imageView.image = UIImage(data: data! as Data)
                    self.activityIndicator.stopAnimating()
                    self.saveImageDataToCoreData(photo: photo, imageData: data! )
                
                }
            }
            
            }
            
            .resume()
    }
    
   
    
    
    //Save Imagesns
    
    func saveImageDataToCoreData(photo: Photo, imageData: Data) {
        do {
            photo.image = imageData
           try DataController.sharedInstance.viewContext.save()
        } catch {
            print("Saving Photo imageData Failed")
        }
    }
    
}
