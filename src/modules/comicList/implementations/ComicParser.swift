//
//  ComicParser.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/22/15.
//
//

import Foundation
import ReactiveCocoa

struct ComicParser : ComicParsingService {
    
    func comicFromData(data: NSData) -> SignalProducer<Comic, ComicParsingServiceError> {
        do {
            let JSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            guard let comicDict = JSONObject as? [String: AnyObject] else {
                return SignalProducer(error: .MalformedEncodingError(underlyingError:nil))
            }
            guard let num = comicDict["num"] as? Comic.Number else {
                return SignalProducer(error: .MalformedPayloadError(underlyingError:nil))
            }
            guard let imageURL = (comicDict["img"] as? String).flatMap({NSURL(string: $0)}) else {
                return SignalProducer(error: .MalformedPayloadError(underlyingError:nil))
            }
            guard let day = comicDict["day"] as? UInt8,
                month = comicDict["month"] as? UInt8,
                year = comicDict["year"] as? UInt16 else {
                    return SignalProducer(error: .MalformedPayloadError(underlyingError:nil))
            }
            guard let title = comicDict["title"] as? String else {
                return SignalProducer(error: .MalformedPayloadError(underlyingError:nil))
            }
            guard let alt = comicDict["alt"] as? String else {
                return SignalProducer(error: .MalformedPayloadError(underlyingError:nil))
            }
            
            let comic = Comic(number: num,
                day: day,
                month: month,
                year: year,
                title: title,
                link: comicDict["link"] as? String,
                news: comicDict["news"] as? String,
                imageURL: imageURL,
                transcript: comicDict["transcript"] as? String,
                alt: alt)
            return SignalProducer(value: comic)
        }
        catch (let e) {
            return SignalProducer(error: .MalformedEncodingError(underlyingError:e))
        }
    }
}