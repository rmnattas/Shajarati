//
//  AppDelegate.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 23/7/2015.
//  Copyright (c) 2015 Abdulrahman Alattas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let version : AnyObject! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")
    let build : AnyObject! = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion")
    let directoryurl : String = "http://xxxx.xxx/"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
            
        let defaults = NSUserDefaults.standardUserDefaults()
        //defaults.setObject(nil, forKey: "shajaratiDB")
        if((defaults.stringForKey("hashnum")) == nil){
            defaults.setObject("\((UIDevice.currentDevice().identifierForVendor!.hash / 2))", forKey: "hashnum")
        }
        /*
         print(UIDevice.currentDevice().identifierForVendor!)
         print(UIDevice.currentDevice().identifierForVendor!.hash)
         print((UIDevice.currentDevice().identifierForVendor!.hash / 2))
         */
        print(defaults.stringForKey("hashnum")!)
        
        
        if((defaults.stringForKey("shajaratiDB")) != nil){
            print(defaults.stringForKey("shajaratiDB")!)
        }
        
        
        if((defaults.objectForKey("FavIDs")) == nil){
            let FavIDs : [String] = []
            defaults.setObject(FavIDs, forKey: "FavIDs")
            let FavNames : [String] = []
            defaults.setObject(FavNames, forKey: "FavNames")
            let FavImages : [String] = []
            defaults.setObject(FavImages, forKey: "FavImages")
            let FavDB : [String] = []
            defaults.setObject(FavDB, forKey: "FavDB")
        }
            
        return true
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

extension UIColor {
    convenience init(hex: String) {
        let scanner = NSScanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt32 = 0
        
        scanner.scanHexInt(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
