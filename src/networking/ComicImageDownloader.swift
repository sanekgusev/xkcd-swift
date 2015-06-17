//
//  ComicImageDownloader.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/17/15.
//
//

import Foundation

final class ComicImageDownloader: NSObject, NSURLSessionDownloadDelegate, ComicImageNetworkDataSource {
    
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
        imageKind: ComicImageKind) -> CancellableAsynchronousTask<Result<NSURL>>? {
        let URL: NSURL?
        switch imageKind {
            case .DefaultImage:
                URL = comic.imageURL
        }
        if let URL = URL {
            let URLRequest = NSURLRequest(URL:URL)
            var downloadTask : NSURLSessionDownloadTask?
            let asynchronousTask = CancellableAsynchronousTask<Result<NSURL>>(spawnBlock: { (completionBlock) -> () in
                dispatch_semaphore_wait(self._semaphore, DISPATCH_TIME_FOREVER)
                downloadTask = self._backgroundURLSession.downloadTaskWithRequest(URLRequest,
                    completionHandler: { URL, response, error in
                        if let URL = URL {
                            completionBlock(result: .Success(URL))
                        }
                        else {
                            completionBlock(result: .Failure(error))
                        }
                })
                dispatch_semaphore_signal(self._semaphore)
                downloadTask?.resume()
            }, cancelBlock: { () -> () in
                // TODO: add support for resume data
                downloadTask?.cancel()
            })
            return asynchronousTask
        }
        return nil
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