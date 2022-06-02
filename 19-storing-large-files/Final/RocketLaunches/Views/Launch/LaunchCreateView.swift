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
import CoreData

struct LaunchCreateView: View {
  // MARK: - Environment -
  @Environment(\.dismiss) var dismiss
  @Environment(\.managedObjectContext) var viewContext

  // MARK: - State -
  @State var name: String = ""
  @State var notes: String = ""
  @State var isViewed = false
  @State var launchDate = Date()
  @State var launchpad: String = ""
  @State var tags: String = ""
  @State var showImagePicker = false
  @State var attachment: UIImage?

  let launchList: RocketLaunchList

  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Title", text: $name)
          TextField("Launch Pad", text: $launchpad)
          TextField("Notes", text: $notes)
        }
        Section {
          TextField("Tags", text: $tags)
        }
        Section {
          DatePicker(selection: $launchDate, displayedComponents: .date) {
            Text("Date")
          }
        }
        Section {
          if let attachment = attachment {
            Image(uiImage: attachment)
              .resizable()
              .aspectRatio(contentMode: .fit)
          } else {
            Button("Pick Image") {
              showImagePicker.toggle()
            }
          }
        }
      }
      .background(Color(.systemGroupedBackground))
      .navigationBarTitle(Text("Create Event"), displayMode: .inline)
      .navigationBarItems(trailing:
        Button(action: {
          let tags = Set(self.tags.split(separator: ",").map {
            Tag.fetchOrCreateWith(title: String($0), in: self.viewContext)
          })
          RocketLaunch.createWith(
            name: self.name,
            notes: self.notes,
            launchDate: self.launchDate,
            isViewed: false,
            launchpad: self.launchpad,
            attachment: self.attachment,
            tags: tags,
            in: self.launchList,
            using: self.viewContext)
          dismiss()
        }, label: {
          Text("Save")
            .fontWeight(.bold)
        })
      )
      .sheet(isPresented: $showImagePicker) {
        ImagePicker(image: $attachment)
      }
    }
  }
}

struct ImagePicker: UIViewControllerRepresentable {
  @Environment(\.dismiss) private var dismiss
  var sourceType: UIImagePickerController.SourceType = .photoLibrary
  @Binding var image: UIImage?

  func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = false
    imagePicker.sourceType = sourceType
    imagePicker.delegate = context.coordinator

    return imagePicker
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: ImagePicker

    init(_ parent: ImagePicker) {
      self.parent = parent
    }

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        parent.image = image
      }
      parent.dismiss()
    }
  }
}

struct LaunchCreateView_Previews: PreviewProvider {
  static var previews: some View {
    let context = PersistenceController.preview.container.viewContext
    let newLaunchList = RocketLaunchList(context: context)
    newLaunchList.title = "Preview List"
    return LaunchCreateView(launchList: newLaunchList)
      .environment(\.managedObjectContext, context)
  }
}
