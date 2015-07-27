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
    
    private let _semaphore = dispatch_semaphore_create(1);
    private var _backgroundURLSession : NSURLSession!
    
    // MARK: Init
    
    init(URLSessionConfiguration: NSURLSessionConfiguration) {
        let concurrentQueue = NSOperationQueue()
        concurrentQueue.qualityOfService = NSQualityOfService.UserInitiated
        super.init()
        _backgroundURLSession = NSURLSession(configuration: URLSessionConfiguration,
            delegate: self,
            delegateQueue: concurrentQueue)
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
                dispatch_semaphore_wait(self._semaphore, DISPATCH_TIME_FOREVER)
                let downloadTask = self._backgroundURLSession.downloadTaskWithRequest(URLRequest,
                    completionHandler: { (url, response, error) -> Void in
                        guard let url = url else {
                            reject(error!)
                            return
                        }
                        fulfill(url)
                })
                dispatch_semaphore_signal(self._semaphore)
                configure.resume = {
                    downloadTask?.resume()
                }
                configure.cancel = {
                    downloadTask?.cancel()
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