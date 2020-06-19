//
//  ContentView.swift
//  NetterForget
//
//  Created by Cathal Farrell on 15/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @State private var showingAddContactScreen = false
    // Made un-private simple to see the canvas preview
    @State var newContact = Contact()
    @State var contactList = [Contact]()

    let locationFetcher = LocationFetcher()

    var body: some View {
        NavigationView {
            List {
                ForEach(self.contactList, id: \.self) { contact in
                    NavigationLink(destination: DetailView(contact: contact, centerCoordinate: contact.location)) {
                        HStack {
                            Image(uiImage: contact.image ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.primary, lineWidth: 1))
                            Text(contact.name)
                        }
                    }
                }
                .onDelete(perform: deleteBooks)
            }
            .navigationBarTitle("Never Forget")
            .navigationBarItems(leading: EditButton(), trailing:
                Button("Add Contact") {
                    self.newContact = Contact() //Ensures new contact each time
                    self.showingAddContactScreen = true
            })
        }
        .sheet(isPresented: $showingAddContactScreen, onDismiss: saveData) {
            AddPhotoView(contact: self.$newContact, centerCoordinate: self.locationFetcher.getLocation())

        }
        .onAppear(perform: loadData) //loads any saved data on launch
    }

    func deleteBooks(at offsets: IndexSet) {

        let sortedList = contactList.sorted()

        for offset in offsets {
            let contactAtOffset = sortedList[offset]
            self.contactList.removeAll { (contact) -> Bool in
                contact.name == contactAtOffset.name
            }
        }

        saveData()
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func loadData() {

        startFetchingLocation()

        //If no data see if there is any to restore
        print("🔥 Data found before loading: \(self.contactList.count)")

        guard self.contactList.count > 0 else {

            do {
                let filename = getDocumentsDirectory().appendingPathComponent("SavedContacts")

                let data = try Data(contentsOf: filename)
                print("🔥 Checking filename: \(filename) for saved locations")
                let storedContacts = try JSONDecoder().decode([Contact].self, from: data)
                //Load images
                for contact in storedContacts {
                    var updadeContact = contact
                    updadeContact.image = getStoredImage(for: contact.id)
                    contactList.append(updadeContact)
                }

                // Sort the list on load
                self.contactList = contactList.sorted()

                print("✅ Loaded \(contactList.count) contacts.")
            } catch {
                print("🛑 Unable to load saved data.")
            }

            return
        }

        print("Nothing to load")
    }

    // Restores image that was saved to local file
    func getStoredImage(for id: String) -> UIImage? {

        do {
            let filename = getDocumentsDirectory().appendingPathComponent(id)

            let data = try Data(contentsOf: filename)
            if let image = UIImage(data: data) {
                return image
            }

        } catch {
            print("🛑 Unable to load saved data.")
        }

        return nil
    }

    func saveData() {

        stopFetchingLocation()

        //Add new contact to current list of items if not empty
        if !self.newContact.name.isEmpty && self.newContact.image != nil {

            // Save item to file on device
            print("Saving data for contact: \n---------\n")
            print("Contact Name: \(self.newContact.name)")
            print("Contact Image ID: \(self.newContact.id)\n---------\n")
            print("Contact Latitude: \(self.newContact.latitude)")
            print("Contact Longitude: \(self.newContact.longitude)\n---------\n")

            contactList.append(self.newContact)

            //Now we dont want to save the Image itself but convert it to data, use the id to reference it, and save to local document file
            do {
                let filename = self.getDocumentsDirectory().appendingPathComponent(self.newContact.id)
                if let jpegData = self.newContact.image?.jpegData(compressionQuality: 0.8) {
                    try jpegData.write(to: filename, options: [.atomicWrite, .completeFileProtection])
                }
                print("✅ Image Data Saved: \(filename)")
            } catch {
                print("🛑 Unable to save image data: \(self.newContact.id)")
            }
        }

        // Sort the list before saving
        self.contactList = contactList.sorted()

        //Save list
        do {
            let filename = self.getDocumentsDirectory().appendingPathComponent("SavedContacts")
            let data = try JSONEncoder().encode(self.contactList)
            // MARK: - Strong file encryption using .completeFileProtection
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            print("✅ Data Saved to: \(filename)")
        } catch {
            print("🛑 Unable to save data.")
        }
    }
}
extension ContentView {
    
    func startFetchingLocation() {
        self.locationFetcher.start()
    }

    func stopFetchingLocation() {

        if let location = self.locationFetcher.lastKnownLocation {
            print("✨ Your location is \(location)")
            self.newContact.latitude = "\(location.latitude)"
            self.newContact.longitude = "\(location.longitude)"
        } else {
            print("✨ Your location is unknown")
        }

        self.locationFetcher.stop()
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        let dummyContact = Contact(name: "Cathal Farrell", id: "\(UUID())")
        let dummyList = [dummyContact]
        return NavigationView {
            ContentView(newContact: dummyContact, contactList: dummyList)
        }
    }
}
