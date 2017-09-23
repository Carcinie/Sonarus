//
//  UserCell.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 8/29/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

class UserCell:UITableViewCell{
    private let userNameLabel = UILabel()
    private var userName:String!
    private var userRoom:String!
    private let icon = UIButton(type: UIButtonType.system)
    private let followButton = UIButton(type: UIButtonType.system)
    private let listenButton = UIButton(type: UIButtonType.system)
    private var profilePic = UIImageView()
    private let status = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Profile Pic
        profilePic = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.height, height: contentView.frame.height))
        profilePic.layer.cornerRadius = (profilePic.frame.width/2)
        profilePic.layer.borderColor = UIColor.green.cgColor
        profilePic.layer.borderWidth = 2.0
        profilePic.layer.masksToBounds = true
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profilePic)
        
        //User Name
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 14)//userNameLabel.font.withSize(14)
        userNameLabel.textColor = UIColor.init(colorLiteralRed: 0, green: 122.0/255.0, blue: 1.0, alpha: 1)//default ios aqua
        self.backgroundColor = UIColor.clear//superview?.backgroundColor
        //self.backgroundView = UIImageView(image: UIImage(named: "cellBackground"))
        contentView.addSubview(userNameLabel)
        
        //User Status
        status.translatesAutoresizingMaskIntoConstraints = false
        status.text = ""
        status.font = status.font.withSize(12)
        status.numberOfLines = 2
        status.adjustsFontSizeToFitWidth = true
        contentView.addSubview(status)
        
        //Follow Button
        followButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(followButton)
        //let followIcon = imageWithImage(sourceImage: UIImage(named:"followUser")!, scaledToWidth: contentView.frame.height/2)
        followButton.setImage(UIImage(named:"followUser"), for: .normal)
        followButton.addTarget(self, action: #selector(UserCell.followButtonPressed), for: .touchUpInside)
        followButton.tintColor = UIColor.init(colorLiteralRed: 0, green: 122.0/255.0, blue: 1.0, alpha: 1)//default ios aqua
        
        //Listen Button
        listenButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(listenButton)
        listenButton.setImage(UIImage(named:"listenToUser"), for: .normal)
        listenButton.addTarget(self, action: #selector(UserCell.listenButtonPressed), for: .touchUpInside)
        listenButton.tintColor = UIColor.init(colorLiteralRed: 0, green: 122.0/255.0, blue: 1.0, alpha: 1)//default ios aqua
        
        NSLayoutConstraint.activate([
                profilePic.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                profilePic.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5),
                profilePic.widthAnchor.constraint(equalToConstant: contentView.frame.height),
                profilePic.heightAnchor.constraint(equalToConstant: contentView.frame.height),
                userNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
                userNameLabel.leadingAnchor.constraint(equalTo: profilePic.trailingAnchor, constant: 5),
                followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
                followButton.widthAnchor.constraint(equalToConstant: contentView.frame.height),
                followButton.heightAnchor.constraint(equalToConstant: contentView.frame.height),
                listenButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                listenButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
                listenButton.widthAnchor.constraint(equalToConstant: contentView.frame.height),
                listenButton.heightAnchor.constraint(equalToConstant: contentView.frame.height),
                status.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                status.leadingAnchor.constraint(equalTo: profilePic.trailingAnchor, constant: 5),
                status.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: 5),
                status.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
                status.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2)
            ])
        listenButton.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUsername(userID:String, displayName:String){
        userName = userID
        if displayName == ""{
            userNameLabel.text = userID
        }
        else{
            userNameLabel.text = displayName
        }
        if userName == session.canonicalUsername!{
            disableFollowButton()
        }
            
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
    
    func setUserRoom(room:String){
        if room == ""{
            listenButton.isHidden = true
        }
        else{
            listenButton.isHidden = false
        }
        
        userRoom = room
    }
    
    func setDisplayStatus(asStatus:String){
        status.text = asStatus
    }
    
    func hideFollowButton(){
        followButton.isHidden = true
    }
    func disableFollowButton(){
        followButton.isEnabled = false
    }
    
    func setStatusTextToWhite(){
        status.textColor = UIColor.white
    }
    
    func getUserName()->String{
        return userName
    }
    
    private func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    @objc func followButtonPressed(){
        followButton.isEnabled = false
        
        //Add user to list of following
        var ref = FIRDatabase.database().reference().child("Userbase/\(session.canonicalUsername!)/5Following/")
        ref.setValue([userName!:userName!])
        //Add self to user's list of followers
        ref = FIRDatabase.database().reference().child("Userbase/\(userName!)/4Followers/")
        ref.setValue([session.canonicalUsername!:session.canonicalUsername!])
    }
    
    @objc func listenButtonPressed(){
        print("Connecting to \(userName!)'s room: \(userRoom!).")
        UserVariables.activeRoom = userRoom!
        NotificationCenter.default.post(name: Notification.Name(rawValue: "listenToRoom"), object: userName!)
    }
}
