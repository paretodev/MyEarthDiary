//
//  Location+CoreDataProperties.swift
//  
//
//  Created by 한석희 on 12/15/20.
//

import Foundation
import CoreData
import CoreLocation

extension Location {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }
    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var locationPhotos: [String]
    @NSManaged public var locationTwit: String
    @NSManaged public var name: String
    @NSManaged public var placemark: CLPlacemark?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
}

extension Location : Identifiable { }
