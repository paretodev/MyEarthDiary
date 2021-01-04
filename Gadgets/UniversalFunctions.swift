//
//  UniversalFunctions.swift
//  BeenThere
//
//  Created by 한석희 on 12/4/20.
//

import Foundation
import CoreLocation
import UIKit

//
func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        line1.add(text: placemark.subThoroughfare)
        line1.add(text: placemark.thoroughfare, separatedBy: " ")
        var line2 = ""
        line2.add(text: placemark.locality)
        line2.add(text: placemark.administrativeArea, separatedBy: " ")
        line2.add(text: placemark.postalCode, separatedBy: " ")
        line1.add(text: line2, separatedBy: ", ")
        return line1
}

//
func makeAlert(withTitle: String, withContents: String) -> UIAlertController {
    //
    let alert = UIAlertController(title: withTitle, message: withContents, preferredStyle: .alert)
    let action = UIAlertAction( title: "확인", style: .default, handler: nil )
    alert.addAction(action)
    //
    return alert
}

//
func issuePhotoID() -> Int {
    let thisTimeID = UserDefaults.standard.integer(forKey: "photoID")
    UserDefaults.standard.setValue(thisTimeID + 1, forKey: "photoID")
//    print("id issued : \(thisTimeID)")
    return thisTimeID
}

// 클래스 내에서 정의되지 않아, 글로벌 => 라이프 사이클 == 앱 라이프 사이클
var applicationDocumentsDirectory: URL = {
  let paths = FileManager.default.urls(
    for: .libraryDirectory,
    in: .userDomainMask
  )
  return paths[0]
}()

//MARK: - Handle Core Data Error -> Get Notification
let dataSaveFailedNotification = Notification.Name("DataSaveFailedNotification") // name of notification

func fatalCoreDataError(_ error : Error){
//    print("Fatal error : \(error)")
    NotificationCenter.default.post(
        name: dataSaveFailedNotification,
        object: nil
    )
}

//
func removeFileAtUrl(_ url: URL){
    do {
        try  FileManager().removeItem(at: url)
    } catch  {
        print("Failed deleting the file at \(url.description)")
        fatalError()
    }
}
