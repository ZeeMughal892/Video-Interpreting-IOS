//
//  MessagesViewController.swift
//  VideoInterpreting
//
//  Created by Muhammad Zeeshan on 08/12/2020.
//

import UIKit
import SWRevealViewController

struct Message{
    let text: String
    let isIncoming: Bool
    let name: String
}

class MessagesViewController: UIViewController,UITextViewDelegate  {

    @IBOutlet weak var lblUsername: PaddingLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtMessage: customUITextView!
    public static var localName:String!
    @IBOutlet weak var messageInputView: UIView!
    
    fileprivate let cellId = "mesgID"
    public static var chatMessages = [Message]()
 
    var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblUsername.text = MessagesViewController.localName
        txtMessage.placeholder = "Write Something ...."
        HideKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        bottomConstraint = NSLayoutConstraint(item: messageInputView!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(bottomConstraint!)
        
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
    }
    @objc func refresh() {
        self.tableView.reloadData() // a refresh the tableView.
    }
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardSize!.height : 0
        }
    }    
    @IBAction func actionClose(_ sender: Any) {
        self.revealViewController()?.revealToggle(self)
    }
    @IBAction func btnSend(_ sender: Any) {
        if MeetingViewController.localDataTrack != nil {
            MeetingViewController.localDataTrack!.send(txtMessage.text)
            let mesg = Message(text: txtMessage.text, isIncoming: false, name: "")
            MessagesViewController.chatMessages.append(mesg)
            txtMessage.text = ""
            tableView.reloadData()
        }
    }
}
extension MessagesViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessagesViewController.chatMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageTableViewCell
        let chatMessage = MessagesViewController.chatMessages[indexPath.row]
        cell.chatMessage = chatMessage
        return cell
    }
}
