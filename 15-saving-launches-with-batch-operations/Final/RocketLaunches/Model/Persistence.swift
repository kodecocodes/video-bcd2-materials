/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import CoreData

enum LaunchError: Error {
  case batchInsertError
}

struct PersistenceController {
  static let shared = PersistenceController()

  static var preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext

    for i in 0..<10 {
      let newLaunch = RocketLaunch(context: viewContext)
      newLaunch.launchDate = Date()
      newLaunch.name = "Launch \(i + 1)"
      let newList = RocketLaunchList(context: viewContext)
      newList.title = "Sample List"
      //      newLaunch.addToList(newList)
      newLaunch.list = newList
    }

    let launchLinks = SpaceXLinks(context: viewContext)
    launchLinks.patch = [:]
    launchLinks.patch?["small"] = "https://imgur.com/BrW201S.png"
    launchLinks.patch?["large"] = "https://imgur.com/573IfGk.png"

    launchLinks.reddit = [:]
    launchLinks.reddit?["campaign"] = "https://www.reddit.com/r/spacex/comments/jhu37i/starlink_general_discussion_and_deployment_thread/"
    launchLinks.reddit?["launch"] = "https://www.reddit.com/r/spacex/comments/t0yksi/rspacex_starlink_411_launch_discussion_and/"
    launchLinks.reddit?["media"] = nil
    launchLinks.reddit?["recovery"] = "https://www.reddit.com/r/spacex/comments/k2ts1q/rspacex_fleet_updates_discussion_thread/"

    launchLinks.flickr = [:]
    launchLinks.flickr?["small"] = []
    launchLinks.flickr?["original"] = []

    launchLinks.presskit = nil
    launchLinks.webcast = "https://youtu.be/nnVOfKOzXHE"
    launchLinks.youtubeid = "nnVOfKOzXHE"
    launchLinks.article = nil
    launchLinks.wikipedia = "https://en.wikipedia.org/wiki/Starlink"

    let spaceXLaunch = SpaceXLaunch(context: viewContext)
    spaceXLaunch.name = "Starlink 4-11 (v1.5)"
    spaceXLaunch.links = launchLinks
    spaceXLaunch.dateUtc = "2022-02-25T17:12:00.000Z"
    spaceXLaunch.flightNumber = 151

    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    return result
  }()

  let container: NSPersistentContainer

  init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "RocketLaunches")
    if inMemory {
      // swiftlint:disable:next force_unwrapping
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    container.viewContext.automaticallyMergesChangesFromParent = true

    container.viewContext.name = "viewContext"
    /// - Tag: viewContextMergePolicy
    container.viewContext.mergePolicy =
    NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.undoManager = nil
    container.viewContext.shouldDeleteInaccessibleFaults = true
  }

  static func fetchSpaceXLaunches() async throws {
    let launches = try await SpaceXAPI.getAllLaunches()
    do {
      try PersistenceController.shared.importLaunches(from: launches, to: "All")
    } catch {
      print("error is \(error)")
    }

    let upcomingLaunches = try await SpaceXAPI.getUpcomingLaunches()
    do {
      try PersistenceController.shared.importLaunches(from: upcomingLaunches, to: "Upcoming")
    } catch {
      print("error is \(error)")
    }

    let pastLaunches = try await SpaceXAPI.getPastLaunches()
    do {
      try PersistenceController.shared.importLaunches(from: pastLaunches, to: "Past")
    } catch {
      print("error is \(error)")
    }

    let latestLaunches = try await SpaceXAPI.getLatestLaunch()
    do {
      try PersistenceController.shared.importLaunches(from: latestLaunches, to: "Latest")
    } catch {
      print("error is \(error)")
    }
  }

  static func createSpaceXLaunchLists() async throws {
    let context = shared.container.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    try await context.perform {
      let fetchRequest = SpaceXLaunchList.fetchRequest()
      fetchRequest.predicate = NSPredicate(format: "title == %@", ["All"])
      var results = try context.fetch(fetchRequest)
      if results.isEmpty {
        let list = SpaceXLaunchList(context: context )
        list.title = "All"
      }

      fetchRequest.predicate = NSPredicate(format: "title == %@", ["Upcoming"])
      results = try context.fetch(fetchRequest)
      if results.isEmpty {
        let list = SpaceXLaunchList(context: context )
        list.title = "Upcoming"
      }
      fetchRequest.predicate = NSPredicate(format: "title == %@", ["Past"])
      results = try context.fetch(fetchRequest)
      if results.isEmpty {
        let list = SpaceXLaunchList(context: context )
        list.title = "Past"
      }
      fetchRequest.predicate = NSPredicate(format: "title == %@", ["Latest"])
      results = try context.fetch(fetchRequest)
      if results.isEmpty {
        let list = SpaceXLaunchList(context: context )
        list.title = "Latest"
      }
      try context.save()
    }
  }

  static func getAllLists() -> [RocketLaunchList] {
    let fetchRequest = RocketLaunchList.fetchRequest()
    guard let results = try? shared.container.viewContext.fetch(fetchRequest),
          !results.isEmpty else { return [] }
    return results as [RocketLaunchList]
  }

  static func getTestLaunch() -> SpaceXLaunch? {
    let fetchRequest = SpaceXLaunch.fetchRequest()
    fetchRequest.fetchLimit = 1
    guard let results = try? preview.container.viewContext.fetch(fetchRequest),
          let first = results.first else { return nil }
    return first
  }

  /// Imports the JSON based launches into Core Data via the background context
  /// - Parameter launchCollection: the array of `SpaceXLaunchJSON` structs for the available launches
  func importLaunches(from launchCollection: [SpaceXLaunchJSON], to listName: String) throws {
    let taskContext = container.viewContext
    print("number of launches \(launchCollection.count)")
    // get the relationships so we can set them later, retaining the launch id
    let fairings = launchCollection.map { ($0.id, $0.fairings) }
    let links = launchCollection.map { ($0.id, $0.links) }

    // Fetch the lists of SpaceX launches
    // swiftlint:disable:next implicitly_unwrapped_optional
    var list: SpaceXLaunchList!
    let fetchRequest = SpaceXLaunchList.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "title == %@", listName)
    let results = try taskContext.fetch(fetchRequest)
    if let fetchedList = results.first {
      list = fetchedList
    }


    // Insert the launches into the database
    // Use a batch insert request to add the launches
    let batchInsertRequest = createBatchInsertLaunchRequest(from: launchCollection)
    if let fetchResult = try? taskContext.execute(batchInsertRequest),
       let batchInsertResult = fetchResult as? NSBatchInsertResult,
       let success = batchInsertResult.result as? Bool, success {
      return
    } else {
      throw LaunchError.batchInsertError
    }

    // Add the fairings to the database
    // Use a batch insert request to add the fairings
    let batchInsertRequest2 = createBatchInsertRelationshipRequest(from: fairings, for: SpaceXFairings.self)
    if let fetchResult = try? taskContext.execute(batchInsertRequest2),
       let batchInsertResult = fetchResult as? NSBatchInsertResult,
       let success = batchInsertResult.result as? Bool, success {
      return
    } else {
      throw LaunchError.batchInsertError
    }

    // Setup the fairing relationships
    for (id, fairing) in fairings {
      guard let fairing = fairing else { continue }
      let fairingFetchRequest = SpaceXFairings.fetchRequest()
      fairingFetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [fairing.id])

      let launchFetchRequest = SpaceXLaunch.fetchRequest()
      launchFetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [id])

      let returnedFairing = try taskContext.fetch(fairingFetchRequest) as [SpaceXFairings]
      let launch = try taskContext.fetch(launchFetchRequest) as [SpaceXLaunch]
      guard !returnedFairing.isEmpty, !launch.isEmpty else { continue }
      let matchedFairing = returnedFairing[0]
      let matchedLaunch = launch[0]
      matchedFairing.launch = matchedLaunch
    }
    try taskContext.save()

    // Add the links to the database
    // Use a batch insert request to add the links
    let batchInsertRequest3 = createBatchInsertRelationshipRequest(from: links, for: SpaceXLinks.self)
    if let fetchResult = try? taskContext.execute(batchInsertRequest3),
       let batchInsertResult = fetchResult as? NSBatchInsertResult,
       let success = batchInsertResult.result as? Bool, success {
      return
    } else {
      throw LaunchError.batchInsertError
    }


    // Setup the link relationships
    for (id, links) in links {
      let linksFetchRequest = SpaceXLinks.fetchRequest()
      linksFetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [links.id])

      let launchFetchRequest = SpaceXLaunch.fetchRequest()
      launchFetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [id])

      let returnedLinks = try taskContext.fetch(linksFetchRequest) as [SpaceXLinks]
      let launch = try taskContext.fetch(launchFetchRequest) as [SpaceXLaunch]
      guard !returnedLinks.isEmpty, !launch.isEmpty else { continue }
      returnedLinks[0].launch = launch[0]
      launch[0].addToSpaceXList(list)
    }

  }

  private func createBatchInsertLaunchRequest(from launchCollection: [SpaceXLaunchJSON]) -> NSBatchInsertRequest {
    var index = 0
    let total = launchCollection.count

    // Provide one dictionary at a time when the closure is called.
    // swiftlint:disable:next trailing_closure
    let batchInsertRequest = NSBatchInsertRequest(entity: SpaceXLaunch.entity(), dictionaryHandler: { dictionary in
      guard index < total else { return true }
      dictionary.addEntries(from: launchCollection[index].dictionaryValue as [AnyHashable: Any])
      index += 1
      return false
    })
    return batchInsertRequest
  }

  private func createBatchInsertRelationshipRequest<T: BatchInsertable, E: NSManagedObject>(from relationshipCollection: [(String, T?)], for type: E.Type) -> NSBatchInsertRequest {
    var index = 0
    let total = relationshipCollection.count

    // Provide one dictionary at a time when the closure is called.
    // swiftlint:disable:next trailing_closure
    let batchInsertRequest = NSBatchInsertRequest(entity: E.entity(), dictionaryHandler: { dictionary in
      guard index < total else { return true }
      guard let value = relationshipCollection[index].1 else { index += 1; return false }
      dictionary.addEntries(from: value.dictionaryValue as [AnyHashable: Any])
      index += 1
      return false
    })

    return batchInsertRequest
  }
}
