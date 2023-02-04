//
//  Street.swift
//  
//
//  Created by Vladislav Fitc on 13/10/2020.
//

import Foundation

struct Street: Codable {
  
  let id: Int
  let title: String
  let cityID: Int
    
}

extension Street: CustomStringConvertible {
  
  var description: String { title }
  
}
