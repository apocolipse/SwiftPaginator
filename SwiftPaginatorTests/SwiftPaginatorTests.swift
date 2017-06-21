//
//  SwiftPaginatorTests.swift
//  SwiftPaginatorTests
//
//  Created by Christopher Simpson on 3/31/16.
//  Copyright © 2016 Christopher Simpson. All rights reserved.
//

import XCTest
@testable import SwiftPaginator

let lipsum = [["Curabitur", "eros", "magna,", "varius", "ut", "metus", "non,", "iaculis", "vestibulum", "nisl."],
              ["Curabitur", "eros", "magna,", "varius", "ut", "metus", "non,", "iaculis", "vestibulum", "nisl."],
              ["Curabitur", "eros", "magna,", "varius", "ut", "metus", "non,", "iaculis", "vestibulum", "nisl."],
              ["Curabitur", "eros", "magna,", "varius", "ut", "metus", "non,", "iaculis", "vestibulum", "nisl."],
              ["Curabitur", "eros", "magna,", "varius", "ut", "metus", "non,", "iaculis"]]

class SwiftPaginatorTests: XCTestCase {
  
  var lipsumPaginator: Paginator<String>!
  override func setUp() {
    super.setUp()
    
    lipsumPaginator = Paginator<String>(pageSize: 10, fetchHandler: {
      (paginator: Paginator, page: Int, pageSize: Int) in
      
      paginator.received(results: lipsum[page - 1], total: lipsum.flatMap({ $0 }).count)
      
    },resultsHandler: { (paginator, results) in })
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testFirstPage() {
    lipsumPaginator.fetchFirstPage()
    XCTAssertEqual(lipsumPaginator.results.count, 10, "fetchFirstPage() failed, should have 10 results")
  }
  
  func testTotal() {
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.total, 48, "Total Failed, should have 48 total")
  }
  
  func testResults() {
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.results, lipsum[0], "Results failed, should only have 1st page")
    
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.results, lipsum[0] + lipsum[1], "Results failed, should only have page 1 and 2")
    
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.results, lipsum[0] + lipsum[1] + lipsum[2], "Results failed, should only have pages 1, 2, and 3")
    
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.results, lipsum[0] + lipsum[1] + lipsum[2] + lipsum[3], "Results failed, should only have pages 1, 2, 3 and 4")
    
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.results, lipsum.flatMap({ $0 }), "Results failed, should all pages")
    
    XCTAssertEqual(lipsumPaginator.results.count, lipsumPaginator.total, "Results failed, total should be 48")
  }
  
  func testStatus() {
    XCTAssertEqual(lipsumPaginator.requestStatus, RequestStatus.none, "Status Failed, should be None")
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.requestStatus, RequestStatus.done, "Status Failed, should be Done")
  }
}

class SwiftPaginatorCompletionHandlerTests: XCTestCase {
  
  var lipsumPaginator: Paginator<String>!
  var completionText: String?
  
  override func setUp() {
    super.setUp()
    
    lipsumPaginator = Paginator<String>(pageSize: 10, fetchHandler: { (paginator: Paginator, page: Int, pageSize: Int) in
      paginator.received(results: lipsum[page - 1], total: lipsum.flatMap({ $0 }).count)
    }, resultsHandler: { (paginator, results) in },
       completionHandler: { [weak self] (paginator) in
        self?.completionText = "Hey the paginator has completed!"
    })
  }
  
  func testResults() {
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.results, lipsum[0], "Results failed, should only have 1st page")
    
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.results, lipsum[0] + lipsum[1], "Results failed, should only have page 1 and 2")
    
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.results, lipsum[0] + lipsum[1] + lipsum[2], "Results failed, should only have pages 1, 2, and 3")
    
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.results, lipsum[0] + lipsum[1] + lipsum[2] + lipsum[3], "Results failed, should only have pages 1, 2, 3 and 4")
    
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.results, lipsum.flatMap({ $0 }), "Results failed, should all pages")
    
    XCTAssertEqual(lipsumPaginator.results.count, lipsumPaginator.total, "Results failed, total should be 48")
    
    //Completion handler was called at the completion of all pages fetched
    XCTAssertNotNil(completionText, "Completion handler failed to be called")
  }
  
  func testStatus() {
    XCTAssertEqual(lipsumPaginator.requestStatus, RequestStatus.none, "Status Failed, should be None")
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.requestStatus, RequestStatus.done, "Status Failed, should be Done")
  }
}

class SwiftPaginatorAsyncTests: XCTestCase {
  
  var lipsumPaginator: Paginator<String>!
  var fetchCallCount: Int = 0
  
  override func setUp() {
    super.setUp()
    
    fetchCallCount = 0
    // set an expectation to fulfill
    let asyncExpectation = expectation(description: "longRunningFunction")
    
    lipsumPaginator = Paginator<String>(pageSize: 10, fetchHandler: {
      (paginator: Paginator, page: Int, pageSize: Int) in
      self.fetchCallCount += 1
      // async for 5 seconds
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
        self.lipsumPaginator.received(results: lipsum[page - 1], total: lipsum.flatMap({ $0 }).count)
        asyncExpectation.fulfill()
      }
    }, resultsHandler: { (paginator, results) in })
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testAsync() {
    self.lipsumPaginator.fetchNextPage()
    self.waitForExpectations(timeout: 5.1) { error in
      XCTAssertNil(error, "Something went Horribly Wrong!  \(String(describing: error))")
      XCTAssertEqual(self.lipsumPaginator.results, lipsum[0], "Async Results failed, should only have 1st page")
    }
  }
  
  func testStatus() {
    self.lipsumPaginator.fetchNextPage()
    XCTAssertEqual(self.lipsumPaginator.requestStatus, RequestStatus.inProgress, "Async Results failed, status should be InProgress")
    self.waitForExpectations(timeout: 5.1) { error in
      XCTAssertNil(error, "Something went Horribly Wrong!  \(String(describing: error))")
      XCTAssertEqual(self.lipsumPaginator.requestStatus, RequestStatus.done, "Async Results failed, status should be Done")
    }
  }
  
  func testWontFetchInProgress() {
    self.lipsumPaginator.fetchNextPage()
    XCTAssertEqual(fetchCallCount, 1, "Fetch Call Count failed, should be 1")
    
    // verify in progress
    XCTAssertEqual(self.lipsumPaginator.requestStatus, RequestStatus.inProgress, "Async Results failed, status should be InProgress")
    
    // call again, shouldn't increment the count
    self.lipsumPaginator.fetchNextPage()
    XCTAssertEqual(fetchCallCount, 1, "Fetch Call Count failed, should be 1")
    
    self.waitForExpectations(timeout: 5.1) { error in
      XCTAssertNil(error, "Something went Horribly Wrong!  \(error)")
      
      // verify done
      XCTAssertEqual(self.lipsumPaginator.requestStatus, RequestStatus.done, "Async Results failed, status should be Done")
      
      // call again, should increment the count
      self.lipsumPaginator.fetchNextPage()
      XCTAssertEqual(self.fetchCallCount, 2, "Fetch Call Count failed, should be 2")
    }
  }
}

class SwiftPaginatorFailureResetTests: XCTestCase {
  
  var lipsumPaginator: Paginator<String>!
  var failureCallCount = 0
  var resetCallCount = 0
  
  override func setUp() {
    super.setUp()
    
    failureCallCount = 0
    resetCallCount = 0
    lipsumPaginator = Paginator<String>(pageSize: 10, fetchHandler: {
      (paginator: Paginator, page: Int, pageSize: Int) in
      
      paginator.failed()
      
    }, resultsHandler: { (paginator, results) in }, resetHandler: {
      paginator in
      
      self.resetCallCount += 1
    }, failureHandler: {
      paginator in
      
      self.failureCallCount += 1
    })
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testFailureCalled() {
    XCTAssertEqual(failureCallCount, 0, "Failure Call Count Failed, should be 0")
    
    lipsumPaginator.fetchNextPage()
    
    XCTAssertEqual(self.failureCallCount, 1, "Failure Call Count Failed, should be 1")
    
  }
  
  func testResetCalled() {
    XCTAssertEqual(resetCallCount, 0, "Reset Call Count Failed, should be 0")
    
    lipsumPaginator.fetchFirstPage()
    
    XCTAssertEqual(resetCallCount, 1, "Reset Call Count Failed, fetchFirstPage should call Reset handler")
    
    lipsumPaginator.reset()
    
    XCTAssertEqual(resetCallCount, 2, "Reset Call Count Failed, reset() should call Reset Handler")
    
  }
  
}


