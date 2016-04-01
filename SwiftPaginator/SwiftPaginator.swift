//
//  SwiftPaginator.swift
//  SwiftPaginator
//
//  Created by Christopher Simpson on 3/31/16.
//  Copyright © 2016 Christopher Simpson. All rights reserved.
//

public enum RequestStatus {
  case None, InProgress, Done
}

public class Paginator<Element> {

  public var pageSize = 0
  public var page = 0
  public var total = 0
  public var requestStatus: RequestStatus = .None
  public var results: [Element] = []
  
  
  public typealias FetchHandlerType   = (paginator: Paginator<Element>, page: Int, pageSize: Int) -> ()
  public typealias ResultsHandler = (Paginator, [Element]) -> ()
  public typealias FailureHandler = (Paginator) -> ()
  public typealias ResetHandler   = (Paginator) -> ()

  public var fetchHandler: FetchHandlerType
  public var resultsHandler: ResultsHandler
  public var failureHandler: FailureHandler?
  public var resetHandler: ResetHandler?
  
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
  
  private func setDefaultValues() {
    total = 0
    page = 0
    results = []
  }
  
  public func reset() {
    setDefaultValues()
    resetHandler?(self)
  }
  
  public var reachedLastPage: Bool {
    if requestStatus == .None {
      return false
    }
    let totalPages = ceil(Float(total) / Float(pageSize))
    return page >= Int(totalPages)
  }
  
  public func fetchFirstPage() {
    reset()
    fetchNextPage()
  }
  
  public func fetchNextPage() {
    if requestStatus == .InProgress {
      return
    }
    if !reachedLastPage {
      requestStatus = .InProgress
      fetchHandler(paginator: self, page: page + 1, pageSize: pageSize)
    }
  }
  
  
  public func receivedResults(results: [Element], total: Int) {
    self.results.appendContentsOf(results)
    self.total = total
    page += 1
    requestStatus = .Done
    
    resultsHandler(self, results)
  }
  
  public func failed() {
    requestStatus = .Done
    failureHandler?(self)
  }
  
}
