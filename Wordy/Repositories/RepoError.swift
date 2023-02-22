//
//  RepoError.swift
//  Repo
//
//  Created by Joey Zhang on 2023/2/21.
//

import Foundation

public enum RepoError: Error {
    case invalidDatabase
    case invalidFilePath
    case invalidWordTag
    case notFound(word: String)
}
