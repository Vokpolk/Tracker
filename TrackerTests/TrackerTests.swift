import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private lazy var trackerStore: TrackerStore = {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.trackerStore
    }()
    
    private lazy var trackerRecordStore: TrackerRecordStore = {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.trackerRecordStore
    }()
    
    private lazy var trackerCategoryStore: TrackerCategoryStore = {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.trackerCategoryStore
    }()
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        // Uncomment to update shanpshots
        // isRecording = true
    }
    
    // MARK: - Tests
    func testViewController() {
        let tabBarController = TabBarController(
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore,
            trackerCategoryStore: trackerCategoryStore
        )
        assertSnapshot(
            of: tabBarController,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "TabBarController_Light"
        )
        assertSnapshot(
            of: tabBarController,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "TabBarController_Dark"
        )
    }

}
