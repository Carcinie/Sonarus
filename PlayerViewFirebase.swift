//
//  PlayerViewFirebase.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 5/12/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

/*
 TODO:
 [ ] 1.
 */

import Foundation

extension PlayerViewController{
    
    /**
     Function plays track provided a QCell and calls for appropriate images to load. Should be used in conjunction with unloading cells from the track queue.
     Triggered by notification "playSongFromQ". *Notification must contain object of type* **QCell**.
     If streaming (i.e. user created a room), the track will be loaded to firebase as the current playing track.
     */
    func streamAudioFromQ(notification : NSNotification){
        selectedQueueCell = notification.object as! QCell
        let playableURI:String = (selectedQueueCell.link?.absoluteString)!
        updateLablesAndArt(source: .dequeue)
        fireSetSong(cell: selectedQueueCell)
        
        self.player.playSpotifyURI(playableURI, startingWith: 0, startingWithPosition: 0) { (error) in
            if error != nil{
                print("\nERROR: " + error.debugDescription + "\n")
                print(error?.localizedDescription ?? "err")
                print("\n\nFAILED TO PLAY\n\n")
                return
            }
            self.musicPaused = false
            self.playPauseButton.setImage(UIImage(named:"pauseButton"), for: .normal)
            if !self.streaming{
                self.rotateImageAnimation(view: self.streamArtButton)
            }
        }
    }
    
    /**
     Function plays track provided a MusicCell and calls for appropriate images to load.
     Triggered by notification "playSongFromMusicCell". *Notification must contain object of type* **MusicCell**.
     If streaming (i.e. user created a room), the track will be loaded to firebase as the current playing track.
     */
    func streamAudioFromMusicCell(notification : NSNotification){
        var playableURI:String = "spotify:track:1jTTkIl0tfWitlf60ncUro"
        if notification.name.rawValue == "playSongFromMusicCell"{
            selectedMusicCell = notification.object as! MusicCell
            playableURI = (selectedMusicCell.link?.absoluteString)!
            updateLablesAndArt(source: .searchRequest)
            fireSetSong(cell: selectedMusicCell)
        }
        self.player.playSpotifyURI(playableURI, startingWith: 0, startingWithPosition: 0) { (error) in
            if error != nil{
                print("\nERROR: " + error.debugDescription + "\n")
                print(error?.localizedDescription ?? "err")
                print("\n\nFAILED TO PLAY\n\n")
                return
            }
        }
        
        musicPaused = false
        playPauseButton.setImage(UIImage(named:"pauseButton"), for: .normal)
        if !streaming{
            rotateImageAnimation(view: streamArtButton)
        }
    }
    
    /**
     *Provided a MusicCell*, function sets the track as the current track being played by the user in the firebase DB.
     *User should be streaming to take effect.*
     */
    func fireSetSong(cell:MusicCell){
        if streaming{
            //Generate key
            let refActiveSong = FIRDatabase.database().reference().child("Roombase/\(UserVariables.activeRoom)/6Songs/")//song playing actively on other devices
            let myTime:Double = ((NSDate().timeIntervalSince1970) * 1000)
            print(myTime)
            let timeLong = UInt64(myTime)
            let id:String = cell.trackID
            let song = ["1trackId":id, "2isPlaying":true, "3position": 0 as Int, "4timestamp": timeLong] as [String : Any]
            refActiveSong.setValue(song)
            print("Firebase song set")
        }
    }
    
    /**
     Used to indicate (through firebase) to other users listening to stream, that the user has paused playback.
     This function, however, *does not pause playback.*
     User should be streaming to take effect.
     */
    func firePausePlayback(){
        if streaming{
            let ref = FIRDatabase.database().reference().child("Roombase/\(UserVariables.activeRoom)/6Songs/2isPlaying")
            ref.setValue(false)
            print("Firebase track paused.")
        }
    }
    
    /**
     Used to indicate (through firebase) to other users listening to stream, that the user has resumed playback.
     This function, however, *does not pause playback.*
     User should be streaming to take effect.
     */
    func fireResumePlayback(){
        if streaming{
            let ref = FIRDatabase.database().reference().child("Roombase/\(UserVariables.activeRoom)/6Songs/2isPlaying")
            ref.setValue(true)
            print("Firebase track unpaused.")
        }
    }
    /**
     Updates the firebase track queue with tracks listed on local users queue.
     Function called through notification "trackIdQChanged".
     *Tracks must be provided* in a notification object as NSMutableArray of String.
     User should be streaming to take effect.
     */
    func fireUpdateQ(notification : NSNotification){
        if streaming{
            let refQ = FIRDatabase.database().reference().child("Roombase/\(UserVariables.activeRoom)/7Queue/")
            
            //Add to Q
            let arrayOfIDs: NSMutableArray = notification.object as! NSMutableArray
            var q:String = ""
            for trackID in arrayOfIDs{
                q += "\(trackID),"
            }
            
            //Add message to generated key
            refQ.setValue(q)
            
            print("Firebase Q updated")
        }
    }
    
    /**
     Sets users playback to tracks from activeRoom set in UserVariables.
     Tracks are gathered from firebase DB where the activeRoom lists its tracks.
     If there are tracks in the room that are queued, those are set as local user's queue as well.
     The local user's pre-existing queue is wiped out in the process.
     Sets variable streaming to false.
     */
    func listenToRoom(notification: NSNotification){
        streaming = false
        //userName = notification.object as! QCell
        let room = UserVariables.activeRoom
        
        //TEMPORARY hard code for testing! Create time stamp
        let myTime:Double = ((NSDate().timeIntervalSince1970) * 1000)
        let timeLongTimeStamp = UInt64(myTime)
        
        //Get current song
        let refSong = FIRDatabase.database().reference().child("Roombase/\(room)/6Songs/")
        refSong.observe(.value, with: {(snapshot) in
            guard let roomData = snapshot.value as? NSDictionary else {
                print("No room data for: \(room).")
                return
            }
            let trackID = roomData["1trackid"] as? String ?? ""
            let isPlaying = roomData["2isPlaying"] as? Bool ?? false
            let timeStamp = roomData["4timestamp"] as? UInt64 ?? 0
            
            if isPlaying{
                self.streamAudioFromID(id: trackID, position: 0, timeStamp: timeLongTimeStamp)
            }
            else{//update album art, pause track
                let position = roomData["3position"] as? Int ?? 0
                //implement when user pauses playback and user tunes in
            }
        })
        
        
        //load queue
        let refQ = FIRDatabase.database().reference().child("Roombase/\(room)/7Queue/")
        refQ.observe(.value, with: {(snapshot) in
            let qData = snapshot.value as? String ?? ""
            if qData != ""{
                let tracks = qData.split(separator: ",")
                print("Loading Room Queue..")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "clearQ"), object: nil)
                for track in tracks{
                    print(track)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "trackToQ"), object: track)
                }
            }
        })
        
    }
    
    /**Streams audio provided the track id, it's position, and timeStamp.
     Intended for playback of tracks listed in firebase DB.
     */
    func streamAudioFromID(id:String, position:Int, timeStamp:UInt64){
        let playableURI:String = "spotify:track:\(id)"
        print(playableURI)
        let trackURL = NSURL(string: playableURI) as URL!
        
        self.player.playSpotifyURI(playableURI, startingWith: 0, startingWithPosition: 0) { (error) in//TimeInterval(position)) { (error) in
            if error != nil{
                print("\nERROR: " + error.debugDescription + "\n")
                print(error?.localizedDescription ?? "err")
                print("\n\nFAILED TO PLAY\n\n")
                return
            }
            else{
                SPTTrack.track(withURI: trackURL, accessToken: self.session.accessToken, market: "US", callback: { (error, result) in
                        let track = result as! SPTTrack
                        let cell = MusicCell.init(style: .default, reuseIdentifier: "streamed")
                    
                        cell.link = track.playableUri
                        cell.trackID = id
                        cell.songName = track.name
                        let artist = track.artists.first as! SPTPartialArtist
                        cell.artistName = artist.name
                    self.getMusicCellAlbumArt(cell: cell, smallArtUrl: track.album.smallestCover.imageURL, largeArtUrl: track.album.largestCover.imageURL)
                        self.selectedMusicCell = cell
                    } as SPTRequestCallback!)
                
            }
        }
        
        musicPaused = false
        playPauseButton.setImage(UIImage(named:"pauseButton"), for: .normal)
    }
    
    /**
     Provided a MusicCell, fetch the album art, and load on to the views.
     */
    func getMusicCellAlbumArt(cell: MusicCell, smallArtUrl : URL, largeArtUrl : URL){
        var coverImageSmall : UIImage? = nil
        var coverImageLarge : UIImage? = nil
        
        DispatchQueue.global(qos: .userInitiated).async{
            do{
                let imageDataSmall = try Data(contentsOf: smallArtUrl)
                coverImageSmall = UIImage(data: imageDataSmall)
                let imageDataLarge = try Data(contentsOf: largeArtUrl)
                coverImageLarge = UIImage(data: imageDataLarge)
            }//End do
            catch{
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async{
                if coverImageSmall != nil{
                    //print("setting cover")
                    cell.artView.image = coverImageSmall
                    cell.smallArt = coverImageSmall!
                }
                else{
                    print("no image for search cell")
                }
                if coverImageLarge != nil{
                    //print("setting cover")
                    cell.largeArt = coverImageLarge!
                }
                else{
                    print("no image for search cell")
                }
                self.updateLablesAndArt(source: .stream)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showPulley"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "playerExtended"), object: nil)
            }//End dispatch main
        }//End Dispatch Global
    }
    
    
    
}

public struct UserVariables {
    static var userID = session.canonicalUsername!
    static var userName = ""
    static var activeRoom = ""
}

public enum PlaySource : Int{
    case searchRequest = 0
    case dequeue = 1
    case stream = 2

}
