//
//  Classroom.swift
//  testChat
//
//  Created by Andy Li on 12/8/18.
//

import Foundation
import CoreLocation


class Classroom {
    let course: String
    let location: CLLocation
    let days: [Int]
    let time: ClosedRange<Int> // TODO: Find better way to check for time
    let locationName: String
    
    init(course: String, locationName: String, days: [Int], time: ClosedRange<Int>, latitude: Double, longitude: Double) {
        self.course = course
        self.locationName = locationName
        self.days = days
        self.time = time
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
}
