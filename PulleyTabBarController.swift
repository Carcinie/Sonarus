//
//  PulleyTabBarController.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 7/8/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

class PulleyTabBarController: PulleyViewController, UITabBarDelegate{
    var tabBar : UITabBar!
    var itemToReplace:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ADD TABBAR--------------------------------------------------------------------------------------------------------
        tabBar = UITabBar()
        tabBar.delegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        //tabBar.tintColor = UIColor.black
        tabBar.barTintColor = UIColor.black
        view.addSubview(tabBar)
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        //ADD TABS----------------------------------------------------------------------------------------------------------
        let icon0 = UITabBarItem(title: "", image: UIImage(named: "tabHome"), tag: 1)
        icon0.imageInsets = UIEdgeInsetsMake(4, 0, -4, 0)
        icon0.title = nil
        let icon1 = UITabBarItem(title: "", image: UIImage(named: "tabLibrary"), tag: 1)
        icon1.imageInsets = UIEdgeInsetsMake(4, 0, -4, 0)
        icon1.title = nil
        let icon2 = UITabBarItem(title: "", image: UIImage(named: "tabSearch"), tag: 2)
        icon2.imageInsets = UIEdgeInsetsMake(4, 0, -4, 0)
        icon2.title = nil
        let icon3 = UITabBarItem(title: "", image: UIImage(named: "tabProfile"), tag: 2)
        icon3.imageInsets = UIEdgeInsetsMake(4, 0, -4, 0)
        icon3.title = nil
        tabBar.items = [icon0, icon1, icon2, icon3]
        tabBar.selectedItem = icon1
        
        //Mechanism to show pulley in other classes
        NotificationCenter.default.addObserver(self, selector: #selector(PulleyTabBarController.extendPulley), name: Notification.Name(rawValue: "showPulley"), object: nil)
    }
    
    public func collapsePulley(){
        setDrawerPosition(position: .collapsed)
    }
    public func extendPulley(){
        setDrawerPosition(position: .open)
    }
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        collapsePulley()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "playerCollapsed"), object: nil)
        if tabBar.items?.index(of: item) == 0
        {
            print("Home tab selected")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "switchingTabs"), object: [itemToReplace, 0])
            itemToReplace = 0
        }
        else if tabBar.items?.index(of: item) == 1{
            print("Library tab selected")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "switchingTabs"), object: [itemToReplace, 1])
            itemToReplace = 1
        }
        else if tabBar.items?.index(of: item) == 2{
            print("Search tab selected")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "switchingTabs"), object: [itemToReplace, 2])
            itemToReplace = 2
        }
        else if tabBar.items?.index(of: item) == 3{
            print("Settings tab selected")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "switchingTabs"), object: [itemToReplace,3])
            itemToReplace = 3
        }
    }
    

}
