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

struct LaunchDetailView: View {
  @Environment(\.managedObjectContext) var viewContext
  let launch: RocketLaunch
  let launchName: String?
  let launchNotes: String?
  let launchDate: Date?
  let isViewed: Bool?

  init(launch: RocketLaunch) {
    self.launch = launch
    self.launchName = launch.name
    self.launchNotes = launch.notes
    self.launchDate = launch.launchDate
    self.isViewed = launch.isViewed
  }

  var body: some View {
    Form {
      Section("Notes") {
        Text(launchNotes ?? "No Notes")
      }
      if let launchDate = launchDate {
        Section("Launch Date") {
          Text(launchDate.formatted())
        }
      }
      Section {
        Button("Mark as Viewed") {
          self.launch.isViewed = true
          do {
            try viewContext.save()
          } catch {
            print("Error marking launch as viewed \(error)")
          }
        }
      }
    }
    .navigationTitle(self.launchName ?? "Sample Launch")
    .background(Color(.systemGroupedBackground))
  }
}

struct LaunchDetailView_Previews: PreviewProvider {
  static var previews: some View {
    let context = PersistenceController.preview.container.viewContext
    let newLaunch = RocketLaunch(context: context)
    newLaunch.name = "Some launch"
    newLaunch.notes = "Here are the notes"
    newLaunch.launchDate = Date()
    return LaunchDetailView(launch: newLaunch)
  }
}
