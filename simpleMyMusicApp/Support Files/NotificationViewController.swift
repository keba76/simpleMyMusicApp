//
//  NotificationViewController.swift
//  simpleMyMusicApp
//
//  Created by Ievgen Keba on 7/10/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//

import Foundation
import UserNotifications

class MyUserNotificationHelper : NSObject {
    
    func kickThingsOff() {
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([])
        
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        self.checkAuthorization()
    }
    
    private func checkAuthorization() {
        print("checking for notification permissions")
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings {
            settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.doAuthorization()
            case .denied:
                print("denied, giving up")
                break
            case .authorized:
                self.createNotification()
            }
        }
    }
    
    private func doAuthorization() {
        print("asking for authorization")
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { ok, err in
            if let err = err {
                print(err)
                return
            }
            if ok {
                self.createNotification()
            } else {
                print("user refused authorization")
            }
        }
    }
    
    fileprivate func createNotification() {
        print("creating notification")
        
        // need trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        // need content
        let content = UNMutableNotificationContent()
        content.title = "A moment of attention!"
        content.body = "You added a new sound to favorites."
        content.sound = UNNotificationSound.default()
        
        // new iOS 10 feature: attachments! AIFF, JPEG, or MPEG
        let url = Bundle.main.url(forResource: "note", withExtension: "png")!
        
        if let att = try? UNNotificationAttachment(identifier: "cup", url: url, options:nil) {
            delay(1) {
                content.attachments = [att]
                let req = UNNotificationRequest(identifier: "coffeeNotification", content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(req)
            }
        }
    }
}

extension MyUserNotificationHelper : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("received notification while active")
        completionHandler([.sound, .alert])
    }
    
}
