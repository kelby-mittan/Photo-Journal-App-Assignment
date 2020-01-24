//
//  ImageObject.swift
//  PhotoJournalApp
//
//  Created by Kelby Mittan on 1/23/20.
//  Copyright © 2020 Kelby Mittan. All rights reserved.
//

import Foundation

struct ImageObject: Codable & Equatable {
    let imageData: Data
    let date: Date
    let identifier = UUID().uuidString
    var description: String
}
