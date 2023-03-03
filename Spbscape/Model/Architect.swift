//
//  Architect.swift
//
//
//  Created by Vladislav Fitc on 13/10/2020.
//

import Foundation

struct Architect: Codable {
  let id: Int
  let name: String
}

extension Architect: CustomStringConvertible {
  var description: String { name }
}
