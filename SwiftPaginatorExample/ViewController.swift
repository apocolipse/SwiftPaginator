//
//  ViewController.swift
//  SwiftPaginatorExample
//
//  Created by Christopher Simpson on 3/31/16.
//  Copyright © 2016 Christopher Simpson. All rights reserved.
//

import UIKit
import SwiftPaginator


class ViewController: UITableViewController {

  var flickrPaginator: Paginator<FlickrPhoto>?
  var activityIndicator: UIActivityIndicatorView!
  var footerLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // in case you don't read the readme file
    if FlickrAPIKey.characters.count == 0 {
      let alertVC = UIAlertController(title: "Empty API Key",
                                      message: "You need to set FlickrAPIKey in FlickrFetcher.swift to test this app",
                                      preferredStyle: .Alert)
      
      self.presentViewController(alertVC, animated: true, completion: nil)
    }
    self.title = "Flickr Photos"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: #selector(ViewController.clearButtonPressed(_:)))
    
    self.setupTableViewFooter()
    
    // Set up the paginator
    flickrPaginator = Paginator<FlickrPhoto>(pageSize: 15, fetchHandler: {
      (paginator: Paginator, page: Int, pageSize: Int) in

      // do request on async thread
      let fetchQ = dispatch_queue_create("Flickr fetcher", nil)
      dispatch_async(fetchQ, {
        let results = FlickrFetcher.photosWithSearchText("paginator", page: page, pageSize: pageSize)
        print(results)
        // go back to main thread before adding results
        dispatch_async(dispatch_get_main_queue(), {

          paginator.receivedResults(results?.photos ?? [], total: results?.total ?? 0)
        })
      })
      
    }, resultsHandler: {
      (paginator, results) in
      
      // update tableview footer
      self.updateTableViewFooter()
      self.activityIndicator.stopAnimating()
      
      var indexPaths = [NSIndexPath]()
      var i = (paginator.results.count ?? 0) - results.count
      for _ in results {
        indexPaths.append(NSIndexPath(forRow: i, inSection: 0))
        i += 1
      }
      self.tableView.beginUpdates()
      self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Middle)
      self.tableView.endUpdates()
    
    }, resetHandler: {
      (paginator) in
      self.tableView.reloadData()
      self.updateTableViewFooter()
    })
    
    self.flickrPaginator?.fetchFirstPage()
    
  }

  func clearButtonPressed(sender: UIButton) {
    
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.flickrPaginator?.results.count ?? 0
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("CellID")
    if cell == nil {
      cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "CellID")
    }
    
    let photo = self.flickrPaginator?.results[indexPath.row]
    if photo?.title.characters.count == 0 {
      cell?.textLabel?.text = "<no title>"
    } else {
      cell?.textLabel?.text = photo?.title
    }
    cell?.detailTextLabel?.text = photo?.description
    return cell!
  }
  
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    //super.scrollViewDidScroll(scrollView)
    
    // when reaching bottom, load a new page
    if scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height {
      // ask next page only if we haven't reached last page
      if self.flickrPaginator?.reachedLastPage == false {
        // fetch next page of results
        self.flickrPaginator?.fetchNextPage()
      }
    }
  }
  
  func fetchNextPage() {
    self.flickrPaginator?.fetchNextPage()
    self.activityIndicator.startAnimating()
  }
  
  func setupTableViewFooter() {
    // set up label
    let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44.0))
    footerView.backgroundColor = UIColor.clearColor()

    let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44.0))
    label.font = UIFont.boldSystemFontOfSize(16)
    label.textColor = UIColor.lightGrayColor()
    label.textAlignment = .Center;
    
    self.footerLabel = label
    footerView.addSubview(label)
    
    // set up activity indicator
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    activityIndicatorView.center = CGPoint(x: 40, y:22)
    activityIndicatorView.hidesWhenStopped = true
    
    self.activityIndicator = activityIndicatorView;
    footerView.addSubview(activityIndicatorView)
    
    self.tableView.tableFooterView = footerView;

  }
  
  func updateTableViewFooter() {
    if self.flickrPaginator?.results.count != 0 {
      self.footerLabel.text = "\(self.flickrPaginator?.results.count ?? 0) results out of \(self.flickrPaginator?.total ?? 0)"
    } else {
      self.footerLabel.text = ""
    }
    self.footerLabel.setNeedsDisplay()
  }
}

