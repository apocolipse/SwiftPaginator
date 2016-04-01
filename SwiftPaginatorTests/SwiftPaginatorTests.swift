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
      
      paginator.receivedResults(lipsum[page - 1], total: lipsum.flatMap({ $0 }).count)
      
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
    XCTAssertEqual(lipsumPaginator.requestStatus, RequestStatus.None, "Status Failed, should be None")
    lipsumPaginator.fetchNextPage()
    XCTAssertEqual(lipsumPaginator.requestStatus, RequestStatus.Done, "Status Failed, should be Done")
  }
  
}

class SwiftPaginatorAsyncTests: XCTestCase {
  
  var lipsumPaginator: Paginator<String>!
  var fetchCallCount: Int = 0
  
  override func setUp() {
    super.setUp()
    
    fetchCallCount = 0
    // set an expectation to fulfill
    let asyncExpectation = expectationWithDescription("longRunningFunction")
    
    lipsumPaginator = Paginator<String>(pageSize: 10, fetchHandler: {
      (paginator: Paginator, page: Int, pageSize: Int) in
      self.fetchCallCount += 1
      // async for 5 seconds
      dispatch_after(dispatch_time( DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC))),
        dispatch_get_main_queue(), {
          
          paginator.receivedResults(lipsum[page - 1], total: lipsum.flatMap({ $0 }).count)
          asyncExpectation.fulfill()
      })
      
      }, resultsHandler: { (paginator, results) in })
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testAsync() {
    self.lipsumPaginator.fetchNextPage()
    self.waitForExpectationsWithTimeout(5.1) { error in
      XCTAssertNil(error, "Something went Horribly Wrong!  \(error)")
      XCTAssertEqual(self.lipsumPaginator.results, lipsum[0], "Async Results failed, should only have 1st page")
    }
  }

  func testStatus() {
    self.lipsumPaginator.fetchNextPage()
    XCTAssertEqual(self.lipsumPaginator.requestStatus, RequestStatus.InProgress, "Async Results failed, status should be InProgress")
    self.waitForExpectationsWithTimeout(5.1) { error in
      XCTAssertNil(error, "Something went Horribly Wrong!  \(error)")
      XCTAssertEqual(self.lipsumPaginator.requestStatus, RequestStatus.Done, "Async Results failed, status should be Done")
    }
  }
  
  func testWontFetchInProgress() {
    self.lipsumPaginator.fetchNextPage()
    XCTAssertEqual(fetchCallCount, 1, "Fetch Call Count failed, should be 1")

    // verify in progress
    XCTAssertEqual(self.lipsumPaginator.requestStatus, RequestStatus.InProgress, "Async Results failed, status should be InProgress")

    // call again, shouldn't increment the count
    self.lipsumPaginator.fetchNextPage()
    XCTAssertEqual(fetchCallCount, 1, "Fetch Call Count failed, should be 1")
    
    self.waitForExpectationsWithTimeout(5.1) { error in
      XCTAssertNil(error, "Something went Horribly Wrong!  \(error)")
      
      // verify done
      XCTAssertEqual(self.lipsumPaginator.requestStatus, RequestStatus.Done, "Async Results failed, status should be Done")
      
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


