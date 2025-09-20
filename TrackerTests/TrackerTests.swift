//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Александр Клопков on 20.09.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    let trackerStore = (UIApplication.shared.delegate as! AppDelegate).trackerStore
    let trackerRecordStore = (UIApplication.shared.delegate as! AppDelegate).trackerRecordStore
    let trackerCategoryStore = (UIApplication.shared.delegate as! AppDelegate).trackerCategoryStore
    func testViewController() {
        let tabBarController = TabBarController(
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore,
            trackerCategoryStore: trackerCategoryStore
        )
        assertSnapshot(of: tabBarController, as: .image(traits: .init(userInterfaceStyle: .light)))
        assertSnapshot(of: tabBarController, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

}
