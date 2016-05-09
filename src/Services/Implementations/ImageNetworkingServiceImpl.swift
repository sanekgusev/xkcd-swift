//
//  ComicImageNetworkingServiceImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/17/15.
//
//

import Foundation
import ReactiveCocoa

final class ImageNetworkingServiceImpl: NSObject, ImageNetworkingService {
    
    private let URLSessionConfiguration: NSURLSessionConfiguration
    private let completionQueueQualityOfService: NSQualityOfService
    private lazy var URLSession: NSURLSession = {
        let completionQueue = NSOperationQueue()
        completionQueue.qualityOfService = self.completionQueueQualityOfService
        completionQueue.name = "com.sanekgusev.xkcd.ComicImageNetworkingServiceImpl.completionQueue"
        return NSURLSession(configuration: self.URLSessionConfiguration,
            delegate: nil,
            delegateQueue: completionQueue)
    }()
    
    init(URLSessionConfiguration: NSURLSessionConfiguration,
        completionQueueQualityOfService: NSQualityOfService) {
            self.URLSessionConfiguration = URLSessionConfiguration
            self.completionQueueQualityOfService = completionQueueQualityOfService
    }
    
    func downloadImageForURL(imageURL: NSURL) -> SignalProducer<FileURL, ImageNetworkingServiceError> {
            let URLRequest = NSURLRequest(URL:imageURL)
            
            return SignalProducer { observer, disposable in
                let downloadTask = self.URLSession.downloadTaskWithRequest(URLRequest,
                    completionHandler: { url, response, error in
                        guard !disposable.disposed else {
                            return
                        }
                        switch (url, response, error) {
                        case (let url?, _, _):
                            observer.sendNext(url)
                            observer.sendCompleted()
                        case (_, _?, let error):
                            observer.sendFailed(.ServerError(underlyingError:error))
                        case (_, _, let error):
                            observer.sendFailed(.NetworkError(underlyingError:error))
                        }
                })
                disposable += ActionDisposable { [weak downloadTask] in
                    downloadTask?.cancel()
                }
                downloadTask.resume()
            }
    }
}