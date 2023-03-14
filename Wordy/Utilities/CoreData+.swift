//
//  CoreData+.swift
//  Wordy
//
//  Created by Joey Zhang on 2023/3/14.
//

import CoreData

extension UserDataEntity {
    static func request() -> NSFetchRequest<UserDataEntity> {
        return NSFetchRequest<UserDataEntity>(entityName: String(describing: UserDataEntity.self))
    }
}

extension WordEntity {
    static func request() -> NSFetchRequest<WordEntity> {
        return NSFetchRequest<WordEntity>(entityName: String(describing: WordEntity.self))
    }
}

extension NSSet {
    func toArray<T>(of type: T.Type) -> [T] {
        allObjects.compactMap { $0 as? T }
    }
}
