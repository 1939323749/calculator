//
//  Item.swift
//  calculator
//
//  Created by mba on 2023/10/10.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
