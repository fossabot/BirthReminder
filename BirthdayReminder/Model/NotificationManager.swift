//
//  NotificationManager.swift
//  BirthdayReminder
//
//  Created by Captain雪ノ下八幡 on 09/12/2017.
//  Copyright © 2017 CaptainYukinoshitaHachiman. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import CoreData
import MobileCoreServices

class NotificationManager {
    
    static private var context: NSManagedObjectContext {
        let app = UIApplication.shared
        let delegate = app.delegate as! AppDelegate
        return delegate.context
    }
    
    static public func reloadNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        // remove all the notifications before
        notificationCenter.removeAllPendingNotificationRequests()
        // add notifications
        let fetchRequest = PeopleToSave.sortedFetchRequest
        let people = try? context.fetch(fetchRequest)
        people?.forEach() { person in
            let birth = person.birth.toDate()!
            var components = DateComponents()
            components.month = birth.month
            components.day = birth.day
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let content = UNMutableNotificationContent()
            content.title = String.localizedStringWithFormat(
                NSLocalizedString("It's %@'s birthday", comment: "It's %@'s birthday"),
                person.name)
            content.body = String.localizedStringWithFormat(
                NSLocalizedString("%@ is %@'s birthday, let's celebrate!", comment: "%@ is %@'s birthday, let's celebrate!"),
                person.birth.toLocalizedDate()!,person.name)
            content.sound = .default()
            if let pngData = person.picData,
                let image = UIImage(data: pngData),
                let jpegData = UIImageJPEGRepresentation(image, 1.0) {
                let fileManager = FileManager()
                let tempUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                let picUrl = tempUrl.appendingPathComponent("temp\(person.name)\(person.birth)" + ".jpg")
                if let _ = try? jpegData.write(to: picUrl),
                    let attachment = try? UNNotificationAttachment(identifier: pngData.base64EncodedString(), url: picUrl, options: [UNNotificationAttachmentOptionsTypeHintKey:kUTTypeJPEG]) {
                    content.attachments.append(attachment)
                }
            }
            let notificationRequest = UNNotificationRequest(identifier: "\(person.name)\(person.birth)\(person.picData?.base64EncodedString() ?? "")", content: content, trigger: trigger)
            notificationCenter.add(notificationRequest, withCompletionHandler: nil)
        }
    }
}