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
    
    init(qos: dispatch_qos_class_t) {
        scheduler = QueueScheduler(qos: qos, name: "com.sanekgusev.xkcd.ComicParsingService.queue")
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
                guard let day = comicDict["day"] as? UInt8,
                    month = comicDict["month"] as? UInt8,
                    year = comicDict["year"] as? UInt16 else {
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
            }
            catch (let e) {
                observer.sendFailed(.MalformedEncodingError(underlyingError:e))
                return
            }
        }.startOn(scheduler)
    }
}