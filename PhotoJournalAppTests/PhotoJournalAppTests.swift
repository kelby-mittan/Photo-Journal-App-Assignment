//
//  PhotoJournalAppTests.swift
//  PhotoJournalAppTests
//
//  Created by Kelby Mittan on 1/23/20.
//  Copyright © 2020 Kelby Mittan. All rights reserved.
//

import XCTest
import DataPersistence

@testable import PhotoJournalApp

class PhotoJournalAppTests: XCTestCase {

    func testLoadImageObjects() {
        
        let persistence = DataPersistence<ImageObject>(filename: "images.plist")
        do {
            let imageObjects = try persistence.loadItems()
            let firstDescription = imageObjects.first?.description
            XCTAssertEqual(firstDescription, "p")
        } catch {
            print("could not get photos")
            XCTFail()
        }
    }
}
