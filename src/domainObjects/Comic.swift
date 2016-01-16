//
//  Comic.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/17/15.
//
//

import Foundation

struct Comic {
    
    typealias Number = UInt
    
    var number: Number
    var day: UInt8
    var month: UInt8
    var year: UInt16
    var title: String
    var link: String?
    var news: String?
    var imageURL: NSURL
    var transcript: String?
    var alt: String
    
    var dateComponents : NSDateComponents {
        let components = NSDateComponents()
        components.day = Int(day)
        components.month = Int(month)
        components.year = Int(year)
        return components
    }
}

extension Comic : Hashable, Equatable {
    var hashValue: Int {
        return Int(number);
    }
}

func ==(lhs: Comic, rhs: Comic) -> Bool {
    return lhs.number == rhs.number &&
    lhs.day == rhs.day &&
    lhs.month == rhs.month &&
    lhs.year == rhs.year &&
    lhs.title == rhs.title &&
    lhs.link == rhs.link &&
    lhs.news == rhs.news &&
    lhs.imageURL == rhs.imageURL &&
    lhs.transcript == rhs.transcript &&
    lhs.alt == rhs.alt
}