//
//  DetailView.swift
//  NetterForget
//
//  Created by Cathal Farrell on 17/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI
import MapKit

struct DetailView: View {

    @State var contact: Contact
    @State var centerCoordinate = CLLocationCoordinate2D()

    var body: some View {
        VStack {
            Image(uiImage: contact.image ?? UIImage())
            .resizable()
            .scaledToFit()
            MapView(centerCoordinate:$centerCoordinate, annotation: contact.locationAnnotation)
        }
        .navigationBarTitle(contact.name)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        return DetailView(contact: Contact.sampleContact)
    }
}
