//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Waiel Eid on 23/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import UIKit
import MapKit

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var photoCellId = "photoCell"
    var photos : [Photo]?
    var coordinates: CLLocationCoordinate2D!
    var dataController : DataController
    var fi : FlickrImage
    let spacingBetweenItems:CGFloat = 5
    let totalCellCount:Int = 25

    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noPhotoLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
        
        
        
        getFlickrImagesRandomResult { (flickrImages) in
            
            if flickrImages != nil {
                
                
                DispatchQueue.main.async {
                    self.FI = flickrImages

                    for photo in flickrImages ?? [] {
                        print(photo.imageURLString())
                    }
                }
            }
        }
    }
    

    @IBAction func newCollectionButtonAction(_ sender: Any) {
        
    }
    
    
    func getFlickrImagesRandomResult(completion: @escaping (_ result:[FlickrImage]?) -> Void) {
        
        var result:[FlickrImage] = []
        FlickrAPI.getFlickrImages(lat: coordinates.latitude, lng: coordinates.longitude) { (success, flickrImages) in
            if success {
                if flickrImages!.count > self.totalCellCount {
                    var randomArray:[Int] = []
                    
                    while randomArray.count < self.totalCellCount {
                        
                        let random = arc4random_uniform(UInt32(flickrImages!.count))
                        if !randomArray.contains(Int(random)) { randomArray.append(Int(random)) }
                    }
                    
                    for random in randomArray {
                        
                        result.append(flickrImages![random])
                    }
                    
                    completion(result)
                    
                } else {
                    
                    completion(flickrImages!)
                }
                
            } else {
                completion(nil)
                print("No images found")
            }
        }
    }
 
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellId, for: indexPath) as! PhotosCollectionViewCell
     
        
        getdate(from: imgurl){data, response, error in
            guard let data = data, error == nil else { return }
            self.imageView.image = UIImage(data: data)
        }
        
        // Configure the cell
        
        URLSession.shared.dataTask(with: imgurl) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                cell.imageView = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
        
        
        
        
        return cell
    }
    
    
//    func getData(from: String) -> Any{
//        URLSession.shared.dataTask(with: from) { data, response, error in
//            guard
//                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
//                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
//                let data = data, error == nil,
//                let image = UIImage(data: data)
//                else { return }
//            DispatchQueue.main.async() {
//                self.image = image
//            }
//            }.resume()
//    }
}
