//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Waiel Eid on 23/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var photoCellId = "PhotoCell"
    var pin: Pin! = nil
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    let spacingBetweenItems:CGFloat = 2
    let totalCellCount:Int = 25

    
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noPhotoLable: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
     
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: photoCellId)
//        collectionView.delegate = self
//        collectionView.dataSource = self
//
        //set flowlayout
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumLineSpacing = spacingBetweenItems
        flowLayout.minimumInteritemSpacing = spacingBetweenItems
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        
        newCollectionButton.isEnabled = true
        noPhotoLable.isHidden = true
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setFetchedResultsController()
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedInstance.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            if (fetchedResultsController.fetchedObjects?.count ?? 0) == 0 {
                newCollectionButtonAction(self)
            } else {
                processUI(process: false)
            }
        } catch {
             fatalError("Could not perform fetch: \(error.localizedDescription)")
        }
    }
    
    
    
    @IBAction func newCollectionButtonAction(_ sender: Any) {
        processUI(process: true)
        
        if (fetchedResultsController.fetchedObjects?.count ?? 0) != 0 {
            for photo in fetchedResultsController.fetchedObjects! {
                DataController.sharedInstance.viewContext.delete(photo)
            }
            try? DataController.sharedInstance.viewContext.save()
        }
        
        getFlickrImagesRandomResult(pin: pin) { flickerImages in
            if(flickerImages == nil){
                //displat error to user
                print("Error")
                return
            }
            
            for fi in flickerImages ??  [] {
                let photo = Photo(context: DataController.sharedInstance.viewContext)
                photo.imageURL = fi.imageURLString()
                photo.pin = self.pin
            }
            
            try? DataController.sharedInstance.viewContext.save()
            
            DispatchQueue.main.async {
                self.processUI(process: false)
                self.noPhotoLable.isHidden = ((flickerImages?.count ?? 0) != 0)
            }
        }
    }
        
    
    func getFlickrImagesRandomResult(pin:Pin,  completion: @escaping (_ result:[FlickrImage]?) -> Void) {
        
        var result:[FlickrImage] = []
        FlickrAPI.getFlickrImages(lat: pin.latitude, lng: pin.longitude) { (success, flickrImages) in
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

    
    func processUI(process: Bool){
        self.collectionView.isUserInteractionEnabled = !process
//self.newCollectionButton.isEnabled = !process
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        //print(fetchedResultsController.fetchedObjects?.count as Any)
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellId, for: indexPath as IndexPath) as! PhotosCollectionViewCell
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.startAnimating()
        cell.initWithPhoto(fetchedResultsController.object(at: indexPath))
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        DataController.sharedInstance.viewContext.delete(photo)
        try? DataController.sharedInstance.viewContext.save()
    }

}

extension PhotosViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert, .delete:
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        default:
            return
        }
    }
}
