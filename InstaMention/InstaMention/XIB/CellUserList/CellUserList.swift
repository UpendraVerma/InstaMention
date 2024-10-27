//
//  CellUserList.swift
//  InstaMention


import UIKit

class CellUserList: UITableViewCell {
    //MARK: Outlet
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    
    @IBOutlet weak var vwSeprator: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imgProfile.setRound()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.customCellStyle()
    }
    
    //Apply Style
    func customCellStyle() {
        self.imgProfile.contentMode = .scaleAspectFill
        self.vwSeprator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        self.lblName.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        self.lblName.textColor = .black
        self.lblUsername.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        self.lblUsername.textColor = .lightGray
    }
    
    //------------------------------------------------------
    //set the data of share list
    func configureCell(objAtIndex: MentionUserModel) {
        self.lblName.text = objAtIndex.name
        self.imgProfile.image = objAtIndex.userProfile
        self.lblUsername.text = "@\(objAtIndex.userName)"
        self.vwSeprator.isHidden = true
    }
}
