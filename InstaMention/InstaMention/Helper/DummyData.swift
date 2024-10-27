//
//  DummyData.swift
//  InstaMention


import Foundation
import UIKit

class DummyData {
    static let shared : DummyData = DummyData()
    
    func setDummyData() -> [MentionUserModel] {
        let user1 = MentionUserModel(id: 1, userProfile: UIImage(named: "Profile1") ?? UIImage(), name: "John Dey", userName: "JohnD")
        let user2 = MentionUserModel(id: 2, userProfile: UIImage(named: "Profile2") ?? UIImage(), name: "Michael Dev", userName: "MichleD")
        let user3 = MentionUserModel(id: 3, userProfile: UIImage(named: "Profile3") ?? UIImage(), name: "Emily Johnson", userName: "EmilyJ")
        let user4 = MentionUserModel(id: 4, userProfile: UIImage(named: "Profile4") ?? UIImage(), name: "Jessica Smith", userName: "JessS")
        let user5 = MentionUserModel(id: 5, userProfile: UIImage(named: "Profile5") ?? UIImage(), name: "Daniel Brown", userName: "DanB")
        let user6 = MentionUserModel(id: 6, userProfile: UIImage(named: "Profile6") ?? UIImage(), name: "Sophia Davis", userName: "SophieD")
        let user7 = MentionUserModel(id: 7, userProfile: UIImage(named: "Profile7") ?? UIImage(), name: "James Wilson", userName: "JamesW")
        let user8 = MentionUserModel(id: 8, userProfile: UIImage(named: "Profile8") ?? UIImage(), name: "Olivia Garcia", userName: "LivG")
        let user9 = MentionUserModel(id: 9, userProfile: UIImage(named: "Profile9") ?? UIImage(), name: "Liam Martinez", userName: "LiamM")
        let user10 = MentionUserModel(id: 10, userProfile: UIImage(named: "Profile10") ?? UIImage(), name: "Ava Rodriguez", userName: "AvaR")
        let arrUserList = [user1, user2, user3, user4, user5, user6, user7, user8, user9, user10]
        return arrUserList
    }
}
