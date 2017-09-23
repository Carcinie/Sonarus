//
//  MenuCell.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 8/19/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

class MenuCell: UITableViewCell {
    private let label = UILabel()
    private let bottomLine = UIButton()
    private let icon = UIButton(type: UIButtonType.system)
    private let addToQueue = UIButton()
    private var labelLeadingConstraint:NSLayoutConstraint!
    private var button:UIButton!
    private var playlist:SPTPartialPlaylist!
    private var notification:String = ""
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = label.font.withSize(16)
        label.textColor = UIColor.white
        self.backgroundColor = UIColor.clear//superview?.backgroundColor
        //self.backgroundView = UIImageView(image: UIImage(named: "cellBackground"))
        contentView.addSubview(label)
        contentView.addSubview(bottomLine)
        labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        
        NSLayoutConstraint.activate([
            labelLeadingConstraint,
            label.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLabel(named:String){
        label.text = named
    }
    
    func setIcon(withImageNamed:String){
        icon.setImage(UIImage(named: withImageNamed), for: .normal)
        icon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(icon)
        icon.tintColor = UIColor.init(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            ])
        
        //Move label
        labelLeadingConstraint.isActive = false
        labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 5)
        labelLeadingConstraint.isActive = true
    }
    
    func turnOnLines(){
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.setImage(UIImage(named: "lineSeparator"), for: .normal)
        bottomLine.tintColor = UIColor.black//init(red: 0.0, green: 195/255, blue: 229.0, alpha: 0.5)
        bottomLine.backgroundColor = UIColor.clear
        
        NSLayoutConstraint.activate([
                bottomLine.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                bottomLine.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
                bottomLine.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
                bottomLine.heightAnchor.constraint(equalToConstant: 1)
            ])
    }
    
    func addPlaylistQueueButton(playlist:SPTPartialPlaylist){
        button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(playlistToQueueButtonPress), for: .touchUpInside)
        button.setImage(UIImage(named: "qButton"), for: .normal)
        button.tintColor = UIColor.init(red: 0.0, green: 122/255, blue: 1.0, alpha: 1)
        self.playlist = playlist
        NSLayoutConstraint.activate([
                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
                button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
    }
    
    func getPlaylist()->SPTPartialPlaylist{
        return playlist
    }
    
    @objc func playlistToQueueButtonPress(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: "playlistForQueue"), object: playlist)
    }
}
