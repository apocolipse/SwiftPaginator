//
//  SwiftPaginator.swift
//  SwiftPaginator
//
//  Created by Christopher Simpson on 3/31/16.
//  Copyright © 2016 Christopher Simpson. All rights reserved.
//

#if os(Linux)
  import Glibc
#else
  import Darwin
#endif

/**
 RequestStatus for Paginator
 
 - None: No pages have been fetched.
 - InProgress: The paginator fetchHandler is in progress.
 - Done: All fetch calls have finished and data exists.
 */
public enum RequestStatus {
  case None, InProgress, Done
}


public class Paginator<Element> {

  /**
   Size of pages.
   */
  public var pageSize = 0
  
  /**
   Last page fetched.  Start at 0, fetch calls use page+1 and increment after.  Read-Only
   */
  public private(set) var page = 0
  
  /**
   Total number of results.  Must be set with `receivedResults(_:total:)`.  Read-Only
   */
  public private(set) var total = 0
  
  /**
   The requestStatus defines the current state of the paginator.  If .None, no pages have fetched.  
   If .InProgress, incoming `fetchNextPage()` calls are ignored.
   */
  public private(set) var requestStatus: RequestStatus = .None
  
  /**
   All results in the order they were received.
   */
  public var results: [Element] = []
  
    /// Shortcuts for the block signatures
  public typealias FetchHandlerType   = (paginator: Paginator<Element>, page: Int, pageSize: Int) -> ()
  public typealias ResultsHandler = (Paginator, [Element]) -> ()
  public typealias ResetHandler   = (Paginator) -> ()
  public typealias FailureHandler = (Paginator) -> ()

  /**
   The fetchHandler is defined by the user, it defines the behaviour for how to fetch a given page.
   NOTE: `receivedResults(_:total:)` or `failed()` must be called within.
   */
  public var fetchHandler: FetchHandlerType
  
  /**
   The resultsHandler is called by `receivedResults(_:total:)`.  It contains the Array of Elements
   for a given page.
   */
  public var resultsHandler: ResultsHandler
  
  /**
   The resetHandler is called by `reset()`.  Here you can define a callback to be called after
   the paginator has been reset.
   */
  public var resetHandler: ResetHandler?

  /**
   The failureHandler is called by `failed()`.  Here you can define a callback to be called when the
   fetchHandler fails to separate it from fetch logic.
   */
  public var failureHandler: FailureHandler?
  
  /**
   Creates a Paginator
   
   - parameter pageSize:       Size of pages
   - parameter fetchHandler:   Block to define fetch behaviour, required.  
                               NOTE: `receivedResults(_:total:)` or `failed()` must be called within.
   - parameter resultsHandler: Callback to handle new pages of resutls, required.
   - parameter resetHandler:   Callback for `reset()`, will be called after data has been reset, optional.
   - parameter failureHandler: Callback for `failure()`, will be called
   
   */
  public init(pageSize: Int,
              fetchHandler: FetchHandlerType,
              resultsHandler: ResultsHandler,
              resetHandler: ResetHandler? = nil,
              failureHandler: FailureHandler? = nil) {
    
    self.pageSize = pageSize
    self.fetchHandler = fetchHandler
    self.resultsHandler = resultsHandler
    self.failureHandler = failureHandler
    self.resetHandler = resetHandler
    self.setDefaultValues()

  }
  
  /**
   Sets default values for total, page, and results.  Called by `reset()` and `init`
   */
  private func setDefaultValues() {
    total = 0
    page = 0
    requestStatus = .None
    results = []
  }
  
  /**
   Reset the Paginator, clears all results and sets total and page to 0.
   */
  public func reset() {
    setDefaultValues()
    resetHandler?(self)
  }
  
  /**
   reachedLastPage: Bool - Boolean indicating all pages have been fetched
   */
  public var reachedLastPage: Bool {
    if requestStatus == .None {
      return false
    }
    let totalPages = ceil(Double(total) / Double(pageSize))
    return page >= Int(totalPages)
  }
  
  /**
   Fetch the first page.  If requestStatus is not .None, the paginator will be reset.
   */
  public func fetchFirstPage() {
    reset()
    fetchNextPage()
  }
  
  /**
   Fetch the next page.  If no pages are present it will fetch the first page (called by `fetchFirstPage()`
   */
  public func fetchNextPage() {
    if requestStatus == .InProgress {
      return
    }
    if !reachedLastPage {
      requestStatus = .InProgress
      fetchHandler(paginator: self, page: page + 1, pageSize: pageSize)
    }
  }
  
  /**
   Public method to be called within a `fetchHandler`.  Lets the paginator and any observers know a new chunk of 
   `Element`s are available, as well as indicates the total number of results to the paginator.
   
   - parameter results: Array of elements fetched within the fetchHandler
   - parameter total:   Total number of elements the paginator will page over.
   */
  public func receivedResults(results: [Element], total: Int) {
    self.results.appendContentsOf(results)
    self.total = total
    page += 1
    requestStatus = .Done
    
    resultsHandler(self, results)
  }
  
  /**
   Public method to be called within a `fetchHandler`.  Lets the paginator and any obervers know a fetch
   has failed.
   */
  public func failed() {
    requestStatus = .Done
    failureHandler?(self)
  }
  
}
