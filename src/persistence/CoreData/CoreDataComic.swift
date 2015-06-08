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
    @NSManaged var date: NSTimeInterval
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
            coreDataComic.date = comic.date?.timeIntervalSinceReferenceDate ?? 0
            coreDataComic.title = comic.title
            coreDataComic.link = comic.link
            coreDataComic.news = comic.news
            coreDataComic.imageURL = comic.imageURL?.absoluteString
        }
        return coreDataComic
    }
    
    func comic() -> Comic {
        let comic = Comic(number: number,
            date: NSDate(timeIntervalSinceReferenceDate: date),
            title: title,
            link: link,
            news: news,
            imageURL: imageURL == nil ? nil : NSURL(string: imageURL!),
            transcript: transcript,
            alt: alt)
        return comic
    }
}
