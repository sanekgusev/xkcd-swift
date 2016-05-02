//
//  ComicNetworkingServiceImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/19/15.
//
//

import Foundation
import ReactiveCocoa

final class ComicNetworkingServiceImpl: NSObject, ComicNetworkingService {
    
    private let sessionConfiguration: NSURLSessionConfiguration
    private let completionQueueQualityOfService: NSQualityOfService
    
    private lazy var URLSession : NSURLSession = {
        let completionQueue = NSOperationQueue()
        completionQueue.qualityOfService = self.completionQueueQualityOfService
        completionQueue.name = "com.sanekgusev.xkcd.ComicNetworkingServiceImpl.completionQueue"
        return NSURLSession(configuration: self.sessionConfiguration,
            delegate: nil,
            delegateQueue: completionQueue)
    }()
    
    init(sessionConfiguration: NSURLSessionConfiguration,
        completionQueueQualityOfService: NSQualityOfService) {
        self.sessionConfiguration = sessionConfiguration
        self.completionQueueQualityOfService = completionQueueQualityOfService
    }
    
    func downloadComic(identifier: ComicIdentifier) -> SignalProducer<NSData, ComicNetworkingServiceError> {
        let URLComponents = NSURLComponents()
        URLComponents.scheme = "http"
        URLComponents.host = "xkcd.com"
        switch identifier {
        case .Latest:
            URLComponents.path = "/info.0.json"
        case .Number(comicNumber: let number):
            URLComponents.path = "/\(number)/info.0.json"
        }
        let URLRequest = NSURLRequest(URL:URLComponents.URL!)
        
        return SignalProducer { observer, disposable in
            let dataTask = self.URLSession.dataTaskWithRequest(URLRequest, completionHandler: { data, response, error in
                switch (data, response, error) {
                case (let data?, _, _):
                    observer.sendNext(data)
                    observer.sendCompleted()
                case (_, _?, let error):
                    if !disposable.disposed {
                        observer.sendFailed(.ServerError(underlyingError:error))
                    }
                case (_, _, let error):
                    if !disposable.disposed {
                        observer.sendFailed(.NetworkError(underlyingError:error))
                    }
                }
            })
            disposable += ActionDisposable { [weak dataTask] in
              dataTask?.cancel()
            }
            dataTask.resume()
        };
    }
}
