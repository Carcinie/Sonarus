//
//  Playlists.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 8/19/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

//Display menu for playlists
class Playlists:UITableViewController{
    var user:String!
    var playlistPage:SPTPartialPlaylist!
    var playlistsCount = 0
    var playlists = [SPTPartialPlaylist]()
    var session:SPTSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(MenuCell.self, forCellReuseIdentifier: "Playlist")
        view.backgroundColor = UIColor.darkGray
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.tableFooterView = UIView()//removes empty cells
        tableView.backgroundColor = UIColor.black
        tableView.backgroundView = UIImageView(image: UIImage(named: "wallpaper"))
        tableView.separatorColor = UIColor.clear
        //NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.loginSetup), name: Notification.Name(rawValue: "addPlaylistToQueue"), object: nil)
        
        //get session variable
        if let sessionObj:AnyObject = UserDefaults.standard.value(forKey: "SpotifySession") as AnyObject?{
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            session = firstTimeSession
        }
        
        getUserPlaylists()
    }
    
    func getUserPlaylists(){
        SPTPlaylistList.playlists(forUser: session.canonicalUsername, withAccessToken: session.accessToken, callback: {(error, results) in
            if error == nil{
                //print("0: no error")
                let listPage = results as! SPTPlaylistList
                self.playlistsCount = Int(listPage.totalListLength)
                self.playlists = listPage.items as! [SPTPartialPlaylist]
                self.tableView.reloadData()
                if listPage.hasNextPage{
                    self.getNextPage(currentPage: listPage)
                }
            }
            else {
                print(error ?? "Error in getting playlist metadata.")}
            self.tableView.reloadData()
            }as SPTRequestCallback!)
    }
    
    func getNextPage(currentPage:SPTPlaylistList){
        currentPage.requestNextPage(withAccessToken: session.accessToken, callback: {(error, result) in
            let newPage = result as? SPTPlaylistList
            let extraPlaylists = newPage?.items as? [SPTPartialPlaylist]
            for playlist in extraPlaylists!{
                self.playlists.append(playlist)
            }
            self.tableView.reloadData()
            if (newPage?.hasNextPage)!{
                self.getNextPage(currentPage: newPage!)
            }
        })
            
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MenuCell
        var controller:UIViewController! = PlaylistSong(playlist: cell.getPlaylist())
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistsCount
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65)
    }
    
    //Set Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //deque grabs cell that has already scrolled off of the screen, and resuses it. Saves mem, allows quicker scroll
        let cell = tableView.dequeueReusableCell(withIdentifier: "Playlist", for: indexPath) as? MenuCell
        cell?.setLabel(named: playlists[indexPath.row].name)
        cell?.addPlaylistQueueButton(playlist: playlists[indexPath.row])
        cell?.turnOnLines()
        return cell!
    }
    
    
}
