//
//  Comic.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/17/15.
//
//

import Foundation

typealias ComicNumber = Int

struct Comic {
    let number: ComicNumber
    let date: NSDateComponents?
    let title: String?
    let link: String?
    let news: String?
    let imageURL: NSURL?
    let transcript: String?
    let alt: String?
}

extension Comic : UniquelyIdentifiable {
    var identifier: ComicNumber {
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