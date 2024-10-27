//
//  StringHelper.swift
//  InstaMention


import Foundation
import UIKit
//------------------------------------------------------
//hash tag helper methods
extension String {
    func isBackspace() -> Bool {
        let  char = self.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            return true
        }
        return false
    }
    
    func last(index: Int) -> String? {
        guard count > index else {return nil}
        return self.reversed()[index].description
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substringFrom(from: Int) -> String {
        guard from >= 0 && from < count else {
            return ""
        }
        let startIndex = index(self.startIndex, offsetBy: from)
        return String(self[startIndex...])
    }
    
    func isContainerSpaceOrNewLine() -> Bool {
        return contains(" ") || contains("\n")
    }
    
}
extension StringProtocol {
    subscript(from index: Index) -> SubSequence {
        return self[index...]
    }
}
