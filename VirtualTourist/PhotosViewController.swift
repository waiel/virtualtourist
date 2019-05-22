//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Waiel Eid on 22/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation
import UIKit

class PhotosViewController: UICollectionViewController {
    
    var photoCellId = "photoCell"
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func newCollectionButtonAction(_ sender: Any) {
        
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellId, for: indexPath) as! PhotosCollectionViewCell
        
        // Configure the cell
     
        
        
        return cell
    }

}
