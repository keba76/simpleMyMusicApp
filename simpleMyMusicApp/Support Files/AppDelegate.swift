//
//  AppDelegate.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import AVFoundation

func delay(_ delay: Double, closure: @escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}
var secondFromStart: Int = 0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var restrictRotation = UIInterfaceOrientationMask.portrait
    let notifHelper = MyUserNotificationHelper()
    
    var timer : Timer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let center = UNUserNotificationCenter.current()
        center.delegate = self.notifHelper
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask { return self.restrictRotation }
    
    func applicationWillResignActive(_ application: UIApplication) {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval:1, target: self, selector: #selector(fired), userInfo: nil, repeats: true)
    }
    
    func fired(_ timer:Timer) {
        secondFromStart += 1
        print(secondFromStart)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {}
    
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.timer?.invalidate()
        secondFromStart = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {}
    
    
}

