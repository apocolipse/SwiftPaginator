# SwiftPaginator
[![CocoaPods](https://img.shields.io/cocoapods/v/SwiftPaginator.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/l/SwiftPaginator.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/p/SwiftPaginator.svg)]()
[![CocoaPods](https://img.shields.io/cocoapods/metrics/doc-percent/SwiftPaginator.svg)]()



SwiftPaginator is a block-based Swift class that helps manage paginated resources.
Inspired by [NMPaginator](https://github.com/nmondollot/NMPaginator), an Obj-C class.  SwiftPaginator leverages blocks and generics so that subclassing and delegates aren't needed.


## How to Install

### With Cocoapods
Add this to your Podfile:
```ruby
pod 'SwiftPaginator'
```

### Manually
Copy ``SwiftPaginator.swift`` to your project


## How to use
Although based on [NMPaginator](https://github.com/nmondollot/NMPaginator), SwiftPaginator doesn't require subclassing or delegates.  The `Paginator` class uses Generics and Blocks to handle everything for you.

### Set up a Paginator
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
### Fetch pages
Use `fetchFirstPage()` or `fetchNextPage()` to invoke a fetch.  `fetchFirstPage()` calls `reset()` then `fetchNextPage()` internally.
```swift
stringPaginator.fetchNextPage()  // Use this one for most cases
stringPaginator.fetchFirstPage() // will reset paginator
```
Details on how to define fetch behavior below in `fetchHandler`
_NOTE_: `Paginator` will not allow simultaneous requests.  Requests incoming while `paginator.requestStatus` is `.InProgress` will be ignored.

### Reset the paginator
To reset the paginator and clear all stored results, simply call:
```swift
stringPaginator.reset()
```
Details on the `resetHandler` below show how to react to a reset()

### Status
The `requestStatus` property stores an enum of type `RequestStatus` with 3 cases, `.Done`, `.InProgress`, `.None`.  Until the 1st page is fetched, the status is `.None`, after which it will be `.InProgress` while async requests are processing and `.Done` otherwise.


### Blocks Explained
All blocks have a `paginator: Paginator<T>` parameter, this is a reference to `self` called within the paginator so you may use it within the block without scope issues.
All blocks passed in the init method can be accessed and changed after initialization, i.e.
```swift
paginator.fetchHandler   = ...
paginator.resultsHandler = ...
paginator.resetHandler   = ...
paginator.failureHandler = ...

```

#### fetchHandler - Required
The `fetchHandler` block defines the behavior to fetch new pages.  It is called internally from `fetchNextPage()`.  
_NOTE_: You Must call either `paginator.receivedResults(_:total:)` or `paginator.failed()` within the `fetchHandler`.

#### resultsHandler - Required
The `resultsHandler` allows you to handle batches of new results coming in.  
Although it is required to be defined, it can be empty, i.e.
```swift
...
resultsHandler: { _ in },
...
```

_NOTE_: the `results` passed to the `resultsHandler` are the results for that specific _page_, to access all results use `paginator.results`

#### resetHandler - Optional
The `resetHandler` allows you to do things like updating the UI or other activities that must be done _after_ the data source has changed.  It is optional.

#### failureHandler - Optional
The `failureHandler` allows you to react to failures separately from the `fetchHandler`.  It isn't required, but is a decent way to split logic of fetching and reacting to failures.
