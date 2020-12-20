//
//  String+Add.swift
//  BeenThere
//
//  Created by 한석희 on 12/4/20.
//

import Foundation

extension String {
    //
  mutating func add(text: String?, separatedBy separator: String = "") {
    if let text = text {
      if !isEmpty {
        self += separator
      }
      self += text
    }
  }
}
