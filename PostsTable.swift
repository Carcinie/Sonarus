//
//  PostsTable.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 8/28/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

class PostsTable:UITableViewController{
    
    private var arrayOfPosts:[String] = []
    private var user:String!
    private var name:String!
    private var profilePic:URL!
    
    init(user: String, name:String) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        self.name = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.separatorColor = UIColor.clear
        tableView.alwaysBounceVertical = false
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.tableFooterView = UIView()//removes empty cells
        tableView.dataSource = self
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: "Posts")
        
        //get session variable
        if let sessionObj:AnyObject = UserDefaults.standard.value(forKey: "SpotifySession") as AnyObject?{
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            session = firstTimeSession
        }
        
        //Get Firebase Profile Pic
        let refQ = FIRDatabase.database().reference().child("Userbase/\(user!)/3Image/")
        refQ.observeSingleEvent(of: .value, with: {(snapshot) in
            let userImage = snapshot.value as! String
            self.profilePic = URL(string: userImage)!
            self.populatePosts()
        })
    }
    
    
    private func populatePosts(){
        //Generate key
        let refQ = FIRDatabase.database().reference().child("Userbase/\(user!)/6Statuses/")
        
        refQ.observeSingleEvent(of: .value, with: {(snapshot) in
            for data in snapshot.children.allObjects as! [FIRDataSnapshot]{
                guard let dataDict = data.value as? [String:Any] else {continue}
                let status = dataDict["1status"] as? String
                self.arrayOfPosts.insert(status!, at: 0)
            }
            self.tableView.reloadData()
        })
    }
    
    public func addPostToTable(text:String){
        arrayOfPosts.insert(text, at: 0)
        tableView.reloadData()
    }
    
    //TableView setup
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfPosts.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65)
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //deque grabs cell that has already scrolled off of the screen, and resuses it. Saves mem, allows quicker scroll
        let cell = tableView.dequeueReusableCell(withIdentifier: "Posts", for: indexPath) as? UserCell
        cell?.hideFollowButton()
        cell?.setUsername(userID: user!, displayName: name!)
        let post = arrayOfPosts[indexPath.row]
        cell?.setDisplayStatus(asStatus: post)
        cell?.setProfilePic(imageURL: profilePic)
        
        return cell!
    }
    
}

