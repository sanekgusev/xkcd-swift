//
//  ComicKind.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/2/15.
//
//

enum ComicIdentifier {
    case Number(comicNumber: UInt)
    case Latest
}

extension ComicIdentifier : IntegerLiteralConvertible {
    typealias IntegerLiteralType = UInt
    
    init(integerLiteral value: ComicIdentifier.IntegerLiteralType) {
        self = .Number(comicNumber: value)
    }
}