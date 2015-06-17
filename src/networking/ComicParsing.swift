//
//  ComicParser.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/22/15.
//
//

import Foundation

final class ComicParsing {
    
    static let ErrorDomain = "ComicParsing"
    static let ComicNumberMissingCode = 0
    
    private static let calendar : NSCalendar? = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    class func comicFromJSONData(JSONData: NSData, error: NSErrorPointer) -> Comic? {
        if let
            comicDict = NSJSONSerialization.JSONObjectWithData(JSONData, options: nil, error: error) as? [String: AnyObject] {
                if let num = comicDict["num"] as? Int {
                    let imageURL: NSURL?
                    if let img = comicDict["img"] as? String {
                        imageURL = NSURL(string: img)
                    }
                    else {
                        imageURL = nil
                    }
                    let date: NSDate?
                    if let day = comicDict["day"] as? Int,
                        month = comicDict["month"] as? Int,
                        year = comicDict["year"] as? Int {
                            date = dateFrom(day, month: month, year: year)
                    }
                    else {
                        date = nil
                    }
                    return Comic(number: num,
                        date: date, 
                        title: comicDict["title"] as? String,
                        link: comicDict["link"] as? String,
                        news: comicDict["news"] as? String,
                        imageURL: imageURL,
                        transcript: comicDict["transcript"] as? String,
                        alt: comicDict["alt"] as? String)
                }
                else {
                    if error != nil {
                        error.memory = NSError(domain: ErrorDomain, code: ComicNumberMissingCode, userInfo: nil)
                    }
                }
        }
        return nil
    }
    
    private class func dateFrom(day: Int, month: Int, year: Int) -> NSDate? {
        let dateComponents = NSDateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        
        return calendar?.dateFromComponents(dateComponents)
    }
}