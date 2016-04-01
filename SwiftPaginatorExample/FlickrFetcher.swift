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
  case Square = 1
  case Large = 2
  case Original = 64
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
  private class func executeFlickrFetch(query aQuery: String) -> FlickrResults? {
    var query = "\(aQuery)&format=json&nojsoncallback=1&api_key=\(FlickrAPIKey)"
    query = query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    
    let url = NSURL(string: query)!
    if let jsonData = (try? String(contentsOfURL: url, encoding: NSUTF8StringEncoding))?.dataUsingEncoding(NSUTF8StringEncoding) {
      
      let results = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: [.MutableContainers, .MutableLeaves])
      if let jsonResults = results as? NSDictionary {
        if let photosObj = jsonResults["photos"] as? NSDictionary {
          let photos = photosObj["photo"] as! [NSDictionary]
          let total = Int(photosObj["total"]?.intValue ?? 0)
          
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
  
  class func photosWithSearchText(text: String, page: Int, pageSize: Int) -> FlickrResults? {
    var request = "https://api.flickr.com/services/rest/?"
    request += "method=flickr.photos.search&extras=original_format,tags,description,geo,date_upload,owner_name,place_url"
    request += "&text=\(text)&per_page=\(pageSize)&page=\(page)"
    return FlickrFetcher.executeFlickrFetch(query: request)
  }
  
}