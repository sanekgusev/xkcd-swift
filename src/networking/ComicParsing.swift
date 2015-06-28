//
//  ComicParser.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/22/15.
//
//

import Foundation

final class ComicParsing {
    
    private static let calendar : NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    enum Error : ErrorType {
        case NotADictionary
        case ComicNumberMissing
    }
    
    class func comicFromJSONData(JSONData: NSData) throws -> Comic {
        guard let comicDict = try NSJSONSerialization.JSONObjectWithData(JSONData, options: []) as? [String: AnyObject] else {
            throw Error.NotADictionary
        }
        guard let num = comicDict["num"] as? Int else {
            throw Error.ComicNumberMissing
        }
        
        let imageURL = (comicDict["img"] as? String).flatMap({NSURL(string: $0)})

        let nullableDate: NSDateComponents?
        if let day = comicDict["day"] as? Int,
            month = comicDict["month"] as? Int,
            year = comicDict["year"] as? Int {
                
            let date = NSDateComponents()
            date.day = day
            date.month = month
            date.year = year
            nullableDate = date
        }
        else {
            nullableDate = nil
        }
        return Comic(number: num,
            date: nullableDate,
            title: comicDict["title"] as? String,
            link: comicDict["link"] as? String,
            news: comicDict["news"] as? String,
            imageURL: imageURL,
            transcript: comicDict["transcript"] as? String,
            alt: comicDict["alt"] as? String)
    }
    
    private class func dateFrom(day: Int, month: Int, year: Int) -> NSDate? {
        let dateComponents = NSDateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        
        return calendar.dateFromComponents(dateComponents)
    }
}