//
//  String+localized.swift
//  LocationTwitter
//
//  Created by 한석희 on 12/23/20.
//
import Foundation
extension String {
    func localized() -> String{
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
}
