//
//  ChatViewController.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 5/2/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

/*
 TODO:
[ ] 1. Add header saying "Chat" to tableview
*/

import Foundation

class ChatViewController:UIViewController{
    private let chatTable = UITableView()
    private let newMessageField = UITextView()
    private let newMessageArea = UIView()
    private var keyboardHeight = 0
    private var keyboardAnimationDuration : Double = 0
    var messages = [Message]()
    private var bottomConstraint : NSLayoutConstraint!
    private let cellIdentifier = "Cell"
    var ref: FIRDatabaseReference!

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        ref = FIRDatabase.database().reference()
        view.backgroundColor = UIColor.clear
        chatTable.backgroundColor = UIColor.clear
        //Need tabbar height to set up constraints so tabbar does not block last cell, or message area
        //let tabBarHeight =  (self.tabBarController?.tabBar.frame.size.height)!
        
        
        //newMessageArea at bottom where you write your new message
        newMessageArea.backgroundColor = UIColor.lightGray
        newMessageArea.alpha = 0.5
        
        view.addSubview(newMessageArea)
        newMessageArea.translatesAutoresizingMaskIntoConstraints = false
        newMessageField.translatesAutoresizingMaskIntoConstraints  = false
        newMessageArea.addSubview(newMessageField)
        newMessageField.isScrollEnabled = false
        
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(sendButton)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(pressedSend(button:)), for: .touchUpInside)
        sendButton.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        sendButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .horizontal)
        
        
        bottomConstraint = newMessageArea.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true
        
        let messageAreaConstraints : [NSLayoutConstraint] = [
            newMessageArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newMessageArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newMessageField.leadingAnchor.constraint(equalTo: newMessageArea.leadingAnchor, constant:10),
            newMessageField.centerYAnchor.constraint(equalTo: newMessageArea.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: newMessageArea.trailingAnchor, constant: -10),
            newMessageField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: newMessageField.centerYAnchor),
            newMessageArea.heightAnchor.constraint(equalTo: newMessageField.heightAnchor, constant: 20)//breaks
        ]
        NSLayoutConstraint.activate(messageAreaConstraints)
        
        
        //chatTable.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)  //<- DEFAULT
        chatTable.register(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        chatTable.dataSource = self
        chatTable.delegate = self//Assign delegate so delegate method runs
        chatTable.estimatedRowHeight = 44//rows change to accomodate height if needed
        newMessageField.delegate = self as? UITextViewDelegate
        //Add Chat table view
        chatTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatTable)
        chatTable.tableFooterView = UIView()//eliminates chat lines when no data
        
        
        let chatTableConstraints: [NSLayoutConstraint] = [
            chatTable.topAnchor.constraint(equalTo: view.topAnchor),
            chatTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTable.bottomAnchor.constraint(equalTo: newMessageArea.topAnchor)
        ]
        
        NSLayoutConstraint.activate(chatTableConstraints)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapDismissKeyboard(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        
        //Firebase setup
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.reloadTable), name: NSNotification.Name(rawValue: "FIRMessageAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.joinNewRoom), name: NSNotification.Name(rawValue: "NewRoom"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.fireListenForMessages), name: NSNotification.Name(rawValue: "listenToRoom"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Chat view appeared")
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification){
        updateBottomConstraint(notification: notification, keyboardUp: true)
    }
    @objc func keyboardWillHide(notification: NSNotification){
        updateBottomConstraint(notification: notification, keyboardUp: false)
    }
    
    //Dismiss keyboard when touch outside
    @objc func singleTapDismissKeyboard(recognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func reloadTable(){
        DispatchQueue.main.async(execute: { () -> Void in
            self.chatTable.reloadData()
            self.chatTable.scrollToBottom()//so latest messages appear
        })
    }
    
    func joinNewRoom(){
        self.fireListenForMessages()
        chatTable.reloadData()
        chatTable.scrollToBottom()//so latest messages appear
    }
    
    func updateBottomConstraint(notification:NSNotification, keyboardUp:Bool){
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let frame = (userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as AnyObject).cgRectValue
        let animationDuration = userInfo.value(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
        let newFrame = view.convert(frame!, from: (UIApplication.shared.delegate?.window)!)//for keyboard
        if keyboardUp == false{
            bottomConstraint.constant = 0
        }
        else{
            bottomConstraint.constant = newFrame.origin.y - view.frame.height
        }
        
        
        UIView.animate(withDuration: animationDuration, animations: {self.view.layoutIfNeeded()})
        chatTable.scrollToBottom()
    }
    
    @objc func pressedSend(button:UIButton){
        guard let text = newMessageField.text, text.characters.count > 0 else {return}
    
        newMessageField.text = ""
        view.endEditing(true)
        //messages.append(Message.init(Message: text, Sender: username, incoming: false))
        chatTable.reloadData()
        chatTable.scrollToBottom()
        fireSendMessage(message: text, room: UserVariables.activeRoom)
    }
}




extension ChatViewController:UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO: Label must be removed when room is joined. It shows when there is no chatter and room has been joined.
        if messages.count == 0 && UserVariables.activeRoom == ""{
            let emptyLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text = "Join a room."
            emptyLabel.textAlignment = NSTextAlignment.center
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            return 0
        } else {
            tableView.backgroundView = nil
            return messages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatCell
        cell.setText(isIncoming: message.incoming, user: message.sender!, message: message.text!)//graphically distinguish incoming vs outgoing messages
            cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.size.width, 0, 0)//removes graphical line between cells
            return cell
    }
    
    //Remove highlighing
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Chat"
    }
     func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if view.isKind(of: UITableViewHeaderFooterView.self){
            let headerView:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            headerView.textLabel?.textAlignment = NSTextAlignment.center
            //headerView.backgroundColor = UIColor.init(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
            headerView.tintColor = UIColor.init(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
            headerView.textLabel?.textColor = UIColor.darkGray
        }
    }
}
