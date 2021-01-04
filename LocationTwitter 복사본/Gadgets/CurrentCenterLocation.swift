//
//  CurrentCenterLocation.swift
//  LocationTwitter
//
//  Created by 한석희 on 1/4/21.
//

import Foundation
import MapKit
import CoreLocation

@objc(CurrentCenterLocation)
public class CurrentCenterLocation: NSObject, MKAnnotation {
    
    var latitude = 0.0
    var longitude = 0.0

    public var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    public var title : String? = ""
    public var subtitle : String? = ""
    // MARK: - End of VC
}
