//
//  AddPhotoView.swift
//  NetterForget
//
//  Created by Cathal Farrell on 16/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI
import MapKit

struct AddPhotoView: View {

    @Binding var contact: Contact

    @Environment(\.presentationMode) var presentationMode

    //Image Picker
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? //selected from library
    @State private var image: Image? //displayed in view

    // MapView
    @State var centerCoordinate = CLLocationCoordinate2D()

    var body: some View {
        NavigationView {
            VStack {
                Section {
                    VStack{
                        TextField("Enter contact name", text: $contact.name)
                        .padding(20)
                        .font(.headline)
                    }
                }
                Section {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary)

                        // display the image
                        if image != nil {
                            image?
                                .resizable()
                                .scaledToFit()
                        } else {
                            Text("Tap to select a picture")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                    .onTapGesture {
                        self.showingImagePicker = true
                    }
                }
                Section {
                    MapView(centerCoordinate: $centerCoordinate, annotation: contact.locationAnnotation)
                }
            }
            .navigationBarTitle("Add Contact")
            .navigationBarItems(trailing: Button("Done") {
                self.presentationMode.wrappedValue.dismiss()
            })

            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
        }
    }

    func loadImage() {
        print("Load image...")

        guard let input = self.inputImage else {
            return
        }
        
        image = Image(uiImage: input)
        self.contact.image = input
    }
}

struct AddPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddPhotoView(contact: .constant(Contact(name: "Cathal", id: "\(UUID())", image: nil)))
        }
    }
}
