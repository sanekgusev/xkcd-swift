//
//  ComicImageDownloader.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/17/15.
//
//

import Foundation
import SwiftTask

final class ComicImageDownloader: NSObject, NSURLSessionDownloadDelegate, ComicImageNetworkDataSource {
    
    // MARK: Errors
    
    private enum Error: ErrorType {
        case MissingImageURL
    }
    
    // MARK: Ivars
    
    private lazy var semaphore = dispatch_semaphore_create(1);
    private let URLSessionConfiguration: NSURLSessionConfiguration
    private let completionQueueQualityOfService: NSQualityOfService
    private lazy var URLSession: NSURLSession = {
        let completionQueue = NSOperationQueue()
        completionQueue.qualityOfService = self.completionQueueQualityOfService
        completionQueue.maxConcurrentOperationCount = 1
        completionQueue.name = "com.sanekgusev.xkcd.ComicImageDownloader.completionQueue"
        return NSURLSession(configuration: self.URLSessionConfiguration,
            delegate: self,
            delegateQueue: completionQueue)
    }()
    
    // MARK: Init
    
    init(URLSessionConfiguration: NSURLSessionConfiguration,
        completionQueueQualityOfService: NSQualityOfService) {
            self.URLSessionConfiguration = URLSessionConfiguration
            self.completionQueueQualityOfService = completionQueueQualityOfService
    }
    
    // MARK: ComicImageDataSource
    
    func downloadImageForComic(comic: Comic,
        imageKind: ComicImageKind) throws -> Task<Float, NSURL, ErrorType> {
        var URLFromComic: NSURL?
        switch imageKind {
            case .DefaultImage:
                URLFromComic = comic.imageURL
        }
        guard let URL = URLFromComic else {
            throw Error.MissingImageURL
        }
        let URLRequest = NSURLRequest(URL:URL)
        
        return Task(weakified: false, paused: true,
            initClosure: { (progress, fulfill, reject, configure) -> Void in
                dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER)
                let downloadTask = self.URLSession.downloadTaskWithRequest(URLRequest,
                    completionHandler: { (url: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
                        guard let url = url else {
                            reject(error!)
                            return
                        }
                        fulfill(url)
                })
                dispatch_semaphore_signal(self.semaphore)
                configure.resume = {
                    downloadTask.resume()
                }
                configure.cancel = {
                    downloadTask.cancel()
                }
        })
    }
    
    // MARK: NSURLSessionDownloadDelegate
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        // TODO
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        // TODO
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        // TODO
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // TODO
    }
    
}