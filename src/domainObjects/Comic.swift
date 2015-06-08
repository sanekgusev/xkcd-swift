//
//  Comic.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/17/15.
//
//

import Foundation

final class Comic {
    let number: Int;
    let date: NSDate?;
    let title: String?;
    let link: String?;
    let news: String?;
    let imageURL: NSURL?;
    let transcript: String?;
    let alt: String?;
    
    init(number: Int,
        date: NSDate?,
        title: String?,
        link: String?,
        news: String?,
        imageURL: NSURL?,
        transcript: String?,
        alt: String?){
            
            self.number = number;
            self.date = date;
            self.title = title;
            self.link = link;
            self.news = news;
            self.imageURL = imageURL;
            self.transcript = transcript;
            self.alt = alt;
    }
}

extension Comic : UniquelyIdentifiable {
    var identifier: Int {
        return number
    }
}

extension Comic : Hashable, Comparable {
    var hashValue: Int {
        return number;
    }
}

func ==(lhs: Comic, rhs: Comic) -> Bool {
    return lhs.number == rhs.number
}

func <(lhs: Comic, rhs: Comic) -> Bool {
    return lhs.number < rhs.number
}