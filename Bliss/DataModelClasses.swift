//
//  DataModelClasses.swift
//  Bliss
//
//  Created by Andrew Solesa on 2020-02-09.
//  Copyright © 2020 KSG. All rights reserved.
//

import Foundation

class YSPackage
{
    var firstName: String
    var lastName: String
    var address: String
    var zipCode: String
    var city: String
    var state: String
    var phoneNumber: String
    var email: String
    var cardNumber: String
    var nameOnCard: String
    var monthYear: String
    var cvv: String
    var shoeName: String
    var shoeColor: String
    var shoeSize: String
    
    init(withFirstName firstName: String, lastName: String, address: String, zipCode: String, city: String, state: String, phoneNumber: String, email: String, cardNumber: String, nameOnCard: String, monthYear: String, cvv: String, shoeName: String, shoeColor: String, shoeSize: String)
    {
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.zipCode = zipCode
        self.city = city
        self.state = state
        self.phoneNumber = phoneNumber
        self.email = email
        self.cardNumber = cardNumber
        self.nameOnCard = nameOnCard
        self.monthYear = monthYear
        self.cvv = cvv
        self.shoeName = shoeName
        self.shoeColor = shoeColor
        self.shoeSize = shoeSize
    }
}

struct abck: Codable
{
    let key, val: String
}
