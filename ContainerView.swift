//
//  ContainerView.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 7/6/17.
//  Copyright © 2017 HQZenithLabs. All rights reserved.
//

import Foundation

class ContainerView : UIViewController{
    
    var homeController:HomeViewController!
    var homeNavigator:UINavigationController!
    var searchController:SearchViewController!
    var libraryController:LibraryViewController!
    var libraryNavigator:UINavigationController!
    var profilesController:ProfilesViewController!
    var profilesNavigator:UINavigationController!
    var tabbedControllers:[UIViewController]!
    
    var container:UIView!//display view that does not show below or above bars
    
    private var _currentClientView:UIView? = nil
    private var _currentViewController:UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get session variable
        if let sessionObj:AnyObject = UserDefaults.standard.value(forKey: "SpotifySession") as AnyObject?{
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            session = firstTimeSession
        }
        
        //TabbedContainer informs this class when tab is switched
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerView.switchController(notification:)), name: Notification.Name(rawValue: "switchingTabs"), object: nil)
        
        //Home Tab init
        homeController = HomeViewController(userName: session.canonicalUsername)
        homeNavigator = UINavigationController(rootViewController: homeController)
        homeNavigator.navigationBar.topItem?.title = "Home"
        homeNavigator.navigationBar.barStyle = UIBarStyle.black
        homeNavigator.navigationBar.tintColor = UIColor.darkGray//text
        homeNavigator.navigationBar.barTintColor = UIColor.black//background
        homeNavigator.navigationBar.isTranslucent = false
        //Library Tab init
        libraryController = LibraryViewController(style: .plain)
        libraryNavigator = UINavigationController(rootViewController: libraryController)
        //Search Tab init
        searchController = SearchViewController()
        //Profiles Tab init
        profilesController = ProfilesViewController(userName: session.canonicalUsername)
        profilesNavigator = UINavigationController(rootViewController: profilesController)
        profilesNavigator.navigationBar.barTintColor = UIColor.init(patternImage: UIImage(named: "wallpaper")!)
        profilesNavigator.navigationBar.isTranslucent = false
        profilesNavigator.navigationBar.tintColor = UIColor.white
        
        tabbedControllers = [homeNavigator,libraryNavigator, searchController, profilesNavigator]
        container = UIView()//View that will hold views displayed by tab selection
        container.backgroundColor = UIColor.brown
        container.translatesAutoresizingMaskIntoConstraints = false
        
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.isTranslucent = false
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: view.topAnchor),//self.topLayoutGuide.topAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: (-49 * 2.3))
            ])
        
        //PRESENT FIRST VIEW CONTROLLER by adding the designated tab's view to the container container
        libraryNavigator.navigationBar.topItem?.title = "Library"
        //libraryNavigator.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.darkGray]
        libraryNavigator.navigationBar.barStyle = UIBarStyle.black
        libraryNavigator.navigationBar.tintColor = UIColor.darkGray//text
        libraryNavigator.navigationBar.barTintColor = UIColor.black//background
        libraryNavigator.navigationBar.isTranslucent = false
        
        _currentViewController = libraryNavigator
        displayContentController(libraryNavigator)
    }
    
    
    @objc func switchController(notification : NSNotification){
        let indexes = notification.object as! [Int]
        //_currentViewController = tabbedControllers[indexes[0]]
        let newViewController = tabbedControllers[indexes[1]]
        searchController.dismiss(animated: false, completion: nil)//prevents searchbar from appearing on different tabs
        if let activeViewController = self._currentViewController,
            type(of: activeViewController) !== type(of: newViewController) {
            //we have an active viewController that is not the destination, cycle
            self.cycleFromCurrentViewControllerToViewController(newViewController)
        } else {
            //no active viewControllers
            self.displayContentController(newViewController)
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return false
    }
    
    private func newViewStartFrame() -> CGRect {
        return CGRect(x: self.container.frame.origin.x,
                      y: self.container.frame.origin.y + self.container.frame.size.width,
                      width: self.container.frame.size.width,
                      height: self.container.frame.size.height)
    }
    
    private func oldViewEndFrame() -> CGRect {
        return CGRect(x: self.container.frame.origin.x,
                      y: self.container.frame.origin.y - self.container.frame.size.width,
                      width: self.container.frame.size.width,
                      height: self.container.frame.size.height)
    }

    
    
    //MARK: - Custom Content Controller Routing Methods
    private func frameForContentController() -> CGRect {
        return self.container.frame
    }
    
    
    /**
     Transitions viewControllers, adds-to/removes-from context, and animates views on/off screen.
     */
    private func cycleFromCurrentViewControllerToViewController(_ newViewController: UIViewController) {
        if let currentViewController = self._currentViewController {
            self.cycleFromViewController(currentViewController, toViewController: newViewController)
        }
    }
    
    private func cycleFromViewController(_ oldViewController:UIViewController, toViewController newViewController:UIViewController) {
        
        let endFrame = self.oldViewEndFrame()
        
        oldViewController.willMove(toParentViewController: nil)
        self.addChildViewController(newViewController)
        newViewController.view.frame = self.newViewStartFrame()
        
        self.transition(from: oldViewController, to: newViewController,
                        duration: 0.0,
                        options: [],
                        animations: { () -> Void in
                            newViewController.view.frame = oldViewController.view.frame
                            oldViewController.view.frame = endFrame
        }) { (finished:Bool) -> Void in
            self.hideContentController(oldViewController)
            self.displayContentController(newViewController)
        }
    }
    
    
    /**
     Adds a view controller to the hierarchy and displays its view
     */
    private func displayContentController(_ contentController: UIViewController) {
        self.addChildViewController(contentController)
        contentController.view.frame = self.frameForContentController()
        self._currentClientView = contentController.view
        self.container.addSubview(self._currentClientView!)//self.view.addSubview(self._currentClientView!)
        self._currentViewController = contentController
        contentController.didMove(toParentViewController: self)
    }
    
    /**
     Removes a previously added view controller from the hierarchy
     */
    private func hideContentController(_ contentController: UIViewController) {
        contentController.willMove(toParentViewController: nil)
        if (self._currentViewController == contentController) {
            self._currentViewController = nil
        }
        contentController.view.removeFromSuperview()
        contentController.removeFromParentViewController()
        
    }
    
}
