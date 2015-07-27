//
//  ComicDownloader.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/19/15.
//
//

import Foundation
import SwiftTask

final class ComicDownloader: NSObject, NSURLSessionDataDelegate, ComicNetworkDataSource {
    
    // MARK: errors
    
    private enum Error: ErrorType {
        case CannotCreateDataTask
    }
    
    // MARK: ivars
    
    private lazy var URLSessionGuardSemaphore = dispatch_semaphore_create(1)
    private let sessionConfiguration: NSURLSessionConfiguration
//    private lazy var progressHandlers = Dictionary<NSURLSessionDataTask, Float -> Void>()
    
    private lazy var URLSession : NSURLSession = {
        let completionQueue = NSOperationQueue()
        completionQueue.qualityOfService = NSQualityOfService.UserInitiated
        completionQueue.maxConcurrentOperationCount = 1
        return NSURLSession(configuration: self.sessionConfiguration,
            delegate: self,
            delegateQueue: completionQueue)
    }()
    
    // MARK: init/deinit
    
    init(sessionConfiguration: NSURLSessionConfiguration) {
        self.sessionConfiguration = sessionConfiguration
    }
    
    // MARK: ComicDataSource
    
    func downloadComicOfKind(kind: ComicKind) -> Task<Float, Comic, ErrorType> {
        let URLComponents = NSURLComponents()
        URLComponents.scheme = "http"
        URLComponents.host = "xkcd.com"
        switch kind {
        case .LatestAvailable:
            URLComponents.path = "/info.0.json"
        case .ByNumber(number: let number):
            URLComponents.path = "/\(number)/info.0.json"
        }
        let URLRequest = NSURLRequest(URL:URLComponents.URL!)
        
        return Task<Float, Comic, ErrorType>(weakified: false, paused: true, initClosure: { (progress, fulfill, reject, configure) -> Void in
            dispatch_semaphore_wait(self.URLSessionGuardSemaphore, DISPATCH_TIME_FOREVER)
            guard let dataTask = self.URLSession.dataTaskWithRequest(URLRequest, completionHandler: { data, response, downloadError in
                guard let data = data else {
                    reject(downloadError!)
                    return
                }
                do {
                    let comic = try ComicParsing.comicFromJSONData(data)
                    fulfill(comic)
                } catch let error as NSError {
                    reject(error)
                } catch {
                    fatalError()
                }
            }) else {
                reject(Error.CannotCreateDataTask)
                return
            }
            dispatch_semaphore_signal(self.URLSessionGuardSemaphore)
            configure.resume = {
                dataTask.resume()
            }
            configure.cancel = {
                dataTask.cancel()
            }
//            self.progressHandlers[dataTask] = progress
        })
    }

    // MARK: NSURLSessionDataDelegate

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
//        if dataTask.countOfBytesExpectedToReceive == NSURLSessionTransferSizeUnknown {
//            return
//        }
//        let progressHandler = progressHandlers[dataTask]
//        progressHandler!(Float(dataTask.countOfBytesReceived) / Float(dataTask.countOfBytesExpectedToReceive))
    }
}
