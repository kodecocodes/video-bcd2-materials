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
//

import Foundation
import CoreData


extension RocketLaunchList {
  static func create(withTitle title: String, in managedObjectContext: NSManagedObjectContext) {
    let newLaunchList = self.init(context: managedObjectContext)
    newLaunchList.title = title

    do {
      try managedObjectContext.save()
    } catch {
      let nserror = error as NSError
      fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }

  @nonobjc
  public class func fetchRequest() -> NSFetchRequest<RocketLaunchList> {
    return NSFetchRequest<RocketLaunchList>(entityName: "RocketLaunchList")
  }

  @NSManaged public var title: String?
  @NSManaged public var launches: [RocketLaunch]
}

// MARK: Generated accessors for launches
extension RocketLaunchList {
  @objc(insertObject:inLaunchesAtIndex:)
  @NSManaged public func insertIntoLaunches(_ value: RocketLaunch, at idx: Int)

  @objc(removeObjectFromLaunchesAtIndex:)
  @NSManaged public func removeFromLaunches(at idx: Int)

  @objc(insertLaunches:atIndexes:)
  @NSManaged public func insertIntoLaunches(_ values: [RocketLaunch], at indexes: NSIndexSet)

  @objc(removeLaunchesAtIndexes:)
  @NSManaged public func removeFromLaunches(at indexes: NSIndexSet)

  @objc(replaceObjectInLaunchesAtIndex:withObject:)
  @NSManaged public func replaceLaunches(at idx: Int, with value: RocketLaunch)

  @objc(replaceLaunchesAtIndexes:withLaunches:)
  @NSManaged public func replaceLaunches(at indexes: NSIndexSet, with values: [RocketLaunch])

  @objc(addLaunchesObject:)
  @NSManaged public func addToLaunches(_ value: RocketLaunch)

  @objc(removeLaunchesObject:)
  @NSManaged public func removeFromLaunches(_ value: RocketLaunch)

  @objc(addLaunches:)
  @NSManaged public func addToLaunches(_ values: NSOrderedSet)

  @objc(removeLaunches:)
  @NSManaged public func removeFromLaunches(_ values: NSOrderedSet)
}

extension RocketLaunchList: Identifiable {
}
