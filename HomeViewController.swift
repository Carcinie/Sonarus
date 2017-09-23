//
//  HomeViewController.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 5/21/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation
    
class HomeViewController:UITableViewController{
        
    private var arrayOfPosts:[String] = []
    private var arrayOfPics:[URL] = []
    private var arrayOfUsers:[String] = []
    private var arrayOfNames:[String] = []
    private var user:String!
        
    init(userName: String) {
        super.init(nibName: nil, bundle: nil)
        user = userName
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        tableView.separatorColor = UIColor.clear
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.tableFooterView = UIView()//removes empty cells
        tableView.dataSource = self
        tableView.backgroundView = UIImageView(image: UIImage(named: "wallpaper"))
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: "Posts")
        
        //get session variable
        if let sessionObj:AnyObject = UserDefaults.standard.value(forKey: "SpotifySession") as AnyObject?{
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            session = firstTimeSession
        }
        populatePosts()
    }
        
        
    private func populatePosts(){
        //Generate key
        let refQ = FIRDatabase.database().reference().child("Userbase/\(user!)/7Timeline/")
        
        //Get new posts coming in
        refQ.observe(.value, with: {(snapshot) in
            self.arrayOfNames = []
            self.arrayOfPics = []
            self.arrayOfPosts = []
            self.arrayOfUsers = []
            var index:Int = Int(snapshot.childrenCount) - 1
            
            for data in snapshot.children.allObjects as! [FIRDataSnapshot]{
                guard let dataDict = data.value as? [String:Any] else {continue}
                let post = dataDict["4status"] as? String
                let postUser = dataDict["1user"] as? String
                let userImage = dataDict["3image"] as? String
                let userName = dataDict["2name"] as? String
                
                self.arrayOfPosts.insert(post!, at: 0)
                self.arrayOfPics.insert(URL(string: userImage!)!, at: 0)
                self.arrayOfUsers.insert(postUser!, at: 0)
                self.arrayOfNames.insert(userName!, at: 0)
                index -= 1
            }
            
            self.tableView.reloadData()
        })
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
        cell?.setUsername(userID: arrayOfUsers[indexPath.row], displayName: arrayOfNames[indexPath.row])
        let post = arrayOfPosts[indexPath.row]
        cell?.setDisplayStatus(asStatus: post)
        cell?.setProfilePic(imageURL: arrayOfPics[indexPath.row])
        cell?.setStatusTextToWhite()
        
        return cell!
    }
        
}


