//
//  IntrinsicTableView.swift
//  InstaMention

import Foundation
import UIKit
class IntrinsicTableView: UITableView {
    
    override var contentSize:CGSize {
        didSet {
            self.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        
        self.layoutIfNeeded()
        var size = super.contentSize
        
        if size.height == 0 || size.width == 0 {
            size = self.contentSize
        }
        return size
    }
    
    override func reloadData() {
        
        super.reloadData()
        
        setHeaderFooterviewHeight()
        
        self.layoutIfNeeded()
        self.setNeedsLayout()
        self.invalidateIntrinsicContentSize()
        
    }
    
    func setHeaderFooterviewHeight () {
        
        if let headerView = self.tableHeaderView {
            
            headerView.frame.size.height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            self.tableHeaderView = headerView
        }
        
        if let footerView = self.tableFooterView {
            
            footerView.frame.size.height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            self.tableFooterView = footerView
        }
        
        self.layoutIfNeeded()
    }
    
}

