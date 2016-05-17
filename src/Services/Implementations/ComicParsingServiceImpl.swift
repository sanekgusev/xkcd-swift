//
//  ComicParsingServiceImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/22/15.
//
//

import Foundation
import ReactiveCocoa

final class ComicParsingServiceImpl: ComicParsingService {
    
    private let scheduler: QueueScheduler
    
    init(qos: dispatch_qos_class_t = QOS_CLASS_DEFAULT) {
        scheduler = QueueScheduler(qos: qos, name: "com.sanekgusev.xkcd.ComicParsingServiceImpl.queue")
    }
    
    func comicFromData(data: NSData) -> SignalProducer<Comic, ComicParsingServiceError> {
        return SignalProducer { observer, disposable in
            do {
                let JSONObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                guard let comicDict = JSONObject as? [String: AnyObject] else {
                    observer.sendFailed(.MalformedEncodingError(underlyingError:nil))
                    return
                }
                guard let num = comicDict["num"] as? Comic.Number else {
                    observer.sendFailed(.MalformedPayloadError(underlyingError:nil))
                    return
                }
                guard let imageURL = (comicDict["img"] as? String).flatMap({NSURL(string: $0)}) else {
                    observer.sendFailed(.MalformedPayloadError(underlyingError:nil))
                    return
                }
                guard let dayString = comicDict["day"] as? String,
                    monthString = comicDict["month"] as? String,
                    yearString = comicDict["year"] as? String,
                    day = UInt8(dayString),
                    month = UInt8(monthString),
                    year = UInt16(yearString) else {
                        observer.sendFailed(.MalformedPayloadError(underlyingError:nil))
                        return
                }
                guard let title = comicDict["title"] as? String else {
                    observer.sendFailed(.MalformedPayloadError(underlyingError:nil))
                    return
                }
                guard let alt = comicDict["alt"] as? String else {
                    observer.sendFailed(.MalformedPayloadError(underlyingError:nil))
                    return
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
                observer.sendNext(comic)
                observer.sendCompleted()
            }
            catch (let e) {
                observer.sendFailed(.MalformedEncodingError(underlyingError:e))
                return
            }
        }.startOn(scheduler)
    }
}