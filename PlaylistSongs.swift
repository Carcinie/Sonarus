//
//  PlaylistSongs.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 8/21/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

/*TODO
[] 1. Add whole playlist to queue from song chosen, with repeat option
*/

import Foundation

class PlaylistSong:UITableViewController{
    var partialPlaylist:SPTPartialPlaylist!
    var tracks = [SPTPartialTrack]()
    var trackCount:Int = 0
    
    init(playlist: SPTPartialPlaylist) {
        super.init(nibName: nil, bundle: nil)
        self.partialPlaylist = playlist
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(SongCell.self, forCellReuseIdentifier: "PlaylistSongs")
        view.backgroundColor = UIColor.darkGray
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.tableFooterView = UIView()//removes empty cells
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor.clear
        
        //NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.loginSetup), name: Notification.Name(rawValue: "addPlaylistToQueue"), object: nil)
        
        //get session variable
        if let sessionObj:AnyObject = UserDefaults.standard.value(forKey: "SpotifySession") as AnyObject?{
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            session = firstTimeSession
        }
        getPlaylistSongs()
    }
    
    func getPlaylistSongs(){
        //First, extract full playlist snapshot
        SPTPlaylistSnapshot.playlist(withURI: partialPlaylist.playableUri, accessToken: session.accessToken, callback: {(error, result) in
            if error != nil{
                print("Error: getting playlist tracks for queue")
            }
            let snapshot = result as? SPTPlaylistSnapshot
            let listPage:SPTListPage = (snapshot?.firstTrackPage)!
            self.extractListPageTracks(listPage: listPage)
            if listPage.hasNextPage{
                self.getNextPage(currentPage: listPage)
            }
            else{//End
                self.trackCount = listPage.items.count
                self.tableView.reloadData()
            }
            } as SPTRequestCallback!)
    }
    
    func extractListPageTracks(listPage:SPTListPage){
        let pageCount:Int = (listPage.items.count) - 1
        for index in 0...pageCount{
            let track:SPTPartialTrack = (listPage.items[(index)] as? SPTPartialTrack)!
            if !track.uri.absoluteString.contains("spotify:local"){
                tracks.append(track)
                //self.getFullTrackAndAddToList(uri: track.uri)
            }
        }
    }
    
    func getNextPage(currentPage: SPTListPage){
        currentPage.requestNextPage(withAccessToken: session.accessToken, callback: {(error, result) in
            let newPage = result as! SPTListPage
            self.extractListPageTracks(listPage: newPage)
            if newPage.hasNextPage{
                self.getNextPage(currentPage: newPage)
                self.trackCount += newPage.items.count
            }
            else{//end
                self.trackCount += newPage.items.count
                self.tableView.reloadData()
            }
        })
    }
    
    //Set Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //deque grabs cell that has already scrolled off of the screen, and resuses it. Saves mem, allows quicker scroll
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistSongs", for: indexPath) as? SongCell
        
        if indexPath.row <= (tracks.count - 1){
            let currentTrack = tracks[indexPath.row]
            
            cell?.link = currentTrack.playableUri
            cell?.trackID = currentTrack.identifier
            cell?.topLabel.text = currentTrack.name
            let artist = currentTrack.artists.first as! SPTPartialArtist
            cell?.lowerLabel.text = artist.name
            setAlbumArt(cell: cell!,smallArtUrl: currentTrack.album.smallestCover.imageURL, largeArtUrl: currentTrack.album.largestCover.imageURL)
            
            //Info
            cell?.artistName = artist.name
            cell?.songName = currentTrack.name
        }
        else{//local mp3 from computer produce empty cells
            cell?.hideButton()
            cell?.selectionStyle = .none
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! SongCell
        print(selectedCell.link)
        //let link = selectedCell.link
        NotificationCenter.default.post(name: Notification.Name(rawValue: "playSongFromMusicCell"), object: selectedCell)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackCount
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65)
    }
    
    //Sets a cell's album art provided a URL
    func setAlbumArt(cell : SongCell, smallArtUrl : URL, largeArtUrl : URL){
        //Set proper labels to show
        cell.lowerLabel.isHidden = false
        cell.artView.isHidden = false
        cell.topLabel.isHidden = false
        cell.singleLabel.isHidden = true
        //Set cover
        //print("Getting album art from url")
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
                    print("no image for cell")
                }
                if coverImageLarge != nil{
                    //print("setting cover")
                    cell.largeArt = coverImageLarge!
                }
                else{
                    print("no image for cell")
                }
            }//End dispatch main
            
        }//End Dispatch Global
    }
    
}
