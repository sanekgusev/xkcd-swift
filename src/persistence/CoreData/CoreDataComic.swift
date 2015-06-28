//
//  Comic.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/9/15.
//
//

import Foundation
import CoreData

final class CoreDataComic: NSManagedObject {

    @NSManaged var number: Int
    @NSManaged var day: Int
    @NSManaged var month: Int
    @NSManaged var year: Int
    @NSManaged var title: String?
    @NSManaged var link: String?
    @NSManaged var news: String?
    @NSManaged var imageURL: String?
    @NSManaged var transcript: String?
    @NSManaged var alt: String?

}

extension CoreDataComic {
    
    class var entityName: String {
        return "Comic"
    }
    
    class func comicFromComic(comic: Comic,
        insertIntoManagedObjectContext context: NSManagedObjectContext) -> CoreDataComic? {
        let coreDataComic = NSEntityDescription.insertNewObjectForEntityForName(entityName,
            inManagedObjectContext: context) as? CoreDataComic
        if let coreDataComic = coreDataComic {
            coreDataComic.number = comic.number
            coreDataComic.day = comic.date?.day ?? 0
            coreDataComic.month = comic.date?.month ?? 0
            coreDataComic.year = comic.date?.year ?? 0
            coreDataComic.title = comic.title
            coreDataComic.link = comic.link
            coreDataComic.news = comic.news
            coreDataComic.imageURL = comic.imageURL?.absoluteString
        }
        return coreDataComic
    }
    
    func comic() -> Comic {
        let nullableDateComponents : NSDateComponents?
        if day > 0 && month > 0 && year > 0 {
            let dateComponents = NSDateComponents()
            dateComponents.day = day
            dateComponents.month = month
            dateComponents.year = year
            nullableDateComponents = dateComponents
        }
        else {
            nullableDateComponents = nil
        }
        
        let comic = Comic(number: number,
            date: nullableDateComponents,
            title: title,
            link: link,
            news: news,
            imageURL: imageURL.flatMap({NSURL(string: $0)}),
            transcript: transcript,
            alt: alt)
        return comic
    }
}
