//
//  FlickrImage.swift
//  VirtualTourist
//
//  Created by Waiel Eid on 23/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation
import CoreData

class FlickrImage {
    
    let id:String
    let secret:String
    let server:String
    let farm:Int
    
    init(id: String, secret: String, server: String, farm: Int) {
        
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
    }
    
    func imageURLString() -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
    }
    
}
