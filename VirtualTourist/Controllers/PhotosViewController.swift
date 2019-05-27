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

class PhotosViewController: UIViewController{
    // MARK: - Variables
    var photoCellId = "PhotoCell"
    var pin: Pin! = nil
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    let spacingBetweenItems:CGFloat = 2
    let totalCellCount:Int = 25

    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noPhotoLable: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        //set flowlayout size and dimentions
        let dimension = (self.view.frame.size.width - (2 * spacingBetweenItems)) / 3.0
        flowLayout.minimumLineSpacing = spacingBetweenItems
        flowLayout.minimumInteritemSpacing = spacingBetweenItems
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        newCollectionButton.isEnabled = true
        noPhotoLable.isHidden = true
        activityIndicator.hidesWhenStopped = true
        
        // view the selected annotation on the map
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinate
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //load the data
        setFetchedResultsController()
     }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //clear the data
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
    
    //Enable / Disable user interations
    func processUI(process: Bool){
        self.collectionView.isUserInteractionEnabled = !process
        self.newCollectionButton.isEnabled = !process
        if process {
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
    }
    
    
    // MARK: - IBActions
    @IBAction func newCollectionButtonAction(_ sender: Any) {
        processUI(process: true)
        
        if (fetchedResultsController.fetchedObjects?.count ?? 0) != 0 {
            for photo in fetchedResultsController.fetchedObjects! {
                DataController.sharedInstance.viewContext.delete(photo)
            }
            try? DataController.sharedInstance.viewContext.save()
        }
        
        FlickrAPI.getFlickrImagesRandomResult(pin: pin, totalCellCount: totalCellCount) { flickerImages in
            if(flickerImages == nil){
                //display error to user
                let alert = UIAlertController(title: "Error", message: "Error Loading images from flickr!", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                self.processUI(process: false)
                return
            }
            
            for fl in flickerImages ??  [] {
                let photo = Photo(context: DataController.sharedInstance.viewContext)
                photo.imageURL = fl.imageURLString()
                photo.pin = self.pin
            }
            
            try? DataController.sharedInstance.viewContext.save()
            
            DispatchQueue.main.async {
                self.processUI(process: false)
                //display no imaage lable if no images found
                self.noPhotoLable.isHidden = ((flickerImages?.count ?? 0) != 0)
            }
        }
    }
}

// MARK: - Extensions
extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellId, for: indexPath as IndexPath) as! PhotosCollectionViewCell
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.center = CGPoint(x: cell.contentView.frame.size.width / 2, y: cell.contentView.frame.size.height / 2)
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
