//
//  Location+CoreDataClass.swift
//
//
//  Created by 한석희 on 12/14/20.
//
import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
      return CLLocationCoordinate2DMake(latitude, longitude)
    }
    public var title: String? {
      if name.isEmpty {
        return "(이름 미지정)"
      } else {
        return name
      }
    }
    public var subtitle: String? {
        return category.localized()
    }
    // MARK: - End of VC
}
