//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Waiel Eid on 21/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController {
    // MARK: - Varisalbes
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var dataController : DataController {
        return DataController.sharedInstance
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

         mapView.delegate = self
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressRecogniser)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setFetchResultController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // Load Data
    func setFetchResultController (){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            updateMap()
        } catch {
            fatalError("Could not perform fetch: \(error.localizedDescription)")
        }
    }
    
    
    // update the annotiation on the map
    func updateMap() {
        guard let pins = fetchedResultsController.fetchedObjects else { return }
     
        for pin in pins {
            if mapView.annotations.contains(where: { pin.compare(to: $0.coordinate)}){
                continue
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            if (self.mapView.view(for: annotation) == nil) {
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    // long press add a annotiation on the map
    @objc func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print(coordinate)
        let pin = Pin(context: dataController.viewContext)
        pin.coordinate = coordinate

        try? dataController.viewContext.save()
    }
    
    // transfer data to second view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotos" {
            let pvc = segue.destination as! PhotosViewController
            pvc.pin = fetchedResultsController.fetchedObjects?.filter { pin in pin.compare(to: mapView.selectedAnnotations.first!.coordinate) }.first!
           
        }
    }


}
// MARK: - Extensions
extension MapViewController: MKMapViewDelegate {
    // configure annotiation look
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.tintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }else{
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    //open photos view when slecting annotiation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ShowPhotos", sender: view.annotation?.coordinate)
        }
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate{
    //update the map whenever data is cheanged 
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateMap()
    }
}
