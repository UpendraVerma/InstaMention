//
//  GEnum.swift
//  InstaMention


import Foundation

enum MentionTagType: String {
    case Hash = "#"
    case User = "@"
    
    var strValue: String {
        switch self {
        case .Hash:     return "hashtag"
        case .User:     return "user"
        }
    }
}
