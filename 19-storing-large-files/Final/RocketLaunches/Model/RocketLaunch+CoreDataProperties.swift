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
import SwiftUI
import UIKit

extension RocketLaunch {
  static func createWith(
    name: String,
    notes: String,
    launchDate: Date,
    isViewed: Bool,
    launchpad: String,
    attachment: UIImage?,
    tags: Set<Tag> = [],
    in list: RocketLaunchList,
    using managedObjectContext: NSManagedObjectContext
  ) {
    let launch = RocketLaunch(context: managedObjectContext)
    launch.name = name
    launch.notes = notes
    launch.launchDate = launchDate
    launch.isViewed = isViewed
    launch.launchpad = launchpad
    launch.attachment = attachment?.jpegData(compressionQuality: 1) ?? Data()
    launch.tags = tags
    launch.addToList(list)

    do {
      try managedObjectContext.save()
    } catch {
      let nserror = error as NSError
      fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }

  static func basicFetchRequest() -> FetchRequest<RocketLaunch> {
    return FetchRequest<RocketLaunch>(entity: RocketLaunch.entity(), sortDescriptors: [])
  }

  static func sortedFetchRequest() -> FetchRequest<RocketLaunch> {
    let launchDateSortDescriptor = NSSortDescriptor(key: "launchDate", ascending: true)
    return FetchRequest(entity: RocketLaunch.entity(), sortDescriptors: [launchDateSortDescriptor])
  }

  static func fetchRequestSortedByNameAndLaunchDate() -> FetchRequest<RocketLaunch> {
    let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
    let launchDateSortDescriptor = NSSortDescriptor(key: "launchDate", ascending: true)
    return FetchRequest(entity: RocketLaunch.entity(), sortDescriptors: [nameSortDescriptor, launchDateSortDescriptor])
  }

  static func unViewedLaunchesFetchRequest() -> FetchRequest<RocketLaunch> {
    let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
    let launchDateSortDescriptor = NSSortDescriptor(key: "launchDate", ascending: false)
    let isViewedPredicate = NSPredicate(format: "%K == %@", "isViewed", NSNumber(value: false))
    return FetchRequest(
      entity: RocketLaunch.entity(),
      sortDescriptors: [nameSortDescriptor, launchDateSortDescriptor],
      predicate: isViewedPredicate)
  }

  static func launches(in list: RocketLaunchList) -> FetchRequest<RocketLaunch> {
    let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
    let launchDateSortDescriptor = NSSortDescriptor(key: "launchDate", ascending: false)
    let listPredicate = NSPredicate(format: "%K == %@", "list.title", list.title!)
    let isViewedPredicate = NSPredicate(format: "%K == %@", "isViewed", NSNumber(value: false))
    let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [listPredicate, isViewedPredicate])
    return FetchRequest(
      entity: RocketLaunch.entity(),
      sortDescriptors: [nameSortDescriptor, launchDateSortDescriptor],
      predicate: combinedPredicate)
  }

  @NSManaged public var name: String?
  @NSManaged public var isViewed: Bool
  @NSManaged public var launchDate: Date?
  @NSManaged public var launchpad: String?
  @NSManaged public var notes: String?
  @NSManaged public var list: Set<RocketLaunchList>
  @NSManaged var tags: Set<Tag>?
  @NSManaged public var attachment: Data?
}

// MARK: Generated accessors for list
extension RocketLaunch {
  @objc(addListObject:)
  @NSManaged public func addToList(_ value: RocketLaunchList)

  @objc(removeListObject:)
  @NSManaged public func removeFromList(_ value: RocketLaunchList)

  @objc(addList:)
  @NSManaged public func addToList(_ values: NSSet)

  @objc(removeList:)
  @NSManaged public func removeFromList(_ values: NSSet)
}

extension RocketLaunch: Identifiable {
}
