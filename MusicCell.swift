//
//  MusicCell.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 7/13/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

class MusicCell:UITableViewCell{
    
    
    let topLabel = UILabel()
    let lowerLabel = UILabel()
    let singleLabel = UILabel()
    let artView = UIImageView()
    let button = UIButton()
    private let bottomLine = UIButton()
    
    //Info
    var smallArt = UIImage()
    var largeArt = UIImage()
    var link = URL(string:"")     //playableURI
    var songName = ""
    var artistName = ""
    var trackID = ""
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.black
        self.topLabel.textColor = UIColor.white
        self.lowerLabel.textColor = UIColor.gray
        self.singleLabel.textColor = UIColor.white
        self.clipsToBounds = true
        self.contentView.clipsToBounds = true
        
        //AUTO-LAYOUT
        
        
        //Remove Autoresizing Mask so Autolayout does not declare positioning at runtime, but we do
        artView.translatesAutoresizingMaskIntoConstraints = false
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        lowerLabel.translatesAutoresizingMaskIntoConstraints = false
        singleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        //Adding views
        self.contentView.addSubview(artView)
        self.contentView.addSubview(topLabel)
        self.contentView.addSubview(lowerLabel)
        self.contentView.addSubview(singleLabel)
        self.contentView.addSubview(button)
        self.contentView.addSubview(bottomLine)
        //button.setImage(UIImage(named: "qButton"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        //Options
        artView.sizeToFit()
        artView.contentMode = .scaleAspectFit
        lowerLabel.font = lowerLabel.font.withSize(11)
        
        //Constraints
        NSLayoutConstraint.activate([
            topLabel.leftAnchor.constraint(equalTo: artView.rightAnchor, constant: 3),
            topLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            lowerLabel.leftAnchor.constraint(equalTo: artView.rightAnchor, constant: 3),
            lowerLabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 2),
            singleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8),
            singleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            artView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            artView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            button.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            button.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -5),
            button.heightAnchor.constraint(equalTo: self.contentView.heightAnchor)
            ])
        
    }
    
    func turnOnLines(){
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.setImage(UIImage(named: "lineSeparator"), for: .normal)
        bottomLine.tintColor = UIColor.init(red: 0.0, green: 195/255, blue: 229.0, alpha: 0.5)
        bottomLine.backgroundColor = UIColor.clear
        
        NSLayoutConstraint.activate([
            bottomLine.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            bottomLine.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonPressed(_ sender: AnyObject?){
        preconditionFailure("This method must be overridden")
    }
    
    func hideButton(){
        button.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
