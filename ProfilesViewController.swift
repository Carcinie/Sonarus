//
//  ProfilesController.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 7/8/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

class ProfilesViewController:UIViewController, UIToolbarDelegate, UIPopoverPresentationControllerDelegate{
    private var headerView:UIView!
    private var profilePic:UIImageView!
    private var followingButton:UIBarButtonItem!
    private var followingCount:UILabel!
    private var followersButton:UIBarButtonItem!
    private var followersCount:UILabel!
    private var postsButton:UIBarButtonItem!
    private var postsCount:UILabel!
    private var navToolBar:UIToolbar!
    private var segmentView:UIView!
    private var segControl:UISegmentedControl!
    private var followingController:FollowingTable!
    private var followersController:FollowersTable!
    private var postsController:PostsTable!
    private var newPost:UIButton!
    private var userLabel:UILabel!
    
    //User variables
    private var user:String!
    private var userDisplayName:String!
    private var profileImage:String!
    
    
    init(userName: String) {
        super.init(nibName: nil, bundle: nil)
        user = userName
        getDisplayName(user: user)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ProfilesViewController.pushProfile(notification:)), name: Notification.Name(rawValue: "presentFromProfile\(user!)"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfilesViewController.createProfile), name: Notification.Name(rawValue: "createProfile"), object: nil)
        
        
        //get session variable
        if let sessionObj:AnyObject = UserDefaults.standard.value(forKey: "SpotifySession") as AnyObject?{
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            session = firstTimeSession
        }
        
        //Header View
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width/2))
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        
        //Bottom View
        segmentView = UIView()
        segmentView.translatesAutoresizingMaskIntoConstraints = false
        segmentView.backgroundColor = UIColor.white
        view.addSubview(segmentView)
        
        //Profile Pic
        profilePic = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width/4, height: view.frame.width/4))
        profilePic.layer.cornerRadius = (profilePic.frame.width/2)
        profilePic.layer.borderColor = UIColor.white.cgColor
        profilePic.layer.borderWidth = 2.0
        profilePic.layer.masksToBounds = true
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(profilePic)
        
        //Username
        userLabel = UILabel()
        userLabel.translatesAutoresizingMaskIntoConstraints = false
        userLabel.text = user!
        userLabel.textColor = UIColor.white
        headerView.addSubview(userLabel)
        
        //segControl
        segControl = UISegmentedControl(frame: CGRect(x: 0, y: 0, width: headerView.frame.width, height: 30))
        segControl.isUserInteractionEnabled = true
        segControl.isEnabled = true
        headerView.addSubview(segControl)
        segControl.translatesAutoresizingMaskIntoConstraints = false
        segControl.insertSegment(withTitle: "Posts", at: 0, animated: true)
        segControl.insertSegment(withTitle: "Followers", at: 1, animated: true)
        segControl.insertSegment(withTitle: "Following", at: 2, animated: true)
        segControl.backgroundColor = UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)//UIColor.black
        segControl.tintColor = UIColor.init(colorLiteralRed: 0, green: 122.0/255.0, blue: 1.0, alpha: 0.8)//default ios aqua
        segControl.selectedSegmentIndex = 0
        
        NSLayoutConstraint.activate([
                headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                headerView.topAnchor.constraint(equalTo: view.topAnchor),
                headerView.heightAnchor.constraint(equalToConstant: view.frame.width/2),
                segmentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                segmentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                segmentView.widthAnchor.constraint(equalToConstant: view.frame.width),
                segmentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                segmentView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                profilePic.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                profilePic.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
                profilePic.heightAnchor.constraint(equalToConstant: view.frame.width/4),
                profilePic.widthAnchor.constraint(equalToConstant: view.frame.width/4),
                userLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                userLabel.topAnchor.constraint(equalTo: profilePic.bottomAnchor, constant: 5),
                segControl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
                segControl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
                segControl.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            ])
        if user! == session.canonicalUsername{
            addPostButton(view: headerView)
        }
        
        segControl.addUnderlineForSelectedSegment()
        segControl.addTarget(self, action: #selector(segSwitch), for: .valueChanged)
        
        getProfileData()
        view.backgroundColor = UIColor.init(patternImage: UIImage(named: "wallpaper")!)
    }
    
    //Should be active only on main user
    func addPostButton(view:UIView){
        //NewPost Button
        newPost = UIButton(type: .contactAdd)
        newPost.translatesAutoresizingMaskIntoConstraints = false
        newPost.addTarget(self, action: #selector(ProfilesViewController.newPostButtonPressed), for: .touchUpInside)
        view.addSubview(newPost)
        
        NSLayoutConstraint.activate([
                newPost.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
                newPost.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            ])
    }
    
    func loadBottomViews(){
        followingController = FollowingTable(userName: user)
        followersController = FollowersTable(userName: user)
        postsController = PostsTable(user: user, name: userDisplayName ?? "")
        
        followingController.view.translatesAutoresizingMaskIntoConstraints = false
        followersController.view.translatesAutoresizingMaskIntoConstraints = false
        postsController.view.translatesAutoresizingMaskIntoConstraints = false
        
        segmentView.addSubview(followingController.view)
        segmentView.addSubview(followersController.view)
        segmentView.addSubview(postsController.view)
        
        NSLayoutConstraint.activate([
                followingController.view.leadingAnchor.constraint(equalTo: segmentView.leadingAnchor),
                followingController.view.trailingAnchor.constraint(equalTo: segmentView.trailingAnchor),
                followingController.view.topAnchor.constraint(equalTo: segmentView.topAnchor),
                followingController.view.bottomAnchor.constraint(equalTo: segmentView.bottomAnchor),
                followersController.view.leadingAnchor.constraint(equalTo: segmentView.leadingAnchor),
                followersController.view.trailingAnchor.constraint(equalTo: segmentView.trailingAnchor),
                followersController.view.topAnchor.constraint(equalTo: segmentView.topAnchor),
                followersController.view.bottomAnchor.constraint(equalTo: segmentView.bottomAnchor),
                postsController.view.leadingAnchor.constraint(equalTo: segmentView.leadingAnchor),
                postsController.view.trailingAnchor.constraint(equalTo: segmentView.trailingAnchor),
                postsController.view.topAnchor.constraint(equalTo: segmentView.topAnchor),
                postsController.view.bottomAnchor.constraint(equalTo: segmentView.bottomAnchor),
            ])
        
        followersController.view.isHidden = true
        followingController.view.isHidden = true
    }
    
    @objc func segSwitch(){
        segControl.changeUnderlinePosition()
        switch segControl.selectedSegmentIndex{
        case 0:
            postsController.view.isHidden = false
            followingController.view.isHidden = true
            followersController.view.isHidden = true
            if user! == session.canonicalUsername{//For main user only
                newPost.isHidden = false//show button that creates a new post
            }
        case 1:
            followersController.view.isHidden = false
            followingController.view.isHidden = true
            postsController.view.isHidden = true
            if user! == session.canonicalUsername{
                newPost.isHidden = true
            }
        case 2:
            followingController.view.isHidden = false
            followersController.view.isHidden = true
            postsController.view.isHidden = true
            if user! == session.canonicalUsername{
                newPost.isHidden = true
            }
        default:
            break
        }
    }
    func getProfileData(){
        if user != session.canonicalUsername{//Profile is for fake user. Get data from exclusively from Firebase, not spotify.
            //Get Firebase Profile Pic
            print("Getting profile pic for: \(user!).")
            
            //Get Firebase Profile Pic
            let ref = FIRDatabase.database().reference().child("Userbase/\(user!)/3Image/")
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let imageURL = snapshot.value as! String
                self.setProfilePic(imageURL: URL(string:imageURL)!)
            })
            
            let refN = FIRDatabase.database().reference().child("Userbase/\(user!)/1Name/")
            refN.observeSingleEvent(of: .value, with: {(snapshot) in
                let displayName = snapshot.value as? String ?? ""
                if displayName != ""{
                    self.userLabel.text = displayName
                    self.userDisplayName = displayName
                    self.loadBottomViews()
                }
            })
        }
        else{//profile is for local user
            SPTUser.request(user, withAccessToken: session.accessToken, callback: {(error, result) in
                    let userData = result as! SPTUser
                    do{
                        let picData = try Data(contentsOf: userData.smallestImage.imageURL)
                        self.profileImage = userData.smallestImage.imageURL.absoluteString
                        self.profilePic.image = UIImage(data: picData)
                    }
                    catch{print("Error retrieving image data.")}
                
                    let ref = FIRDatabase.database().reference().child("Userbase/\(self.user!)")
                    ref.observeSingleEvent(of: .value, with:{(snapshot) in
                        if (snapshot.value as? NSDictionary) == nil{
                            print("User does not exist in firebase db. Creating user.")
                            self.createProfile()
                        }
                    })
                } as SPTRequestCallback! )
            
            let refN = FIRDatabase.database().reference().child("Userbase/\(user!)/1Name/")
            refN.observeSingleEvent(of: .value, with: {(snapshot) in
                let displayName = snapshot.value as? String ?? ""
                if displayName != ""{
                    self.userLabel.text = displayName
                    self.userDisplayName = displayName
                    self.loadBottomViews()
                    UserVariables.userName = displayName
                }
            })
        }
    }
    
    //getDisplayNames
    func getDisplayName(user:String){
        let ref = FIRDatabase.database().reference().child("Userbase/\(user)/1Name/")
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            let displayName = snapshot.value as? String ?? ""
            self.userDisplayName = displayName
        })
    }
    
    func setProfilePic(imageURL:URL){
        do{
            let imageData = try Data(contentsOf: imageURL)
            profilePic.image = UIImage(data: imageData)
        }//End do
        catch{
            print(error.localizedDescription)
        }
    }
    
    @objc func newPostButtonPressed(){
        let alert = UIAlertController(title: "New Post", message: "Create new post.", preferredStyle: .alert)
        
        let dismissHandler = {
            (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }
        let sendPost = {
            (action: UIAlertAction!) in
            //Create time stamp
            let myTime:Double = ((NSDate().timeIntervalSince1970) * 1000)
            let timeLongTimeStamp = UInt64(myTime)
            let post:String = (alert.textFields?.first?.text)!
            
            //Publish to own wall
            //Add user to list of following
            let ref = FIRDatabase.database().reference().child("Userbase/\(UserVariables.userID)/6Statuses/")
            let statusRef = ref.childByAutoId()
            statusRef.updateChildValues(["1status":post, "2timestamp":timeLongTimeStamp])
            
            //Publish to followers wall
            let followers:[String] = self.followersController.getfollowers()
            for follower in followers{
                let ref = FIRDatabase.database().reference().child("Userbase/\(follower)/7Timeline/")
                let statusRef = ref.childByAutoId()
                statusRef.updateChildValues(["1user":UserVariables.userID,"2name":UserVariables.userName,"3image":self.profileImage,"4status":post, "5timestamp":timeLongTimeStamp])
           }
            self.postsController.addPostToTable(text: post)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: dismissHandler))
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: sendPost))
        alert.addTextField(configurationHandler: {textField in
            textField.placeholder = "Text"
            
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .overCurrentContext
    }
    
    @objc func pushProfile(notification : NSNotification){
        let userToPresent = notification.object as! String
        let controller:ProfilesViewController = ProfilesViewController(userName: userToPresent)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func createProfile(){
        //Generate key
        let ref = FIRDatabase.database().reference().child("Userbase/\(self.user!)")
        
        if ((userDisplayName as? String) == nil){
            userDisplayName = ""
        }
        
        let newUser = ["1Name":userDisplayName, "2Bio":"", "3Image": profileImage,"4Banner":"" ,"4Followers": "", "5Following":"", "6Statuses":"", "7Timeline":"", "8Room":""] as [String : Any]
        ref.setValue(newUser)
        print("Firebase user profile made")
    }
    

}


