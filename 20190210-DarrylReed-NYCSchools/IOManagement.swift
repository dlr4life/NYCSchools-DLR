//
//  IOManagement.swift
//  20190210-DarrylReed-NYCSchools
//
//  Created by DLR on 2/9/19.
//  Copyright © 2019 DLR. All rights reserved.
//

import UIKit

// Custom struct used to store NYC school information (for ACT scores)
struct SchoolSATDataStruct {
    var dbn: String!
    var name: String!
    var numOfTestTakers: String!
    var critReadingScore: String!
    var mathScore: String!
    var writingScore: String!
    
    init() {
        self.dbn = nil
        self.name = nil
        self.numOfTestTakers = nil
        self.critReadingScore = nil
        self.mathScore = nil
        self.writingScore = nil
    }
    
    init(dbn: String, name: String, numOfTestTakers: String, critReadingScore: String, mathScore: String, writingScore: String) {
        self.dbn = dbn
        self.name = name
        self.numOfTestTakers = numOfTestTakers
        self.critReadingScore = critReadingScore
        self.mathScore = mathScore
        self.writingScore = writingScore
        printInfo()
    }
    
    // Print function included for debugging purposes
    func printInfo() {
        print("dbn: \(self.dbn ?? "")")
        print("name: \(self.name ?? "")")
        print("numOfTestTakers: \(self.numOfTestTakers ?? "")")
        print("critReadingScore: \(self.critReadingScore ?? "")")
        print("mathScore: \(self.mathScore ?? "")")
        print("writingScore: \(self.writingScore ?? "") \n")
    }
}

// Custom struct used to store NYC school information (for Maps & Additional Info.)
struct SchoolDOEDataStruct {
    var dbn: String!
    var schoolName: String!
    var primaryAddressLine1: String!
    var latitude: String!
    var location: String!
    var longitude: String!
    var schoolEmail: String!
    var phoneNumber: String!
    var faxNumber: String!
    var city: String!
    var grades2018: String!
    var stateCode: String!
    var website: String!
    var zip: String!
    
    init() {
        self.dbn = nil
        self.schoolName = nil
        self.primaryAddressLine1 = nil
        self.latitude = nil
        self.longitude = nil
        self.location = nil
        self.city = nil
        self.stateCode = nil
        self.zip = nil
        self.schoolEmail = nil
        self.grades2018 = nil
        self.website = nil
        self.phoneNumber = nil
        self.faxNumber = nil
    }
    
    init(dbn: String, schoolName: String, primaryAddressLine1: String, latitude: String, longitude: String, location: String, city: String, stateCode: String, zip: String, schoolEmail: String, grades2018: String, website: String, phoneNumber: String, faxNumber: String){
        self.dbn = dbn
        self.schoolName = schoolName
        self.primaryAddressLine1 = primaryAddressLine1
        self.latitude = latitude
        self.longitude = longitude
        self.location = location
        self.city = city
        self.stateCode = stateCode
        self.zip = zip
        self.schoolEmail = schoolEmail
        self.grades2018 = grades2018
        self.website = website
        self.phoneNumber = phoneNumber
        self.faxNumber = faxNumber
    }
}
