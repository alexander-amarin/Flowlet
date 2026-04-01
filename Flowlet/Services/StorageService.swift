import Foundation

/// Только сохранение и загрузка сырых данных (без бизнес-логики).
protocol StorageService: AnyObject {
    func save(_ data: Data, forKey key: String)
    func data(forKey key: String) -> Data?
}

/// Реализация через `UserDefaults`.
final class UserDefaultsStorageService: StorageService {
    
    func save(_ data: Data, forKey key: String) {
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func data(forKey key: String) -> Data? {
        UserDefaults.standard.data(forKey: key)
    }
}
