//
//  FollowersTable.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 8/28/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

class FollowersTable:UITableViewController{
    
    private var arrayOfFollowers:[String] = []
    private var arrayOfFollowerNames:[String] = []
    private var arrayOfFollowing:[String] = []
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
        tableView.alwaysBounceVertical = false
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.tableFooterView = UIView()//removes empty cells
        tableView.dataSource = self
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: "Following")
        
        //get session variable
        if let sessionObj:AnyObject = UserDefaults.standard.value(forKey: "SpotifySession") as AnyObject?{
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            session = firstTimeSession
        }
        
        self.populateFollowing()
        self.populateFollowers()
    }
    
    private func populateFollowers(){
        //Generate key
        arrayOfFollowers = []//in case function is called from elsewhere, prevent repeat values
        arrayOfFollowerNames = []
        
        print("populateFollowers for user: \(user!)")
        let refQ = FIRDatabase.database().reference().child("Userbase/\(user!)/4Followers/")
        refQ.observeSingleEvent(of: .value, with: {(snapshot) in
            if let followers = snapshot.value as? NSDictionary{
                for follower in followers{
                    print("Follower: \(follower)!!!!!")
                    self.arrayOfFollowers.append(follower.value as! String)
                    self.getFollowerDisplayName(user: follower.value as! String)
                }
                
                
            }
            else{
                print("No followers.")
            }
        })
        
    }
    
    private func populateFollowing(){
        //Generate key
        let refQ = FIRDatabase.database().reference().child("Userbase/\(user!)/5Following/")
        refQ.observeSingleEvent(of: .value, with: {(snapshot) in
            if let following = snapshot.value as? NSDictionary{
                for name in following{
                    self.arrayOfFollowing.append(name.value as! String)
                }
            }
            else{
                print("Not following.")
            }
        })
    }
    func getfollowers()->[String]{
        //populateFollowers()
        return arrayOfFollowers
    }
    
    //getDisplayNames
    func getFollowerDisplayName(user:String){
        let ref = FIRDatabase.database().reference().child("Userbase/\(user)/1Name/")
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            let displayName = snapshot.value as? String ?? ""
            self.arrayOfFollowerNames.append(displayName)
            if self.arrayOfFollowers.count == self.arrayOfFollowerNames.count{
                self.tableView.reloadData()
            }
        })
    }
    
    //TableView setup
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfFollowers.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65)
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! UserCell
        let userToPresent = cell.getUserName()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "presentFromProfile\(user!)"), object: userToPresent)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //deque grabs cell that has already scrolled off of the screen, and resuses it. Saves mem, allows quicker scroll
        let cell = tableView.dequeueReusableCell(withIdentifier: "Following", for: indexPath) as? UserCell
        //cell?.hideFollowButton()
        let userForCell:String = arrayOfFollowers[indexPath.row]
        cell?.setUsername(userID: userForCell, displayName: arrayOfFollowerNames[indexPath.row])
        
        if arrayOfFollowing.contains(userForCell){
            cell?.disableFollowButton()
        }
        
        
        //Get recent status
        var refQ = FIRDatabase.database().reference().child("Userbase/\(userForCell)/6Statuses/")
        refQ.observeSingleEvent(of: .value, with: {(snapshot) in
            var statuses = [String]()
            for data in snapshot.children.allObjects as! [FIRDataSnapshot]{
                guard let dataDict = data.value as? [String:Any] else {continue}
                let status = dataDict["1status"] as? String
                statuses.append(status!)
            }
            print(userForCell)
            if statuses.last != nil{
                cell?.setDisplayStatus(asStatus: statuses.last!)
            }
            
            
        })
        
        //Get Firebase Profile Pic
        refQ = FIRDatabase.database().reference().child("Userbase/\(userForCell)/3Image/")
        refQ.observeSingleEvent(of: .value, with: {(snapshot) in
            let userImage = snapshot.value as! String
            cell?.setProfilePic(imageURL: URL(string: userImage)!)//userImage.allValues.first as! String)!)
        })
        
        /* Get Spotify User
         SPTUser.request(user, withAccessToken: session.accessToken, callback: {(error, result) in
         let userData = result as! SPTUser
         cell?.setProfilePic(userData.smallestImage.imageURL)
         } as SPTRequestCallback! )
         */
        
        return cell!
    }
    
}
