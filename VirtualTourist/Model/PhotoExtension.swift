//
//  PhotoExtension.swift
//  VirtualTourist
//
//  Created by Waiel Eid on 25/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    
}
