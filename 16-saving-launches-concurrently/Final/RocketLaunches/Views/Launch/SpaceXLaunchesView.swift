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

import SwiftUI

struct SpaceXLaunchesView: View {
//  @Environment(\.managedObjectContext) var viewContext
  @State var isCompleted = false
  let launchListTitle: String
  let launchList: SpaceXLaunchList

  // Technique One
//  var launchesFetchRequest: FetchRequest<SpaceXLaunch>
//  var launches: FetchedResults<SpaceXLaunch> {
//    launchesFetchRequest.wrappedValue
//  }

  let sortTypes = [
    (name: "Name", descriptors: [SortDescriptor(\SpaceXLaunch.name, order: .forward)]),
    (name: "Viewed", descriptors: [SortDescriptor(\SpaceXLaunch.isViewed, order: .forward)])
  ]

  // Technique Two
  @FetchRequest(
    sortDescriptors: [],
    animation: .default)
  var launches: FetchedResults<SpaceXLaunch>

  var body: some View {
    VStack {
      List {
        Section {
          ForEach(launches, id: \.self) { launch in
            NavigationLink(destination: SpaceXLaunchDetailView(launch: launch)) {
              LaunchStatusView(isViewed: launch.isViewed)
              Text("\(launch.name ?? "")")
            }
          }
        }
      }
      .background(Color.white)
    }
    .navigationBarTitle(Text(launchListTitle))
    .onAppear() {
      launches.nsPredicate = NSPredicate(format: "ANY spaceXList.title == %@", launchListTitle)
      launches.sortDescriptors = sortTypes[0].descriptors
    }
    .toolbar {
      Menu {
        ForEach(0..<sortTypes.count, id: \.self) { index in
          let sortType = sortTypes[index]
          Button(action: {
            launches.sortDescriptors = sortType.descriptors
          }, label: {
            Text(sortType.name)
          })
        }
      }
      label: {
        Image(systemName: "line.3.horizontal.decrease.circle.fill")
      }
    }
  }

  init(launchList: SpaceXLaunchList) {
    self.launchList = launchList
    self.launchListTitle = launchList.title ?? "No Title Found"

    // Technique One
////    let listPredicate = NSPredicate(format: "%K == %@", "list.title", launchListTitle)
//    let listPredicate = NSPredicate(format: "ANY spaceXList.title == %@", launchListTitle)
////    let isViewedPredicate = NSPredicate(format: "%K == %@", "isViewed", NSNumber(value: false))
//    let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [listPredicate/*, isViewedPredicate*/])
//
////    let prioritySortDescriptor = NSSortDescriptor(key: "priority", ascending: false)
////    let dateSortDescriptor = NSSortDescriptor(key: "launchDate", ascending: false)
//
//    self.launchesFetchRequest = FetchRequest(
//      entity: SpaceXLaunch.entity(),
//      sortDescriptors: [/*prioritySortDescriptor, dateSortDescriptor*/],
//      predicate: combinedPredicate)
  }
}

struct SpaceXLaunchesView_Previews: PreviewProvider {
  static var previews: some View {
    let context = PersistenceController.preview.container.viewContext
    let newLaunchList = SpaceXLaunchList(context: context)
    newLaunchList.title = "Preview List"
    return SpaceXLaunchesView(launchList: newLaunchList)
  }
}
