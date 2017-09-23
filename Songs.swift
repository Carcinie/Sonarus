//
//  Songs.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 8/20/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

//Display list for Songs, Recently played
class Songs:UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.darkGray
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.tableFooterView = UIView()//removes empty cells
        tableView.backgroundColor = UIColor.black
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65)
    }
    
    //POPULATE CELLS
    //Does not currently retrieve next listpage, so only 20 results will show.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //print("2. Populate Cell")
        //deque grabs cell that has already scrolled off of the screen, and resuses it. Saves mem, allows quicker scroll
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as? SearchCell
        
        print("cellForRowAt. searchText: " + searchController.searchBar.text!)
        if scope == 0 {
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
            //setAlbumArt(cell: cell!,smallArtUrl: partialTrack.album.smallestCover.imageURL, largeArtUrl: partialTrack.album.largestCover.imageURL)
            
            //Info
            cell?.artistName = artist.name
            cell?.songName = partialTrack.name
            
            
        }
        else if scope == 1{
            print("scope is 1")
            cell?.prepareForReuse()
            
            if (indexPath.row < artistListPage.range.length){
                print("Within Range")
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
            
            
        }
        else if scope == 2{
            
        }
        return cell!
    }
    
}
