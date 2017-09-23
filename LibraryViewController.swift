//
//  LibraryViewController.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 7/7/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

/**
 TODO:
 [ ] 1.

 */

import Foundation
import SafariServices

class LibraryViewController : UITableViewController{
    var safariViewController:SFSafariViewController!
    var didShowLogin:Bool = false
    var musicMenu = ["Playlists","Songs", "Artists", "Recent"]
    var menuCells:[UITableViewCell] = []
    
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.tableFooterView = UIView()//removes empty cells
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = UIColor.black
        tableView.backgroundView = UIImageView(image: UIImage(named: "wallpaper"))
        tableView.separatorColor = UIColor.clear
        cellMenuSetup()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(LibraryViewController.presentSpotifyLogin), name: Notification.Name(rawValue: "presentLogin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LibraryViewController.dismissSpotifyLogin), name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if didShowLogin == false{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "setupLogin"), object: nil)
            didShowLogin = true
        }
        
    }
    
    //TableView setup
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicMenu.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65)
    }
    
    func cellMenuSetup(){
        for menuName in musicMenu{
            let menuCell = MenuCell.init(style: .default, reuseIdentifier: menuName)//different cell ident to make cells "static"
            menuCell.setLabel(named: menuName)
            menuCell.setIcon(withImageNamed: menuName)
            menuCell.turnOnLines()
            menuCells.append(menuCell)
        }
    }
    
    /*
    //Allow seperators between cells to stretch accross view
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }*/
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        let cell = menuCells[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var controller:UIViewController!
        if indexPath.row == 0 || indexPath.row == 2{
            controller = Playlists()
        }
        else if indexPath.row == 1{
            controller = Songs()
        }
        else if indexPath.row == 2{
           //controller = Artists()
        }
        else{
            //controller = RecentlyPlayed()
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

//Present Spotify Login
extension LibraryViewController{
    @objc func presentSpotifyLogin(notification : NSNotification){
        let loginURL:URL = notification.object as! URL
        safariViewController = SFSafariViewController(url: loginURL, entersReaderIfAvailable: false)
        present(safariViewController, animated: true)
    }
    @objc func dismissSpotifyLogin(){
        safariViewController.dismiss(animated: true, completion: nil)
    }
}
