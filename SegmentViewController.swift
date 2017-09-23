//
//  SegmentViewController.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 6/7/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

//View controller that switches between chat view and music queue view
class SegmentViewController:UIViewController{
    private var chatView:ChatViewController!
    private var musicQueueView:SongQueueController!
    private var chatHidden:Bool = true
    
    override func viewDidLoad() {
        chatView = ChatViewController()
        musicQueueView = SongQueueController()
        musicQueueView.view.translatesAutoresizingMaskIntoConstraints = false
        chatView.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(musicQueueView.view)
        view.addSubview(chatView.view)
        
        NSLayoutConstraint.activate([
                musicQueueView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                musicQueueView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                musicQueueView.view.topAnchor.constraint(equalTo: view.topAnchor),
                musicQueueView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                //musicQueueView.view.heightAnchor.constraint(equalTo: view.heightAnchor),
                chatView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                chatView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                chatView.view.topAnchor.constraint(equalTo: view.topAnchor),
                chatView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                //chatView.view.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])
        chatView.view.isHidden = true
    }
    
    
    func showChat(){
        /* Useful for when views have same parent controller. Not this case, but left here for when needed.
        chatView.view.frame = musicQueueView.view.frame
        musicQueueView.willMove(toParentViewController: nil)
        self.addChildViewController(chatView)
        self.transition(from: musicQueueView, to: chatView, duration: 0.6, options: .transitionCrossDissolve, animations: {}, completion: {(finished:Bool) in
            self.musicQueueView.removeFromParentViewController()
            self.chatView.didMove(toParentViewController: self)
        })
        */
        
        chatHidden = false
        chatView.view.isHidden = false
        musicQueueView.view.isHidden = true
        view.layoutIfNeeded()
    }
    func showMusicQueue(){
        /*
        musicQueueView.view.frame = chatView.view.frame
        chatView.willMove(toParentViewController: nil)
        self.addChildViewController(musicQueueView)
        self.transition(from: chatView, to: musicQueueView, duration: 0.6, options: .transitionCrossDissolve, animations: {}, completion: {(finished:Bool) in
            self.chatView.removeFromParentViewController()
            self.musicQueueView.didMove(toParentViewController: self)
        })
        */
        
        chatHidden = true
        chatView.view.isHidden = true
        musicQueueView.view.isHidden = false
    }
}
