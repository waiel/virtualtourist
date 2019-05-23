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
    var FI : [FlickrImage]?
    var coordinates: CLLocationCoordinate2D!
    
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
                    
                    for photo in flickrImages ?? [] {
                        print(photo.imageURLString())
                    }
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func newCollectionButtonAction(_ sender: Any) {
        
    }
    func getFlickrImagesRandomResult(completion: @escaping (_ result:[FlickrImage]?) -> Void) {
        
        var result:[FlickrImage] = []
        FlickrAPI.getFlickrImages(lat: 26.50114964470042, lng: 44.0034172046972) { (success, flickrImages) in
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
            }
        }
    }
 
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellId, for: indexPath) as! PhotosCollectionViewCell
        
        // Configure the cell
        
        //        cell.imageView.image = FI?[indexPath].
        
        
        return cell
    }
}
