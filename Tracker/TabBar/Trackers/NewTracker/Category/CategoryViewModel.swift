import Foundation

typealias Binding<T> = (T) -> Void
final class CategoryViewModel {
    var onCategoryNameCreate: (() -> Void)?
    var updateCategories: (() -> Void)?
    
    private let model: TrackerCategoryStore
    
    init(model: TrackerCategoryStore) {
        self.model = model
    }
    
    func didEnter(_ name: String) {
        do {
            try model.addNewTrackerCategory(name)
            onCategoryNameCreate?()
            updateCategories?()
        } catch {
            assertionFailure("CategoryViewModel: не получилось добавить категорию")
        }
    }
    
    func getCategories() -> [TrackerCategory] {
        model.trackerCategories
    }
}
