//
//  AppDelegate.swift
//  Sieve
//
//  Created by Colin Biafore on 2/5/16.
//  Copyright © 2016 Colin Biafore. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var session: SPTSession!
    var player: SPTAudioStreamingController!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        SPTAuth.defaultInstance().clientID = "ed3000e6605a4d21aefc2d4997b370e0"
        SPTAuth.defaultInstance().redirectURL = NSURL(string: "sieve://returnafterlogin")!
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope]
        
        // Construct a login URL and open it
        let loginURL: NSURL = SPTAuth.defaultInstance().loginURL
        
        // Opening URL in Safari close to application launch may trigger an iOS bug,
        // so we will wait a bit before doing so.
        application.performSelector("openURL:", withObject: loginURL, afterDelay:  0.1)
        
        return true

    }
    
    // Handle auth callback
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        // Ask SPTAuth if the URL given is a Spotify authentication callback
        if SPTAuth.defaultInstance().canHandleURL(url) {
            
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: {(error: NSError?, session: SPTSession!) -> Void in
                if error != nil {
                    NSLog("*** Auth error: %@",error!)
                    return
                }
                
                // Call the playUsingSession method to play a track
            })
            
            return true
        }
        
        return false
    }
    

    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

