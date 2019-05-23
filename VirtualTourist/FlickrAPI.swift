//
//  FlickerAPI.swift
//  VirtualTourist
//
//  Created by Waiel Eid on 22/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation

class FlickrAPI {
    
    private static let Endpoint  = "https://api.flickr.com/services/rest/"
    private static let APIKey    = "99ba4dcae4d0ad5a389482f69f063751"
    private static let SearchMethod = "flickr.photos.search"
    private static let format = "json"
    private static let SearcRadius = 10
    
    
    //potintial points
    //flickr.photos.search  https://www.flickr.com/services/api/flickr.photos.search.html
    //https://api.flickr.com/services/rest/?method=flickr.photos.search&name=value
    
    
    //Get Images
    
    static func getFlickrImages(lat: Double, lng: Double, completion: @escaping (_ success: Bool, _ flickrImages:[FlickrImage]?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "\(Endpoint)?method=\(SearchMethod)&format=\(format)&api_key=\(APIKey)&lat=\(lat)&lon=\(lng)&radius=\(SearcRadius)")!)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                completion(false, nil)
                return
            }
            
            let range = Range(uncheckedBounds: (14, data!.count - 1))
            let newData = data?.subdata(in: range)
            
            if let json = try? JSONSerialization.jsonObject(with: newData!) as? [String:Any],
                let photosMeta = json["photos"] as? [String:Any],
                let photos = photosMeta["photo"] as? [Any] {
                
                var flickrImages:[FlickrImage] = []
                
                for photo in photos {
                    
                    if let flickrImage = photo as? [String:Any],
                        let id = flickrImage["id"] as? String,
                        let secret = flickrImage["secret"] as? String,
                        let server = flickrImage["server"] as? String,
                        let farm = flickrImage["farm"] as? Int {
                        flickrImages.append(FlickrImage(id: id, secret: secret, server: server, farm: farm))
                    }
                }
                
                completion(true, flickrImages)
                
            } else {
                
                completion(false, nil)
            }
        }
        
        task.resume()
    }
    
    
}
