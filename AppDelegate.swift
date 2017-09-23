//
//  AppDelegate.swift
//  Sonarus
//
//  Created by Christopher Arciniega on 9/16/16.
//  Copyright © 2016 HQZenithLabs. All rights reserved.
//

import UIKit



@UIApplicationMain
//SPTAudioStreamingDelegate protocol to receive callbacks
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate {
    
    var window: UIWindow?
    var auth = SPTAuth()
    var ref: FIRDatabaseReference!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        auth.redirectURL = NSURL(string: kCallbackURL) as URL!
        auth.sessionUserDefaultsKey = "current session" //kSessionUserDefaultsKey
        FIRApp.configure()//To connect to Firebase when app starts
        ref = FIRDatabase.database().reference()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let containerView = ContainerView()//View that shows tab views
        let player = PlayerViewController(tabBarHeight: 49)//49pts is common to all screen sizes, may not be in the future
        let pulleyController = PulleyTabBarController(contentViewController: containerView, drawerViewController: player)
        pulleyController.delegate = player
        pulleyController.topInset = 0
        pulleyController.drawerCornerRadius = 0
        pulleyController.drawerBackgroundVisualEffectView?.effect = UIBlurEffect(style: .regular)
        
        self.window?.rootViewController = pulleyController
        self.window?.backgroundColor = UIColor.green
        self.window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if (auth.canHandle(auth.redirectURL)){
            auth.handleAuthCallback(withTriggeredAuthURL: url, callback:{
                (error,session) in
                
                if (error != nil){
                    print("\n\nAUTH ERROR!! AppDel\n\n")
                    return
                }
                
                let userDefaults = UserDefaults.standard
                let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
                self.auth.session = session
                print("\nSESSION UPDATED")
                })
            return true
        }

 
        print("did not open")
        return false
    }
    
    
    //OPTIONAL SPTAudioStreamingDelegate methods
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError errorCode: SpErrorCode, withName name: String!) {
        print("\naudioStreaming - DidReceieveError - code: " + String(errorCode.rawValue) + " with name: " + name)
    }
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("\nLOGIN\n")
    }
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        print("\nLOGOUT\n")
    }
    func audioStreamingDidReconnect(_ audioStreaming: SPTAudioStreamingController!) {
        print("\nRECONNECTED\n")
    }
    func audioStreamingDidDisconnect(_ audioStreaming: SPTAudioStreamingController!) {
        print("\nDISCONNECTED\n")
    }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print("\nRECEIVED MESSAGE:\n" + message)
    }
    func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController!) {
        print("\nTEMPORARY CONNECTION ERROR\n")
    }
    
}

