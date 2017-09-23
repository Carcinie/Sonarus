//
//  ChatCell.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 5/3/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    let chatCellLabel : UILabel = UILabel()
    var cellText : NSMutableAttributedString!
    //private let bubbleImageView = UIImageView()
    private var outgoingConstraints : [NSLayoutConstraint]!
    private var incomingConstraints : [NSLayoutConstraint]!
    var u:String = ""//user
    var t:String = ""//message text
    var i:Int = 100//index
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        chatCellLabel.translatesAutoresizingMaskIntoConstraints  = false
        //bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        //contentView.addSubview(bubbleImageView)
        contentView.addSubview(chatCellLabel)
        
        
        NSLayoutConstraint.activate([
                chatCellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                chatCellLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                chatCellLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
                chatCellLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
        
        
        //messageLabel.centerXAnchor.constraint(equalTo: bubbleImageView.centerXAnchor).isActive = true
        //messageLabel.centerYAnchor.constraint(equalTo: bubbleImageView.centerYAnchor).isActive = true
        //So speech bubble grows with text size
        //bubbleImageView.widthAnchor.constraint(equalTo: messageLabel.widthAnchor, constant: 50).isActive = true //50 accounts for tail in image
        //bubbleImageView.heightAnchor.constraint(equalTo: messageLabel.heightAnchor, constant:20).isActive = true//20 constant for padding text
        /*bubbleImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        
        //One of the following will activate depending on message incoming/outgoing
        outgoingConstraint = bubbleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        incomingConstraint = bubbleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        
        outgoingConstraints = [
            //bubbleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),//flush bubble right
            //bubbleImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.centerXAnchor)//not farther than center
        ]
        incomingConstraints = [
            //bubbleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            //bubbleImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.centerXAnchor)
        ]
 */
        //bubbleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true//constant for padding
        //bubbleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        //bubbleImageView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        chatCellLabel.textAlignment = .left
        chatCellLabel.numberOfLines = 0
        
        //let image = UIImage(named:"MessageBubble")?.withRenderingMode(.alwaysTemplate)
        //bubbleImageView.tintColor = UIColor.blue
        //bubbleImageView.image = image
        
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("cell Reuse - Previous text: \(t), index: \(i)")
        self.chatCellLabel.attributedText = nil
        u = ""
        t = ""
        i = 100
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Bubble image flush left or right, depending on incoming or outgoing
    func setText(isIncoming:Bool, user:String, message:String){
        let nameLength = user.characters.count + 1
        let messageLength = message.characters.count + 1
        if isIncoming{
            cellText = NSMutableAttributedString(string: user + ": " + message, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 12)!])
            cellText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.blue, range: NSMakeRange(0, nameLength))
            cellText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSMakeRange(nameLength, messageLength))
            chatCellLabel.attributedText = cellText
            /*incomingConstraint.isActive = true
            outgoingConstraint.isActive = false*/
       //     NSLayoutConstraint.deactivate(outgoingConstraints)
       //     NSLayoutConstraint.activate(incomingConstraints)
            //bubbleImageView.image = bubble.incoming//calls makeBubble method
        }
        else{//message isOutgoing
            cellText = NSMutableAttributedString(string: user + ": " + message, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 13)!])
            print(cellText)
            print(cellText.length)
            
            cellText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSMakeRange(0, nameLength))
            cellText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSMakeRange(nameLength, messageLength))
            chatCellLabel.attributedText = cellText
            /*incomingConstraint.isActive = false
            outgoingConstraint.isActive = true*/
       //     NSLayoutConstraint.deactivate(incomingConstraints)
       //     NSLayoutConstraint.activate(outgoingConstraints)
            //bubbleImageView.image = bubble.outgoing//calls makeBubble method
        }
    }

}


//let bubble = makeBubble()


/*
func makeBubble() -> (incoming : UIImage, outgoing : UIImage){
    let image = UIImage(named:"MessageBubble")!
    
    let insetsIncoming = UIEdgeInsets(top: 17, left: 26.5, bottom: 17.5, right: 21)
    let insetsOutgoing = UIEdgeInsets(top: 17, left: 21, bottom: 17.5, right: 26.5)
    
    
    let outgoing = coloredImage(image: image, red: 0/255, green: 122/255, blue: 255/255, alpha:1).resizableImage(withCapInsets: insetsOutgoing)
    
    let flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: UIImageOrientation.upMirrored)
    let incoming = coloredImage(image: flippedImage, red: 229/255, green: 229/255, blue: 229/255, alpha:1).resizableImage(withCapInsets: insetsIncoming)
    
    return(incoming, outgoing)
}

func coloredImage(image: UIImage, red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) -> UIImage{
    let rect = CGRect(origin: CGPoint.zero, size: image.size)
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.draw(in: rect)
    context?.setFillColor(red: red, green: green, blue: blue, alpha: alpha)
    context?.setBlendMode(CGBlendMode.sourceAtop)
    context?.fill(rect)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return result!
}
 */




