//
//  Location.swift
//  Assingment_quini
//
//  Created by Natwar Jaju on 06/05/21.
//

import Foundation
import CoreLocation

struct Location: Identifiable {
    var id = UUID().uuidString
    var location: CLPlacemark
}
