//
//  ComicKind.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/2/15.
//
//

enum ComicIdentifier {
    case Number(Comic.Number)
    case Latest
}

extension ComicIdentifier : IntegerLiteralConvertible {
    typealias IntegerLiteralType = Comic.Number
    
    init(integerLiteral value: IntegerLiteralType) {
        self = .Number(value)
    }
}