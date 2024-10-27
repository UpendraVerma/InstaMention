//
//  ViewController.swift
//  InstaMention


import UIKit

class ViewController: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var lblMessage: UILabel!
    
    @IBOutlet weak var tvMessage: IQTextView!
    @IBOutlet weak var btnSend: UIButton!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    private var arrAddedUsers : [MentionUserModel] = []
    private var mentionManager: MentionManager!
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint(self.classForCoder , " deinit")
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        self.applyStyle()
        
        mentionManager = MentionManager(textView: self.tvMessage, mentionArray: DummyData.shared.setDummyData())
        mentionManager.delegate = self

    }
    
    //------------------------------------------------------
    //add prefix for username
    func addPrefixForUsername(_ username : String) -> String{
        if username.contains("@"){
            return username
        }
        else{
            return "@"+username
        }
    }

    //------------------------------------------------------
    func applyStyle(){
        self.btnSend.tintColor = .blue
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    @IBAction func btnSendTapped(_ sender: Any) {
        mentionManager.hideShowMentionView(true)
        
        let message: String = self.tvMessage.text ?? ""

        if !message.isEmpty {
            let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)

            var arrID: [String] = []
            var mentionUserNamesValue: String = ""
            var mentionUserIdsValue: String = ""
            let attributedString = NSMutableAttributedString() // Change to NSMutableAttributedString
            var mentionRanges: [NSRange] = [] // Array to hold ranges of mentions

            if let text = self.tvMessage.attributedText, !self.tvMessage.text!.isEmpty {
                text.enumerateAttributes(in: NSMakeRange(0, text.length), options: []) { (attributes, range, stop) in
                    
                    if let color = attributes[NSAttributedString.Key.foregroundColor] as? UIColor, color == UIColor.blue {
                        if let id = attributes[NSAttributedString.Key.link] as? String {
                            arrID.append(id)
                            attributedString.append(NSAttributedString(string: "@" + id + "#", attributes: [NSAttributedString.Key.foregroundColor: UIColor.blue]))
                            mentionRanges.append(range) // Store the range of the mention
                        }
                    } else {
                        attributedString.append(text.attributedSubstring(from: range))
                    }
                }
            }

            debugPrint("ids:::" + arrID.joined(separator: ","))

            // Extract mentions and corresponding user IDs
            let (mentionUserNames, mentionUserIds) = arrID.reduce(into: ([String](), [String]())) { result, mention in
                if let user = self.arrAddedUsers.first(where: { "@\($0.userName)" == mention }) {
                    result.0.append(self.addPrefixForUsername(user.userName))
                    result.1.append(String(user.id))
                }
            }

            // Print the extracted mention names and user IDs
            print("Mention names: \(mentionUserNames.joined(separator: ","))")
            mentionUserNamesValue = mentionUserNames.joined(separator: ",")

            print("Mention IDs: \(mentionUserIds.joined(separator: ","))")
            mentionUserIdsValue = mentionUserIds.joined(separator: ",")

            // Clear the text view after processing
            self.tvMessage.text = ""

            print("trimmedMessage:: \(trimmedMessage)")
            print("mentionUserIdsValue:: \(mentionUserIdsValue)")
            print("mentionUserNamesValue:: \(mentionUserNamesValue)")
            
            let highlightedComment: NSMutableAttributedString = NSMutableAttributedString(string: "\(trimmedMessage)")
            
            // Now, when displaying in the label, you can use attributedString
            self.lblMessage.attributedText = highlightedComment
            
            // Optionally, you can highlight the mentions differently if needed
            for range in mentionRanges {
                debugPrint(range)
                highlightedComment.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: range) // Highlight the mention
            }
            // Set the highlighted attributed string to the label
            self.lblMessage.attributedText = highlightedComment
        }

    }
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
//------------------------------------------------------
extension ViewController : MentionManagerDelegate {
    func didSelectMention(username: String, id: String) {
        print("Selected Mention: \(username) with ID: \(id)")
        self.arrAddedUsers.append(MentionUserModel(id: Int(id) ?? 0, userName: username))
        // Handle the selected mention, e.g., update UI, perform an action, etc.
    }
    
}
