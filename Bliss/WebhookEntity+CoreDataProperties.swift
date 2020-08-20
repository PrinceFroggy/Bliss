//
//  WebhookEntity+CoreDataProperties.swift
//  
//
//  Created by Andrew Solesa on 5/10/20.
//
//

import Foundation
import CoreData


extension WebhookEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WebhookEntity> {
        return NSFetchRequest<WebhookEntity>(entityName: "WebhookEntity")
    }

    @NSManaged public var webhook: String?

}
