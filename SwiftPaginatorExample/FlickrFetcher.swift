//
//  FlickrFetcher.swift
//  SwiftPaginator
//
//  Created by Christopher Simpson on 3/31/16.
//  Copyright © 2016 Christopher Simpson. All rights reserved.
//

import Foundation

let FlickrAPIKey = ""

enum FlickrPhotoFormat: Int {
  case square = 1
  case large = 2
  case original = 64
}

struct FlickrPhoto {
  var title: String
  var description: String
}

struct FlickrResults {
  var photos: [FlickrPhoto]
  var total: Int
}


class FlickrFetcher {
  fileprivate class func executeFlickrFetch(query aQuery: String) -> FlickrResults? {
    var query = "\(aQuery)&format=json&nojsoncallback=1&api_key=\(FlickrAPIKey)"
    query = query.addingPercentEscapes(using: String.Encoding.utf8)!
    
    
    let url = URL(string: query)!
    if let jsonData = (try? String(contentsOf: url, encoding: String.Encoding.utf8))?.data(using: String.Encoding.utf8) {
      
      let results = try? JSONSerialization.jsonObject(with: jsonData, options: [.mutableContainers, .mutableLeaves])
      if let jsonResults = results as? NSDictionary {
        if let photosObj = jsonResults["photos"] as? NSDictionary {
          let photos = photosObj["photo"] as! [NSDictionary]
          let total = Int((photosObj["total"] as AnyObject).int32Value ?? 0)
          
          // map result dictionaries to proper structs
          let flickrPhotos = photos.map { (photo) -> FlickrPhoto in
            let title: String = (photo["title"] as? String) ?? ""
            let desc: String = ((photo["description"] as? NSDictionary)?["_content"] as? String) ?? ""
            return FlickrPhoto(title: title, description: desc)
          }
          return FlickrResults(photos: flickrPhotos, total: total)
        }
      }
    }
    return nil
  }
  
  class func photosWithSearchText(_ text: String, page: Int, pageSize: Int) -> FlickrResults? {
    var request = "https://api.flickr.com/services/rest/?"
    request += "method=flickr.photos.search&extras=original_format,tags,description,geo,date_upload,owner_name,place_url"
    request += "&text=\(text)&per_page=\(pageSize)&page=\(page)"
    return FlickrFetcher.executeFlickrFetch(query: request)
  }
  
}
