//
//  SearchViewController.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 4/22/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//


/**
 TODO:
 [ ] 5. Prefetch data, increase limit of result cells shown
 
 BUGS:
 [ ] 1. Typing too fast causes a missing letter on search results
 */

import Foundation

var searchController = UISearchController(searchResultsController: nil)
var searchText : String = ""
var songListPage : SPTListPage = SPTListPage.init()
var artistListPage : SPTListPage = SPTListPage.init()
var userRef:FIRDatabaseReference!
var scope = 0
var searchCount = 0
var session: SPTSession!
var arrayOfFollowing:[String] = []
///For timing search requests
var timer:Timer!

class SearchViewController :  UITableViewController, UISearchControllerDelegate {

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchController.searchBar.showsScopeBar = false
    }
    
    override func viewDidLoad() {
        print("xxxxxxxxxxxxxxxxxxxxxxxxx SEARCH CONTROLLER view did load xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
        super.viewDidLoad()
        //self.setNeedsStatusBarAppearanceUpdate()
        
        //get session variable
        if let sessionObj:AnyObject = UserDefaults.standard.value(forKey: "SpotifySession") as AnyObject?{
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            session = firstTimeSession
        }
        
        //Register cell class
        self.tableView.register(SearchCell.self, forCellReuseIdentifier: "ResultCell")
        self.tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        searchController.searchBar.barTintColor = UIColor.black
        tableView.backgroundView = UIImageView(image: UIImage(named: "wallpaper"))
        tableView.separatorColor = UIColor.clear
        searchController.searchBar.scopeButtonTitles = ["Songs", "Artists", "Users"]
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        //let searchBarTextField = searchController.searchBar.value(forKey: "_searchField") as! UITextField
        //searchBarTextField.delegate = self
        tableView.dataSource = self
        
        searchController.searchBar.autocorrectionType = UITextAutocorrectionType.no
        searchController.hidesNavigationBarDuringPresentation = true
        self.edgesForExtendedLayout = []
        self.definesPresentationContext = true
        tableView.tableFooterView = UIView()//removes empty cells
        tableView.backgroundColor = UIColor.black
        
        //Set searchbar position
        searchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
        searchController.searchBar.sizeToFit()
        searchController.searchBar.isTranslucent = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.isActive = true //ADDED B/C KEYBOARD WAS NOT APPEARING.
        
        
        searchController.extendedLayoutIncludesOpaqueBars = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchController.searchBar.becomeFirstResponder()
    }
    
    
    //POPULATE CELLS
    //Does not currently retrieve next listpage, so only 20 results will show.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt. searchText: " + searchController.searchBar.text!)
        if scope == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as? SearchCell
            print("Index: \(indexPath.row), Range: \(songListPage.items.count), SearchCount: \(searchCount)")
            guard let partialTrack = songListPage.items[indexPath.row] as? SPTPartialTrack
                else {
                    //throw SearchError.outOfRange
                    print("Search index out of range")
                    cell?.prepareForReuse()
                    return cell!
            }
                
                cell?.link = partialTrack.playableUri
                cell?.trackID = partialTrack.identifier
                cell?.topLabel.text = partialTrack.name
                let artist = partialTrack.artists.first as! SPTPartialArtist
                cell?.lowerLabel.text = artist.name
                setAlbumArt(cell: cell!,smallArtUrl: partialTrack.album.smallestCover.imageURL, largeArtUrl: partialTrack.album.largestCover.imageURL)
                
                //Info
                cell?.artistName = artist.name
                cell?.songName = partialTrack.name
            
            return cell!
        }
        else if scope == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as? SearchCell
            print("scope is 1")
            cell?.prepareForReuse()
            
            if (indexPath.row < artistListPage.range.length){
                let partialArtist = artistListPage.items[indexPath.row] as! SPTPartialArtist
                cell?.lowerLabel.isHidden = true
                cell?.artView.isHidden = true
                cell?.topLabel.isHidden = true
                cell?.button.isHidden = true
                cell?.singleLabel.isHidden = false
                cell?.singleLabel.text = partialArtist.name
            }
            else{
                print("out of range")
            }
            
            return cell!
        }
        else if scope == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell
            cell?.setUsername(userID: searchText, displayName: "")
            cell?.setStatusTextToWhite()
            
            getFollowing()
            if arrayOfFollowing.contains(searchText){
                cell?.disableFollowButton()
            }
            
            //Get recent status
            userRef = FIRDatabase.database().reference().child("Userbase/\(searchText)/6Statuses/")
            userRef.observeSingleEvent(of: .value, with: {(snapshot) in
                var statuses = [String]()
                for data in snapshot.children.allObjects as! [FIRDataSnapshot]{
                    if let dataDict = data.value as? [String:Any]{
                        let status = dataDict["1status"] as? String
                        statuses.append(status!)
                    }
                }
                if statuses.last! != nil{
                    cell?.setDisplayStatus(asStatus: statuses.last!)
                }
            })
            
            //Get Firebase Profile Pic
            userRef = FIRDatabase.database().reference().child("Userbase/\(searchText)/3Image/")
            userRef.observeSingleEvent(of: .value, with: {(snapshot) in
                let userImage = snapshot.value as! String
                cell?.setProfilePic(imageURL: URL(string: userImage)!)
            })
            return cell!
        }
        let cell = UITableViewCell()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65)
    }
    
    //Takes care of when you select things
    //We want it to flash off after user has pressed cell
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! SearchCell
        
        searchController.searchBar.resignFirstResponder()
        if (searchController.searchBar.selectedScopeButtonIndex == 0)
        {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "playSongFromMusicCell"), object: selectedCell)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Number of cells/items
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numOfRowsInSection. Count: \(searchCount), searchText: " + searchController.searchBar.text!)
        if searchText == ""{
            //print("1: searchText empty")
            return 0
        }
        else if searchCount > 20{
            return 20
        }
        
        return searchCount
    }//END NUMBEROFROWSINSECTION
    
    //Sets a cell's album art provided a URL
    func setAlbumArt(cell : SearchCell, smallArtUrl : URL, largeArtUrl : URL){
        //Set proper labels to show
        cell.lowerLabel.isHidden = false
        cell.artView.isHidden = false
        cell.topLabel.isHidden = false
        cell.singleLabel.isHidden = true
        
        //Set cover
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
                    cell.largeArt = coverImageLarge!
                }
                else{
                    print("no image for search cell")
                }
            }//End dispatch main
            
        }//End Dispatch Global
    }
    
    //Scope 0 = songs
    //Scope 1 = artists
    //Scope 2, users
    @objc func sendSearchRequest(){
        print("sendSearchRequest")
        var type : SPTSearchQueryType = SPTSearchQueryType.queryTypeTrack
        
        if (session.accessToken == nil)
        {
            print("nil session")
            return
        }
        searchText = searchController.searchBar.text!
        print("searchtext!: \(searchText)")
        if scope == 2{
            let ref = FIRDatabase.database().reference().child("Userbase/\(searchText)/")
            ref.observeSingleEvent(of: .value, with:{(snapshot) in
                if (snapshot.value as? NSDictionary) == nil{
                    print("User does not exist in firebase db.")
                }
                else{
                    searchCount = 1
                    userRef = ref
                    self.tableView.reloadData()
                }
            })
        }
        else{
            if scope == 1{
                type = SPTSearchQueryType.queryTypeArtist
            }
            
            SPTSearch.perform(withQuery: searchText, queryType: type, offset: 0, accessToken: session.accessToken, market: "US",
                              callback: {(error, results) in
                                var trackListPage : SPTListPage
                                if error == nil{
                                    trackListPage = results as! SPTListPage
                                    
                                    searchCount = Int(trackListPage.totalListLength)
                                    if scope == 0{
                                        songListPage = trackListPage
                                    }
                                    else{//forScope = 1
                                        artistListPage = trackListPage
                                    }
                                }
                                else {
                                    print(error ?? "Error in search.")}
                                self.tableView.reloadData()
                                }as SPTRequestCallback!)//End callback, end SPTSearch.perform
        }
    }
    
    func getFollowing(){
        //Generate key
        let refQ = FIRDatabase.database().reference().child("Userbase/\(session.canonicalUsername!)/5Following/")
        refQ.observeSingleEvent(of: .value, with: {(snapshot) in
            if let following = snapshot.value as? NSDictionary{
                for name in following{
                    arrayOfFollowing.append(name.value as! String)
                }
                self.tableView.reloadData()
            }
            else{
                print("User not following.")
            }
        })
    }
    
    
}


extension SearchViewController : UISearchBarDelegate, UISearchResultsUpdating{//UITextFieldDelegate
    
    func updateSearchResults(for searchController: UISearchController) {
        print("updateSearchResults")
        searchText = searchController.searchBar.text!
        timer?.invalidate()//cancel previous timer
        if searchText.characters.count > 3{
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SearchViewController.sendSearchRequest), userInfo: nil, repeats: false)
        }
    }

    
    //To apply this method, searchBar delegate is made self in viewDidLoad
    //Method allows this class to control what happens when the search scope is changed from song, to artist, or etc
    //Method intends to change the scope1 even if search text remains the same for a different set of data(tracks/artists/etc)
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("scopeButtonIndexDidChange")
        scope = selectedScope
        if searchText.characters.count > 3{
            sendSearchRequest()
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchCount = 0
        tableView.reloadData()
    }
    /*
    //Wait half a second before sending search request
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        timer?.invalidate()//cancel previous timer
        let currentText = textField.text ?? ""
        if (currentText as NSString).replacingCharacters(in: range, with: string).characters.count >= 3{
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SearchViewController.sendSearchRequest), userInfo: nil, repeats: false)
        }
        return true
    }*/
}


