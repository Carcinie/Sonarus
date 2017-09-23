//
//  FollowingTable.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 8/28/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

/*TODO:
[ ]. 1. Send unfollow/delete info to firebase
[ ] 2. Include spotify usernames in database
*/
class FollowingTable:UITableViewController{
    private var arrayOfFollowing:[String] = []
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
        
        getFollowing()
    }
    
    func getFollowing(){
        //Generate key
        let refF = FIRDatabase.database().reference().child("Userbase/\(user!)/5Following/")
        refF.observeSingleEvent(of: .value, with: {(snapshot) in
            if let following = snapshot.value as? NSDictionary{
                for name in following{
                    self.arrayOfFollowing.append(name.value as! String)
                    self.getDisplayName(user: name.value as! String)
                }
            }
            else{
                print("User not following.")
            }
        })
    }
    
    //getDisplayNames
    func getDisplayName(user:String){
        let refN = FIRDatabase.database().reference().child("Userbase/\(user)/1Name/")
        refN.observeSingleEvent(of: .value, with: {(snapshot) in
            let displayName = snapshot.value as? String ?? ""
            self.arrayOfNames.append(displayName)
            if self.arrayOfFollowing.count == self.arrayOfNames.count{
                self.tableView.reloadData()
            }
        })
    }

    
    //TableView setup
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfFollowing.count
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
    
    //Supports deleting/unfollowing cells from queue
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            tableView.reloadData()
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "trackIdQChanged"), object: IDqueue)//send ID to firebase
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //deque grabs cell that has already scrolled off of the screen, and resuses it. Saves mem, allows quicker scroll
        let cell = tableView.dequeueReusableCell(withIdentifier: "Following", for: indexPath) as? UserCell
        cell?.hideFollowButton()
        let userForCell:String = arrayOfFollowing[indexPath.row]
        let nameForCell:String = arrayOfNames[indexPath.row]
        cell?.setUsername(userID: userForCell, displayName: nameForCell)
        
        //Get recent status
        var refQ = FIRDatabase.database().reference().child("Userbase/\(userForCell)/6Statuses/")
        refQ.observeSingleEvent(of: .value, with: {(snapshot) in
            var statuses = [String]()
            for data in snapshot.children.allObjects as! [FIRDataSnapshot]{
                guard let dataDict = data.value as? [String:Any] else {
                    print("No data.")
                    continue
                }
                let status = dataDict["1status"] as? String
                statuses.append(status!)
                print("FollowingTable->FollowingUser:\(userForCell)->Post:\(status!)")
            }
            
            if let post = statuses.last as? String{//checks if nil
                    cell?.setDisplayStatus(asStatus: post)
            }
            else{
                print("User(\(userForCell)) has not posts.")
            }
        })
        
        //Get stream-room if any
        refQ = FIRDatabase.database().reference().child("Userbase/\(userForCell)/8Room/")
        refQ.observeSingleEvent(of: .value, with: {(snapshot) in
                guard let roomData = snapshot.value as? NSDictionary else {
                    print("No room data for user: \(userForCell).")
                    return
                }
                let active = roomData["1Active"] as? Bool ?? false
                if active{
                        let room = roomData["2Name"] as? String ?? ""
                        cell?.setUserRoom(room: room)
                }
        })
        
        //Get Firebase Profile Pic
        refQ = FIRDatabase.database().reference().child("Userbase/\(userForCell)/3Image/")
        refQ.observeSingleEvent(of: .value, with: {(snapshot) in
            let userImage = snapshot.value as! String
            cell?.setProfilePic(imageURL: URL(string: userImage)!)
        })
 
        return cell!
    }
    
}
