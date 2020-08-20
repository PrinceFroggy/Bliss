//
//  DiscordWebhookWrapper.swift
//  Bliss
//
//  Created by Andrew Solesa on 5/7/20.
//  Copyright © 2020 KSG. All rights reserved.
//

import Foundation
import CoreData

class discordWebhook{
    var hook: URL
    
    init(hook: String){
        self.hook = (URL(string: hook) ?? URL(string: ""))!
    }
    
    func successPostHook(email: String, orderNumber: String, productName: String, productImage: String){
        //Convert content to just hold the string and append to the overall json
        let json : [String: Any] = ["username": "Bliss iOS", "avatar_url": "https://imgur.com/EoVmR4c.png", "embeds": [["title": "Success   :iphone:", "color": 100353, "fields": [["name": "Email", "value": "||\(email)||", "inline": true],["name": "Order Number","value":"||\(orderNumber)||","inline": true],["name": "Product Name","value": productName,"inline": true]],"thumbnail": ["url": productImage]]]]
        var request: URLRequest = URLRequest(url: hook)
        request.httpMethod = "POST"
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let str = String(decoding: jsonData!, as: UTF8.self)
        print(str)
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            print(response)
        }
        task.resume()
    }
}
