//
//  MentionUserModel.swift
//  InstaMention


import UIKit

struct MentionUserModel {
    var id: Int
    var userProfile: UIImage?
    var name: String?
    var userName: String
    
    internal init(id: Int, userProfile: UIImage? = nil, name: String? = nil, userName: String) {
        self.id = id
        self.userProfile = userProfile
        self.name = name
        self.userName = userName
    }
}
