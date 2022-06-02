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
import SafariServices
import AVKit

struct SpaceXLaunchDetailView: View {
  @State private var webcastPopupVisible = false
  let launch: SpaceXLaunch
  let launchName: String?
  let launchNotes: String?
  let launchDate: Date?
  let isViewed: Bool?
  let allLists: [RocketLaunchList]
  var webcastURL: URL?
  var imageURL: URL?

  init(launch: SpaceXLaunch) {
    self.launch = launch
    self.launchName = launch.name
    self.launchNotes = launch.notes
    self.launchDate = launch.launchDate
    self.isViewed = launch.isViewed
    self.allLists = PersistenceController.getAllLists()
    if let links = launch.links,
      let webcast = links.webcast {
      webcastURL = URL(string: webcast)
    }
    if let links = launch.links,
      let patch = links.patch,
      let smallImage = patch["small"] {
      imageURL = URL(string: smallImage)
    }
  }

  var body: some View {
    return VStack {
      if let imageURL = imageURL {
        AsyncImage(url: imageURL) { phase in
          switch phase {
          case .empty:
            ProgressView()
          case .success(let image):
            image.resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxWidth: 300, maxHeight: 100)
          case .failure:
            Image(systemName: "photo")
          @unknown default:
            EmptyView()
          }
        }
      }
      Form {
        if let webcastURL = webcastURL {
          Section("Webcast") {
            Button(action: {
              self.webcastPopupVisible.toggle()
            }, label: {
              Text("Play Video")
            })
            .sheet(isPresented: $webcastPopupVisible) {
              WebcastView(url: webcastURL)
                .navigationTitle("Mission Webcast")
            }
          }
        }
        if let launchDateUTC = launch.dateUtc {
          DetailsSection(title: "Launch Date (UTC)", value: launchDateUTC)
        }
        DetailsSection(title: "Flight Number", value: "\(launch.flightNumber)")
        RedditLinks(launch: launch)
        Button(action: {
          launch.isViewed = true
        }, label: {
          Text("Mark as Viewed")
            .foregroundColor(Color.red)
        })
      }
    }
    .navigationTitle(launch.name ?? "No Name")
    .toolbar {
      Menu {
        ForEach(allLists, id: \.title) { list in
          Button(action: {
//            launch.addToList(list)
            launch.list = list
          }, label: {
            Text(list.title ?? "No list name")
          })
        }
      }
      label: {
        Image(systemName: "heart")
      }
      .disabled(allLists.isEmpty)
    }
  }
}

struct WebcastView: UIViewControllerRepresentable {
  var url: URL

  func makeUIViewController(context: Context) -> SFSafariViewController {
    SFSafariViewController(url: url)
  }

  func updateUIViewController(_ uiView: SFSafariViewController, context: Context) {
  }
}


struct DetailsSection: View {
  let title: String
  let value: String

  var body: some View {
    Section(title) {
      Text(value)
    }
  }
}

struct RedditLinks: View {
  let launch: SpaceXLaunch

  var body: some View {
    Section("Reddit Links") {
      if let redditLinks = launch.links?.reddit {
        if let launchLink = redditLinks["launch"], !launchLink.isEmpty {
          DetailsLinkSection(linkTitle: "Launch", value: launchLink)
        }
        if let launchLink = redditLinks["campaign"], !launchLink.isEmpty {
          DetailsLinkSection(linkTitle: "Campaign", value: launchLink)
        }
        if let launchLink = redditLinks["recovery"], !launchLink.isEmpty {
          DetailsLinkSection(linkTitle: "Recovery", value: launchLink)
        }
      }
    }
  }
}

struct DetailsLinkSection: View {
  let linkTitle: String
  let value: String

  var body: some View {
    // swiftlint:disable:next force_unwrapping
    Link(destination: URL(string: value)!) {
      Text(linkTitle)
    }
  }
}

struct SpaceXLaunchDetailView_Previews: PreviewProvider {
  static var previews: some View {
    if let launch = PersistenceController.getTestLaunch() {
      NavigationView {
        SpaceXLaunchDetailView(launch: launch)
      }
    } else {
      Text("Problem fetching data")
    }
  }
}
