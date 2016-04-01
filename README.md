# SwiftPaginator

SwiftPaginator is a block-based Swift class that helps manage paginated resources.
Inspired by [NMPaginator](https://github.com/nmondollot/NMPaginator), an Obj-C class.  SwiftPaginator leverages blocks and generics so that subclassing and delegates aren't needed.


## Usage
To set up a paginator
```swift
import SwiftPaginator

let source = [["one", "two", "three", "four"]]

let stringPaginator = Paginator<String>(pageSize: 2, fetchHandler: {
      (paginator: Paginator, page: Int, pageSize: Int) in

      // implement how to fetch results, must call paginator.receivedResults(_:total:) or paginator.failed()
      if page < source.count {
        paginator.receivedResults(source[page], total: 4)
      } else {
        paginator.failed()
      }

    }, resultsHandler: { (paginator, results) in
        // Handle results
        print(results) // results for the given page
        print(paginator.results) // all results

    }, resetHandler: { (paginator) in
        // callback for a reset, Optional
        tableView.reloadData()
    }, failureHandler: { (paginator) in
        // callback for a failure, Optional
        self.presentFailureAlert()
    })
```
