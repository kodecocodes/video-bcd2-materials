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

struct LaunchesView: View {
  @State var isShowingCreateModal = false
  @State var activeSortIndex = 0
  let launchesFetchRequest = RocketLaunch.unViewedLaunchesFetchRequest()
  var launches: FetchedResults<RocketLaunch> {
    launchesFetchRequest.wrappedValue
  }

  let sortTypes = [
    (name: "Name", descriptors: [SortDescriptor(\RocketLaunch.name, order: .forward)]),
    (name: "LaunchDate", descriptors: [SortDescriptor(\RocketLaunch.launchDate, order: .forward)])
  ]

  var body: some View {
    VStack {
      List {
        Section {
          ForEach(launches, id: \.self) { launch in
            NavigationLink(destination: LaunchDetailView(launch: launch)) {
              HStack {
                LaunchStatusView(isViewed: launch.isViewed)
                Text("\(launch.name ?? "")")
                Spacer()
              }
            }
          }
        }
      }
      .background(Color.white)
      HStack {
        NewLaunchButton(isShowingCreateModal: $isShowingCreateModal)
        Spacer()
      }
      .padding(.leading)
    }
    .navigationBarTitle(Text("Launches"))
    .onChange(of: activeSortIndex) { _ in
      launches.sortDescriptors = sortTypes[activeSortIndex].descriptors
    }
    .toolbar {
      Menu(content: {
        Picker(
          selection: $activeSortIndex,
          content: {
            ForEach(0..<sortTypes.count, id: \.self) { index in
              let sortType = sortTypes[index]
              Text(sortType.name)
            }
          },
          label: {}
        )
      }, label: {
        Image(systemName: "line.3.horizontal.decrease.circle.fill")
      })
    }
  }
}

struct LaunchesView_Previews: PreviewProvider {
  static var previews: some View {
    let context = PersistenceController.preview.container.viewContext
    let newLaunch = RocketLaunch(context: context)
    newLaunch.name = "A really cool launch!"
    return LaunchesView()
  }
}

struct NewLaunchButton: View {
  @Binding var isShowingCreateModal: Bool

  var body: some View {
    Button(
      action: { self.isShowingCreateModal.toggle() },
      label: {
        Image(systemName: "plus.circle.fill")
          .foregroundColor(.red)
        Text("New Launch")
          .font(.headline)
          .foregroundColor(.red)
      })
    .sheet(isPresented: $isShowingCreateModal) {
      LaunchCreateView()
    }
  }
}
