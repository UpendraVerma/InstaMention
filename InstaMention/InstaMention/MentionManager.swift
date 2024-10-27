//
//  TextViewDelegate.swift
//  InstaMention



import UIKit

protocol MentionManagerDelegate: AnyObject {
    func didSelectMention(username: String, id: String)
}
//------------------------------------------------------
class MentionManager: NSObject, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // Public properties
    weak var delegate: MentionManagerDelegate?
    
    private let textView: UITextView
    private let mentionArray: [MentionUserModel]
    //private var arrAddedUsers : [MentionUserModel] = []
    
    private var defaultAttributes : [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor : UIColor.black,NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .regular)]
    private var lastDetectRange: NSRange?
    private var lastNoRecordSearchText: String?
    private var isDetectMentioned = false
    private var tagType: MentionTagType = .User
    private var tagSymbol: [String] = ["#", "@"]
    private var mentionQuery = String()
    
    // Views for suggestion list
    private let mentionContainerView = UIView()
    private let mentionTableView: IntrinsicTableView
    
    private var filteredMentions: [MentionUserModel] = []
    
    init(textView: UITextView, mentionArray: [MentionUserModel]) {
        self.textView = textView
        self.mentionArray = mentionArray
        self.mentionTableView = IntrinsicTableView()
        super.init()
        
        setupTextView()
        setupMentionTableView()
    }
    
    private func setupTextView() {
        textView.delegate = self
    }
    
    private func setupMentionTableView() {
        // Configure the container view
        mentionContainerView.translatesAutoresizingMaskIntoConstraints = false
        mentionContainerView.backgroundColor = .clear
        mentionContainerView.shadow(color: UIColor.lightGray.withAlphaComponent(0.70), shadowOpacity: 0.7)
        mentionContainerView.layer.cornerRadius = 25
        textView.superview?.superview?.addSubview(mentionContainerView)
        
        NSLayoutConstraint.activate([
            mentionContainerView.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
            mentionContainerView.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -5),
            mentionContainerView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -15),  // Place the view above the textView
        ])
        
        // Configure the mentionTableView inside the container view
        mentionTableView.translatesAutoresizingMaskIntoConstraints = false
        mentionTableView.delegate = self
        mentionTableView.dataSource = self
        mentionTableView.allowsSelection = true
        mentionTableView.keyboardDismissMode = .none
        mentionTableView.separatorEffect = .none
        mentionContainerView.addSubview(mentionTableView)
        
        NSLayoutConstraint.activate([
            mentionTableView.topAnchor.constraint(equalTo: mentionContainerView.topAnchor, constant: 10),
            mentionTableView.leadingAnchor.constraint(equalTo: mentionContainerView.leadingAnchor, constant: 10),
            mentionTableView.trailingAnchor.constraint(equalTo: mentionContainerView.trailingAnchor, constant: -10),
            mentionTableView.bottomAnchor.constraint(equalTo: mentionContainerView.bottomAnchor, constant: -10)
        ])
        
        let Nib = UINib(nibName: "CellUserList", bundle: nil)
        self.mentionTableView.register(Nib, forCellReuseIdentifier: "CellUserList")
    }
    
    //MARK: API for search user for mention
    private func APICallForSearchUserInMention(searchText : String){
        
        if searchText != "" {
            self.filteredMentions = self.mentionArray.filter({ ($0.name ?? "").lowercased().contains(searchText.lowercased()) || $0.userName.lowercased().contains(searchText.lowercased()) })
            if self.filteredMentions.isEmpty {
                self.hideShowMentionView()
            } else {
                //hide and show mention user view
                self.hideShowMentionView(false)
            }
            
            self.mentionTableView.reloadData()
        } else {
            self.hideShowMentionView()
            self.filteredMentions = []
        }
    }
    
    //------------------------------------------------------
    //hide and show mention user view
    func hideShowMentionView(_ isHide : Bool = true){
        if isHide{
            self.filteredMentions = []
            self.mentionTableView.reloadData()
            self.mentionContainerView.isHidden = isHide
        }
        else{
            self.mentionContainerView.isHidden = isHide
        }
    }
    
    //------------------------------------------------------
    // MARK: - UITextViewDelegate
    //------------------------------------------------------
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        var lastCharacter = "nothing"
        let currentText = textView.text ?? ""
        
        // Check if the replacement is not empty
        if !text.isEmpty {
            // Calculate the position of the last character
            let lastCharacterIndex = currentText.index(currentText.startIndex, offsetBy: max(0, range.location - 1), limitedBy: currentText.endIndex)
            
            if let lastCharacterIndex = lastCharacterIndex {
                // Check if the index is within the valid range
                if lastCharacterIndex >= currentText.startIndex && lastCharacterIndex < currentText.endIndex {
                    lastCharacter = String(currentText[lastCharacterIndex])
                    print("Last Character: \(lastCharacter)")
                }
            }
        }
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        if text.isBackspace(), textView.text.isEmpty {
            return false
        }
        
        //Set defautl attribute
        textView.typingAttributes = defaultAttributes
        
        //Set tag type
        if self.tagSymbol.contains(text) && (range.location == 0 || lastCharacter == " " || lastCharacter == "\n") {
            lastDetectRange = range
            lastNoRecordSearchText = nil
            isDetectMentioned = true
            
            //set tag type
            if let type = MentionTagType.init(rawValue: "@") {
                self.tagType = type
            }
        }
        
        // action when press backspace
        if text.isBackspace() {
            
            let range = NSRange(location: 0, length: textView.attributedText.length)
            let attrString = textView.attributedText
            var r = NSRange()
            
            if range.length != .zero ,
                let attrDictionary = attrString?.attributes(at: range.length - 1, effectiveRange: &r),
                let color = attrDictionary[NSAttributedString.Key.foregroundColor] as? UIColor,
                color == UIColor.blue{
                
                let attributed = textView.attributedText
                textView.attributedText = attributed?.attributedSubstring(from: NSRange(location: 0, length: textView.attributedText.length - r.length))
                isDetectMentioned = false
                
                //empty the mention query because mention have been deleted
                self.mentionQuery = ""
                
                self.APICallForSearchUserInMention(searchText: self.mentionQuery)
                
                //close popup list
                self.hideShowMentionView()
                lastDetectRange = nil
                return false
            }
        }
        
        if text.isBackspace() && lastDetectRange != nil {
            // Get the index after the last detected range
            let startIndex = textView.text.index(textView.text.startIndex, offsetBy: lastDetectRange!.location + 1)
            
            // Create the substring from the calculated start index to the end
            let textl = String(textView.text[startIndex...])
            
            // if there last no record text then on back space do not call ws until reach to that word
            if textl.isEmpty {
                isDetectMentioned = false
                
                self.mentionQuery = ""
                
                self.APICallForSearchUserInMention(searchText: self.mentionQuery)
                
                // close popup list
                self.hideShowMentionView()
                lastDetectRange = nil
                return true
            }
            
            if lastNoRecordSearchText != nil {
                let text = (textView.text).substringFrom(from: lastDetectRange!.location + 1)
                
                if text.isEmpty {
                    isDetectMentioned = false
                    
                    self.mentionQuery = ""
                    
                    self.APICallForSearchUserInMention(searchText: self.mentionQuery)
                    
                    // close popup list
                    self.hideShowMentionView()
                    return true
                }
                
                if text[..<text.index(before: text.endIndex)] != lastNoRecordSearchText![..<lastNoRecordSearchText!.index(before: lastNoRecordSearchText!.endIndex)]
                {
                    isDetectMentioned = false
                    
                    self.mentionQuery = ""
                    
                    self.APICallForSearchUserInMention(searchText: self.mentionQuery)
                    
                    // close popup listf
                    self.hideShowMentionView()
                    return true
                }else
                {
                    
                    isDetectMentioned = true
                    lastNoRecordSearchText = nil
                    
                    //Show tag list
                    debugPrint("call api here \(text[..<text.index(before: text.endIndex)])")
                    self.APICallForSearchUserInMention(searchText: "\(text[..<text.index(before: text.endIndex)])")
                    return true
                }
            }
            
            // if there is no last no record text then on back space call ws until reach to @ wordh
            var text = (textView.text).substringFrom(from: lastDetectRange!.location + 1)
            
            if text.isEmpty {
                isDetectMentioned = false
                
                self.mentionQuery = ""
                
                self.APICallForSearchUserInMention(searchText: self.mentionQuery)
                
                // close popup list
                self.hideShowMentionView()
                return true
            }
            
            text = String(text[..<text.index(before: text.endIndex)])
            if text.isEmpty {
                isDetectMentioned = false
                
                self.mentionQuery = ""
                
                self.APICallForSearchUserInMention(searchText: self.mentionQuery)
                
                //close popup list
                self.hideShowMentionView()
                return true
            }
            
            isDetectMentioned = true
            self.mentionQuery = text
            
            // Show tag list
            //debugPrint("Api call here with text search text:: \(text)")
            self.APICallForSearchUserInMention(searchText: text)
            return true
        }
        
        // TagSymbol
        if isDetectMentioned /*|| (self.tagSymbol.contains(textView.text.suffix(1).description) && textView.isAllowSpaceFor(1))*/ {
            
            if text == " " || (text.count == 0 &&  self.mentionQuery == ""){ // If Space or delete the "@"
                self.mentionQuery = ""
                self.isDetectMentioned = false
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.hideShowMentionView()
                    
                })
            }
            else if text.count == 0 {
                self.mentionQuery.remove(at: self.mentionQuery.index(before: self.mentionQuery.endIndex))
                //debugPrint("api call here ::\(self.mentionQuery)")
                self.APICallForSearchUserInMention(searchText: self.mentionQuery)
            }
            else {
                if text != "@" {
                    self.mentionQuery += text
                    //debugPrint("api call:: \(self.mentionQuery)")
                    self.APICallForSearchUserInMention(searchText: self.mentionQuery)
                }
            }
            
        }
        
        // When press space or hit enter
        if text.isContainerSpaceOrNewLine() {
            // TODO:
        }
        
        return true
    }
    
    //------------------------------------------------------
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        if textView == self.textView {
            return false
        }
        
        if URL.absoluteString.isEmpty {
            debugPrint("Not Available!")
            return false
        }
        
        //TODO: Open profile according to click
        switch MentionTagType.init(rawValue: URL.absoluteString) {
        case .some(.Hash):
            debugPrint("tapped hastag")
            break
        case .some(.User):
            debugPrint("tapped user")
            break
        default:
            break
        }
        
        return true
    }
    
    //------------------------------------------------------
    func selectTag(text: String? = nil, id: String? = nil) {
        
        let lastTextPoint = lastDetectRange == nil ? self.textView.text!.count : lastDetectRange!.location
        
        let attributedText = NSMutableAttributedString.init(attributedString: self.textView.attributedText.attributedSubstring(from: NSMakeRange(0, self.textView.text!.count)))
        
        //add space before tag
        var strText = text
        if !self.textView.text.isEmpty, !String(self.textView.text!.last!).isContainerSpaceOrNewLine() {
            strText = "\(String(strText ?? ""))"
        }
        
        let appendString = NSAttributedString(string: strText ?? "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .regular), NSAttributedString.Key.foregroundColor : UIColor.blue])
        
        if lastDetectRange != nil {
            attributedText.replaceCharacters(in: NSRange(location: lastDetectRange!.location, length: self.mentionQuery.count + 1), with: appendString)
        } else {
            attributedText.replaceCharacters(in: NSRange(location: 0, length: self.mentionQuery.count), with: appendString)
        }
        
        if let texts = text {
            if lastDetectRange != nil {
                attributedText.addAttribute(NSAttributedString.Key.link, value: texts, range: NSMakeRange(lastTextPoint, appendString.length))
            } else {
                attributedText.addAttribute(NSAttributedString.Key.link, value: texts, range: NSMakeRange(0, appendString.length))
            }
            
        }
        
        //Add space at last
        let spaceString = NSAttributedString(string: " ", attributes: defaultAttributes)
        attributedText.append(spaceString)
        
        self.textView.attributedText = attributedText
        self.textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue]
        lastDetectRange = nil
        lastNoRecordSearchText = nil
        isDetectMentioned = false
        self.hideShowMentionView()
        
        //set defualt typeing attribute style
        self.textView.typingAttributes = defaultAttributes
        self.mentionQuery = ""
    }
    
    //------------------------------------------------------
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMentions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellUserList", for: indexPath) as? CellUserList else { return UITableViewCell() }
        let objAtindex = self.filteredMentions[indexPath.row]
        cell.configureCell(objAtIndex: objAtindex)
        
        //add getssure to tap of cell
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped(_:)))
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(tap)
        
        return cell
    }
    //------------------------------------------------------------------------------
    //MARK: manage tap of mention
    @objc func cellTapped(_ tapGesture : UITapGestureRecognizer) {
        
        guard let selectedIndexPath = self.mentionTableView.indexPathForRow(at: tapGesture.location(in: self.mentionTableView))  else {
            return
        }
        
        debugPrint(selectedIndexPath)
        
        let objOfMentions = self.filteredMentions[selectedIndexPath.row]
        //self.arrAddedUsers.append(self.filteredMentions[selectedIndexPath.row])
        self.selectTag(text: "@\(objOfMentions.userName)", id: objOfMentions.id.description)
        
        self.isDetectMentioned = false
        delegate?.didSelectMention(username: objOfMentions.userName, id: objOfMentions.id.description)
    }
}
