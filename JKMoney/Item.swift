//
//  Item.swift
//  JKMoney
//
//  Created by prom1 on 03.01.2025.
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
