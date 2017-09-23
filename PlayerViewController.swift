//
//  FirstViewController.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 4/19/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import UIKit
import SafariServices
import QuartzCore

class PlayerViewController: UIViewController, UIScrollViewDelegate, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    var auth = SPTAuth.defaultInstance()!
    var session: SPTSession!
    var player: SPTAudioStreamingController!
    var loginURL: URL?
    var tabBarHeight:CGFloat!
    
    
    //Vars
    ///Designates whether the user has locally paused playback
    var musicPaused:Bool = false
    public var streaming:Bool = false //note: connecting to a room, and listening to a stream does not constitute streaming, but being streamed to.
    ///Cell holds track info of a cell that was selected by the user. Intended to be used by various methods for extraction of track content.
    var selectedMusicCell:MusicCell!
    ///Cell holds track info of a cell that was selected by the user in the Queue. Intended to be used by various methods for extraction of track content.
    var selectedQueueCell:QCell!
    
    //Segment Control
    ///View that holds chat and queue inside open Pulley
    var segmentView:SegmentViewController!
    ///Buttons that control between Chat view and Queue view within the open Pulley
    var segControl:UISegmentedControl!
    
    //Labels ad Images
    ///The large album art that shows up when the Pulley is extended
    var mainAlbumArt:UIImageView!
    ///The bar above the tabbar that contains playback controls and track info. When the pulley is pulled up, this view dissapears.
    var playerTab = UIView()
    ///Play and pause button on the playerTab (bar above tabbar).
    var playPauseButton:UIButton = UIButton()
    var playerTabHeight:CGFloat = 0
    var songNamePulleyOpen:UILabel!
    var songNamePlayerTab:UILabel!
    var artistNamePulleyOpen:UILabel!
    var artistNamePlayerTab:UILabel!
    ///Button image displayed in the playerTab as a logo that switches to album art. Button press triggers streaming, and prompts user to create a streaming room.
    var streamArtButton:UIButton!
    ///Constraints view within the bar above the tabbar.
    var playerTabConstraints:[NSLayoutConstraint]!
    ///Constraints for views within the Pulley when the playerTab is extended.
    var PulleyOpenConstraints:[NSLayoutConstraint]!
    
    
    init(tabBarHeight: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        playerTabHeight = tabBarHeight * 2.4
        self.tabBarHeight = tabBarHeight
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //view.backgroundColor = UIColor.black
        
        //var newFrame:CGRect = self.view.frame
        //newFrame.size = CGSize.init(width: playerViewWidth, height: playerViewHeight)
        //self.view.frame = newFrame
        
        
        //loginSetup()//Spotify Login
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.loginSetup), name: Notification.Name(rawValue: "setupLogin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
        //Play song from Q, Search, Playlist, Room
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.streamAudioFromMusicCell(notification:)), name: Notification.Name(rawValue: "playSongFromMusicCell"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.streamAudioFromQ(notification:)), name: Notification.Name(rawValue: "playSongFromQ"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.listenToRoom(notification:)), name: Notification.Name(rawValue: "listenToRoom"), object: nil)
        
        //Update firebase Q trackIDs
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.fireUpdateQ(notification:)), name: Notification.Name(rawValue: "trackIdQChanged"), object: nil)
        //Player Tab show/hide views
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.hidePlayerTab), name: Notification.Name(rawValue: "playerExtended"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.showPlayerTab), name: Notification.Name(rawValue: "playerCollapsed"), object: nil)        
        
        //PLAYER TAB
        var newTabFrame:CGRect = playerTab.frame
        newTabFrame.size = CGSize.init(width: view.frame.width, height: tabBarHeight * 1.4)
        playerTab.frame = newTabFrame
        playerTab.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playerTab)
        
        playerTab.backgroundColor = UIColor.black
        
        //PLAY BUTTON
        playPauseButton.translatesAutoresizingMaskIntoConstraints  = false
        playPauseButton.tag = 13
        playerTab.addSubview(playPauseButton)
        playPauseButton.setImage(UIImage(named: "playButton"), for: UIControlState.normal)
        playPauseButton.tintColor = UIColor.gray
        playPauseButton.addTarget(self, action: #selector(playPausePressed(_:)), for: .touchUpInside)
        playPauseButton.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        playPauseButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .horizontal)
        playPauseButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
   
        //NEXT BUTTON
        let nextButton:UIButton = UIButton()
        nextButton.tag = 14
        nextButton.translatesAutoresizingMaskIntoConstraints  = false
        playerTab.addSubview(nextButton)
        nextButton.setImage(UIImage(named: "playNextButton"), for: UIControlState.normal)
        nextButton.tintColor = UIColor.gray
        nextButton.addTarget(self, action: #selector(nextPressed(_:)), for: .touchUpInside)
        nextButton.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        nextButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .horizontal)
        nextButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .vertical)
        
        //PROGRESS BAR
        let progressBar = UIProgressView()
        progressBar.tag = 15
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressTintColor = UIColor.cyan
        progressBar.progress = 0.5
        playerTab.addSubview(progressBar)
        
        //DROP IMAGE
        let dropImage = UIImageView(image: UIImage(named: "panelRaise"))
        dropImage.tag = 16
        dropImage.tintColor = UIColor.gray
        dropImage.translatesAutoresizingMaskIntoConstraints = false
        playerTab.addSubview(dropImage)
        
        //PLAYER TAB BAR SONG NAME
        songNamePlayerTab = UILabel()
        songNamePlayerTab.text = ""
        songNamePlayerTab.font = songNamePlayerTab.font.withSize(12)
        songNamePlayerTab.tag = 17
        songNamePlayerTab.textColor = UIColor.init(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
        songNamePlayerTab.translatesAutoresizingMaskIntoConstraints = false
        playerTab.addSubview(songNamePlayerTab)
        
        //PLAYER TAB BAR ARTIST NAME
        artistNamePlayerTab = UILabel()
        artistNamePlayerTab.text = ""
        artistNamePlayerTab.font = artistNamePlayerTab.font.withSize(10)
        artistNamePlayerTab.tag = 18
        artistNamePlayerTab.textColor = UIColor.init(red: 0.0, green: 180/255, blue: 1.0, alpha: 1)
        artistNamePlayerTab.translatesAutoresizingMaskIntoConstraints = false
        playerTab.addSubview(artistNamePlayerTab)
        
        //PLAYER TAB BAR ALBUM ART
        
        
        //streamArtButton = UIImageView(image: UIImage(named: "sonarusLogo"))
        streamArtButton = UIButton(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
        streamArtButton.setImage(UIImage(named: "sonarusLogo"), for: .normal)
        streamArtButton.layer.cornerRadius = (streamArtButton.frame.width/2)
        streamArtButton.layer.masksToBounds = true
        streamArtButton.addTarget(self, action: #selector(streamButtonAction), for: .touchUpInside)
        
        playerTab.addSubview(streamArtButton)
        streamArtButton.tag = 19
        streamArtButton.tintColor = UIColor.white
        streamArtButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        //Constraints
        playerTabConstraints = [
            playerTab.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerTab.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerTab.heightAnchor.constraint(equalToConstant: tabBarHeight * 1.4),
            playerTab.topAnchor.constraint(equalTo: view.topAnchor),
            //playPauseButton.centerYAnchor.constraint(equalTo: playerTab.centerYAnchor, constant: 10),
            playPauseButton.rightAnchor.constraint(equalTo: nextButton.leftAnchor, constant: -20),
            playPauseButton.bottomAnchor.constraint(equalTo: playerTab.bottomAnchor, constant: -1),
            playPauseButton.topAnchor.constraint(equalTo: playerTab.topAnchor, constant: 0),
            nextButton.rightAnchor.constraint(equalTo: playerTab.rightAnchor, constant: -7),
            nextButton.bottomAnchor.constraint(equalTo: playerTab.bottomAnchor, constant: -1),
            nextButton.topAnchor.constraint(equalTo: playerTab.topAnchor, constant: 0),
            progressBar.bottomAnchor.constraint(equalTo: playerTab.topAnchor, constant: tabBarHeight * 1.4),
            progressBar.leftAnchor.constraint(equalTo: playerTab.leftAnchor),
            progressBar.rightAnchor.constraint(equalTo: playerTab.rightAnchor),
            dropImage.centerXAnchor.constraint(equalTo: playerTab.centerXAnchor),
            dropImage.topAnchor.constraint(equalTo: playerTab.topAnchor, constant: 2),
            songNamePlayerTab.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            songNamePlayerTab.topAnchor.constraint(equalTo: playerTab.topAnchor, constant: 22),
            artistNamePlayerTab.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artistNamePlayerTab.topAnchor.constraint(equalTo: songNamePlayerTab.bottomAnchor, constant: 2),
            streamArtButton.centerYAnchor.constraint(equalTo: playerTab.centerYAnchor),
            streamArtButton.leftAnchor.constraint(equalTo: playerTab.leftAnchor, constant: 5),
            streamArtButton.heightAnchor.constraint(equalToConstant: tabBarHeight * 1.3),
            streamArtButton.widthAnchor.constraint(equalToConstant: tabBarHeight * 1.3)
            //streamArtButton.bottomAnchor.constraint(equalTo: progressBar.topAnchor, constant: -)
         ]
        NSLayoutConstraint.activate(playerTabConstraints)
        
        playerTab.tag = 12
        //playerTab.isUserInteractionEnabled = true

        
        
        
        //SONG NAME
        songNamePulleyOpen = UILabel()
        songNamePulleyOpen.text = ""
        songNamePulleyOpen.tag = 100
        songNamePulleyOpen.textColor = UIColor.white
        songNamePulleyOpen.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(songNamePulleyOpen)
        //songNamePulleyOpen.font.withSize(200)
        
        //Artist NAME
        artistNamePulleyOpen = UILabel()
        artistNamePulleyOpen.text = ""
        artistNamePulleyOpen.font = artistNamePulleyOpen.font.withSize(15)
        artistNamePulleyOpen.tag = 101
        artistNamePulleyOpen.textColor = UIColor.darkGray
        artistNamePulleyOpen.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(artistNamePulleyOpen)
        
        
        //MAIN ALBUM ART IMAGE
        mainAlbumArt = UIImageView(frame: CGRect(x: 0, y: 0, width: 180, height: 180))
        mainAlbumArt.image = UIImage(named: "sonarusLogo")
        view.addSubview(mainAlbumArt)
        mainAlbumArt.tag = 102
        mainAlbumArt.tintColor = UIColor.white
        mainAlbumArt.translatesAutoresizingMaskIntoConstraints = false
        
        //Make album art round with spin
        /*mainAlbumArt.layer.cornerRadius = (mainAlbumArt.frame.width/2)
        mainAlbumArt.layer.masksToBounds = true
        rotateImageAnimation(view: mainAlbumArt)
        */
        
        //SEGMENTED CONTROL BUTTON
        segControl = UISegmentedControl()
        segControl.tag = 103
        segControl.isUserInteractionEnabled = true
        segControl.isEnabled = true
        
        view.addSubview(segControl)
        segControl.translatesAutoresizingMaskIntoConstraints = false
        //UIImage *myNewImage = [myOldImage resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right)];
        //let UIImage mq =
        segControl.insertSegment(with: UIImage(named:"musicQueue")?.resizableImage(withCapInsets: UIEdgeInsets.zero), at: 0, animated: true)
        segControl.insertSegment(with: UIImage(named:"chatQueue"), at: 1, animated: true)
        segControl.backgroundColor = UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)//UIColor.black
        segControl.tintColor = UIColor.init(colorLiteralRed: 0, green: 122.0/255.0, blue: 1.0, alpha: 0.8)//default ios aqua
        segControl.selectedSegmentIndex = 0
        segControl.addTarget(self, action: #selector(segSwitch), for: .valueChanged)
        segControl.removeBorders()//custom function
        
        //SEGMENTED CONTROL
        segmentView = SegmentViewController()
        segmentView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentView.view)
        segmentView.view.isHidden = true
        segmentView.view.tag = 104
        
        
        PulleyOpenConstraints = [
            songNamePulleyOpen.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            songNamePulleyOpen.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            songNamePulleyOpen.heightAnchor.constraint(equalToConstant: 20),
            artistNamePulleyOpen.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artistNamePulleyOpen.topAnchor.constraint(equalTo: songNamePulleyOpen.bottomAnchor, constant: 5),
            artistNamePulleyOpen.heightAnchor.constraint(equalToConstant: 20),
            mainAlbumArt.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainAlbumArt.heightAnchor.constraint(equalToConstant: 180),//view.widthAnchor, multiplier: 0.35),
            mainAlbumArt.widthAnchor.constraint(equalToConstant: 180),//view.widthAnchor, multiplier: 0.35),
            mainAlbumArt.topAnchor.constraint(equalTo: artistNamePulleyOpen.bottomAnchor, constant: 10),
            segControl.topAnchor.constraint(equalTo: mainAlbumArt.bottomAnchor, constant: 20),
            segControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segControl.leftAnchor.constraint(equalTo: view.leftAnchor),
            segControl.rightAnchor.constraint(equalTo: view.rightAnchor),
            segControl.heightAnchor.constraint(equalToConstant: 25),
            segmentView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            segmentView.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            segmentView.view.topAnchor.constraint(equalTo: segControl.bottomAnchor),
            segmentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70),
            //segmentView.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55)
        ]
        NSLayoutConstraint.activate(PulleyOpenConstraints)
        for tagg in 100...103 {self.view.viewWithTag(tagg)?.alpha = 0}

        mainAlbumArt.contentMode = .scaleAspectFit

    }
    
    ///Presents the Spotify login at startup where user inputs credentials.
    @objc func loginSetup(){

        SPTAuth.defaultInstance().clientID = kClientId
        SPTAuth.defaultInstance().redirectURL = NSURL(string: kCallbackURL) as URL!
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope]
        loginURL = SPTAuth.defaultInstance().spotifyAppAuthenticationURL()
        //Parsing loginURL, since it does not have html header needed for SFSafari
        var str = loginURL?.absoluteString
        let startIndex = str?.index((str?.startIndex)!, offsetBy: 17)
        str = str?.substring(from: startIndex!)//remove spotify-action://
        str = "https://accounts.spotify.com/" + str!
        print(str!)
        loginURL = URL(string: str!)
        print("___________")
        print(loginURL!)
        print("___________")
        //Present Spotify Login
        
        updateAfterFirstLogin()//load working session if available
        //else get a new token by presenting login
        if session == nil{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "presentLogin"), object: loginURL)
            updateAfterFirstLogin()
        }
        else if session.isValid() == false{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "presentLogin"), object: loginURL)
            updateAfterFirstLogin()
        }
    }
    
    ///Loads the authenticated session for continual use
    @objc func updateAfterFirstLogin () {

        if let sessionObj:AnyObject = UserDefaults.standard.value(forKey: "SpotifySession") as AnyObject?{
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            initializePlayer(authSession: session)
        }
    }
    
    ///Initializes Spotify player
    func initializePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
            self.player!.delegate = self as SPTAudioStreamingDelegate
            try! player!.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    ///Shows the views on the playerTab bar. Hides the views from the extended Pulley. Intended for when the Pulley is collapsed.
    @objc func showPlayerTab(){
        //print("showing player")
        UIView.animate(withDuration: 0.1, animations: {
            for tag in 12...19 {self.view.viewWithTag(tag)?.alpha = 1}
            for tagg in 100...103 {self.view.viewWithTag(tagg)?.alpha = 0}
        },completion:{(finished:Bool) in
            self.playerTab.isHidden = false
            self.segmentView.view.isHidden = true
        })
        
    }
    
    ///Hides the views on the playerTab bar. Shows the views for the extended Pulley.
    @objc func hidePlayerTab(){
        //print("hiding player")
        UIView.animate(withDuration: 0.2, animations: {
            for tag in 12...19 {self.view.viewWithTag(tag)?.alpha = 0}
            for tagg in 100...103 {self.view.viewWithTag(tagg)?.alpha = 1}
        },completion:{(finished:Bool) in
            self.playerTab.isHidden=true
            self.segmentView.view.isHidden = false
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    ///Method that triggers playback.
    @objc func playPausePressed(_ sender: Any) {
        print("play pressed")
        
        //var items = playToolbar.items!
        //var newButton : UIButton? = nil//UIBarButtonItem? = nil
        //print(items.count)
        
        if (musicPaused) == false{
            print("")
            if (player.playbackState.isPlaying == true){
                print("Pause")
                pauseRotationAnimation(view: streamArtButton)
                player.setIsPlaying(false, callback: nil)
                playPauseButton.setImage(UIImage(named:"playButton"), for: .normal)
            }
            else if (player.playbackState.isPlaying == false){
                print("Continue Play")
                if !streaming{
                    rotateImageAnimation(view: streamArtButton)
                }
                player.setIsPlaying(true, callback: nil)
                playPauseButton.setImage(UIImage(named:"pauseButton"), for: .normal)
            }
            else{
                print("Nothing to Play")
                pauseRotationAnimation(view: streamArtButton)
                playPauseButton.setImage(UIImage(named:"playButton"), for: .normal)
                return
            }
        }
            
        else
        {
            player.setIsPlaying(true, callback: nil)
            print("Play")
            if !streaming{
                rotateImageAnimation(view: streamArtButton)
            }
            rotateImageAnimation(view: streamArtButton)
            playPauseButton.setImage(UIImage(named:"pauseButton"), for: .normal)
        }
        musicPaused = !musicPaused
    }
    
    ///Method to change to next track
    @objc func nextPressed(_ sender: Any){
        if !streaming{
            rotateImageAnimation(view: streamArtButton)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "playNextFromQ"), object:nil)
    }
    
    ///Method to start stream for the local user. USer is promted to create a room.
    @objc func streamButtonAction(){
        let dismissHandler = {
            (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }
        
        if streaming{//stop streaming
            let closeRoom = {
                (action: UIAlertAction!) in
                
                self.streaming = false
                
                ////Make room inactive on user profile
                var ref = FIRDatabase.database().reference().child("Userbase/\(self.session.canonicalUsername!)/8Room/")
                ref.setValue(["1Active":false, "2Name":""])
                
                //Delete room
                ref = FIRDatabase.database().reference().child("Roombase/\(UserVariables.activeRoom)/")
                ref.removeValue()
                
                UserVariables.activeRoom = ""
            }
            
            let alert = UIAlertController(title: "Close Room", message: "Stop streams, chat, and delete room.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: dismissHandler))
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: closeRoom))
            self.present(alert, animated: true, completion: nil)
        }
        else{//begin streaming
            pauseRotationAnimation(view: streamArtButton)
            streaming = true
            
            let alert = UIAlertController(title: "New Stream", message: "Start a stream by creating a room.", preferredStyle: .alert)
            
            let makeRoom = {
                (action: UIAlertAction!) in
                
                //Create room
                var ref = FIRDatabase.database().reference().child("Roombase/\(alert.textFields!.first!.text!)/")
                ref.setValue(["1Room Name":alert.textFields?.first?.text!,"2Creator":self.session.canonicalUsername!,"3Desc":alert.textFields?.last?.text!,"4Banner":"","4Img":"", "5Messages":"","6Songs":"", "7Queue":""])
                ref = FIRDatabase.database().reference().child("Roombase/\(alert.textFields!.first!.text!)/6Songs")
                ref.setValue(["1trackid":"","2isPlaying":false,"3position":"","4timestamp":""])
                
                ////Make room active on user profile
                ref = FIRDatabase.database().reference().child("Userbase/\(self.session.canonicalUsername!)/8Room/")
                ref.setValue(["1Active":true, "2Name":alert.textFields?.first?.text!])
                UserVariables.activeRoom = (alert.textFields?.first?.text)!
                NotificationCenter.default.post(name: Notification.Name(rawValue: "NewRoom"), object: nil)//Engage chat
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: dismissHandler))
            alert.addAction(UIAlertAction(title: "Create", style: .default, handler: makeRoom))
            alert.addTextField(configurationHandler: {textField in
                textField.placeholder = "Room Title"
            })
            alert.addTextField(configurationHandler: {textField in
                textField.placeholder = "Description"
                
            })
            self.present(alert, animated: true, completion: nil)
                
        }
    }
    
    ///Method that controls the display of either the Chat View or the Queue View within the extended Pulley
    @objc func segSwitch(_ sender:Any){
        switch segControl.selectedSegmentIndex{
            case 0:
                segmentView.showMusicQueue()
            case 1:
                segmentView.showChat()
            default:
                break
        }
    }
    
    /**Extracts track images and loads them onto the playback views.
      Parameter `source` indicates the source of the track info.
     **There are three cases:**
     1. Unloading images from a QCell
     2. Unloading images from a MusicCell, acquired through a search request
     3. Unloading images from a MusicCell, acquired through a stream
     Either `selectedQueueCell` or `selectedMusicCell` should be updated before calling this method.
     */
    func updateLablesAndArt(source:PlaySource){
        switch source{//music source i.e. from queue, from search, from streaming room
            case .dequeue:
                songNamePulleyOpen.text = selectedQueueCell.songName
                songNamePlayerTab.text = selectedQueueCell.songName
                artistNamePulleyOpen.text = selectedQueueCell.artistName
                artistNamePlayerTab.text = selectedQueueCell.artistName
                mainAlbumArt.image = selectedQueueCell.largeArt
                if !streaming{
                    streamArtButton.setImage(selectedQueueCell.smallArt, for: .normal)
                }
            case .searchRequest:
                songNamePulleyOpen.text = selectedMusicCell.songName
                songNamePlayerTab.text = selectedMusicCell.songName
                artistNamePulleyOpen.text = selectedMusicCell.artistName
                artistNamePlayerTab.text = selectedMusicCell.artistName
                mainAlbumArt.image = selectedMusicCell.largeArt
                if !streaming{
                    streamArtButton.setImage(selectedMusicCell.smallArt, for: .normal)
            }
            case .stream:
                songNamePulleyOpen.text = selectedMusicCell.songName
                songNamePlayerTab.text = selectedMusicCell.songName
                artistNamePulleyOpen.text = selectedMusicCell.artistName
                artistNamePlayerTab.text = selectedMusicCell.artistName
                mainAlbumArt.image = selectedMusicCell.largeArt
                streamArtButton.setImage(selectedMusicCell.smallArt, for: .normal)
            
        }
        
        //Activate Retro Album views
        if !streaming{
            let albumArtDot = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
            albumArtDot.layer.cornerRadius = (albumArtDot.frame.width/2)
            albumArtDot.layer.masksToBounds = true
            playerTab.addSubview(albumArtDot)
            albumArtDot.translatesAutoresizingMaskIntoConstraints = false
            albumArtDot.backgroundColor = UIColor.black
            
            let albumArtCircle = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            albumArtCircle.layer.cornerRadius = (albumArtCircle.frame.width/2)
            albumArtCircle.layer.borderColor = UIColor.black.cgColor
            albumArtCircle.layer.borderWidth = 1.0
            albumArtCircle.layer.masksToBounds = true
            playerTab.addSubview(albumArtCircle)
            albumArtCircle.translatesAutoresizingMaskIntoConstraints = false
            //albumArtCircle.backgroundColor = UIColor.black
            
        /*  let mainAlbumArtDot = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            mainAlbumArtDot.layer.cornerRadius = (mainAlbumArtDot.frame.width/2)
            mainAlbumArtDot.layer.masksToBounds = true
            mainAlbumArt.addSubview(mainAlbumArtDot)
            mainAlbumArtDot.translatesAutoresizingMaskIntoConstraints = false
            mainAlbumArtDot.backgroundColor = UIColor.black
             
            var mainAlbumArtCircle = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
            mainAlbumArtCircle.layer.cornerRadius = (mainAlbumArtCircle.frame.width/2)
            mainAlbumArtCircle.layer.borderColor = UIColor.black.cgColor
            mainAlbumArtCircle.layer.borderWidth = 2.0
            mainAlbumArtCircle.layer.masksToBounds = true
            mainAlbumArt.addSubview(mainAlbumArtCircle)
            mainAlbumArtCircle.translatesAutoresizingMaskIntoConstraints = false
            */
            NSLayoutConstraint.activate([
                    albumArtDot.centerYAnchor.constraint(equalTo: streamArtButton.centerYAnchor),
                    albumArtDot.centerXAnchor.constraint(equalTo: streamArtButton.centerXAnchor),
                    albumArtDot.heightAnchor.constraint(equalToConstant: 15),
                    albumArtDot.widthAnchor.constraint(equalToConstant: 15),
                    albumArtCircle.centerYAnchor.constraint(equalTo: streamArtButton.centerYAnchor),
                    albumArtCircle.centerXAnchor.constraint(equalTo: streamArtButton.centerXAnchor),
                    albumArtCircle.heightAnchor.constraint(equalToConstant: 35),
                    albumArtCircle.widthAnchor.constraint(equalToConstant: 35),/*
                    mainAlbumArtDot.centerYAnchor.constraint(equalTo: mainAlbumArt.centerYAnchor),
                    mainAlbumArtDot.centerXAnchor.constraint(equalTo: mainAlbumArt.centerXAnchor),
                    mainAlbumArtDot.heightAnchor.constraint(equalToConstant: 35),
                    mainAlbumArtDot.widthAnchor.constraint(equalToConstant: 35),
                    mainAlbumArtCircle.centerYAnchor.constraint(equalTo: mainAlbumArt.centerYAnchor),
                    mainAlbumArtCircle.centerXAnchor.constraint(equalTo: mainAlbumArt.centerXAnchor),
                    mainAlbumArtCircle.heightAnchor.constraint(equalToConstant: 65),
                    mainAlbumArtCircle.widthAnchor.constraint(equalToConstant: 65),*/
                ])
        }
    }
 
    ///Creates rotating animation for a view. Intended to be used as an animation of a rotating cd or record.
    func rotateImageAnimation(view: UIView){
        print("Rotate")
        var rotationAnimation:CABasicAnimation
        rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Float.pi * 2)
        rotationAnimation.duration = 1
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = .greatestFiniteMagnitude
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func pauseRotationAnimation(view: UIView){
        view.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
    /*
    @IBAction func LogInButtonPressed(_ sender: Any) {
        self.loginSetup()
    }
    */
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "playNextFromQ"), object:nil)
    }
    //OPTIONAL SPTAudioStreamingDelegate methods
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError errorCode: SpErrorCode, withName name: String!) {
        print("\naudioStreaming - DidReceieveError - code: " + String(errorCode.rawValue) + " with name: " + name)
    }
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("\nLOGGED IN\n")
    }
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        print("\nLOGGED OUT\n")
    }
    func audioStreamingDidReconnect(_ audioStreaming: SPTAudioStreamingController!) {
        print("\nRECONNECTED\n")
    }
    func audioStreamingDidDisconnect(_ audioStreaming: SPTAudioStreamingController!) {
        print("\nDISCONNECTED\n")
    }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print("\nRECEIVED MESSAGE:\n" + message)
    }
    func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController!) {
        print("\nTEMPORARY CONNECTION ERROR\n")
    }

}

extension PlayerViewController: PulleyDrawerViewControllerDelegate{

    //Pulley Methods
    func collapsedDrawerHeight() -> CGFloat {
        return playerTabHeight
    }
    
    func partialRevealDrawerHeight() -> CGFloat {
        return playerTabHeight + 1
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [PulleyPosition.collapsed,PulleyPosition.open]
    }
}


extension UISegmentedControl{
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: backgroundColor!), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: tintColor!), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}
