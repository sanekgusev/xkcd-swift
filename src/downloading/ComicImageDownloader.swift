//
//  ComicImageDownloader.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/17/15.
//
//

import Foundation

final class ComicImageDownloader: NSObject {
    
    // MARK: Ivars
    
    private static let backgroundSessionIdentifier = "com.sanekgusev.xkcd.comic-image-queue"
    
    private lazy var backgroundURLSession : NSURLSession = {
        let concurrentQueue = NSOperationQueue()
        concurrentQueue.qualityOfService = NSQualityOfService.UserInitiated
        return NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfiguration(backgroundSessionIdentifier),
            delegate: self,
            delegateQueue: concurrentQueue)
    }()
    
    // MARK: Private
    
    private func retrieveComicImageFrom(URL: NSURL, completion: (result: Result<NSURL>) -> ()) -> AsyncCancellable {
        let URLRequest = NSURLRequest(URL:URL)
        let downloadTask = backgroundURLSession.downloadTaskWithRequest(URLRequest,
            completionHandler: { URL, response, error in
                if let URL = URL {
                    completion(result: .Success(URL))
                }
                else {
                    completion(result: .Failure(error))
                }
        })
        return downloadTask
    }
    
}

extension ComicImageDownloader: NSURLSessionDownloadDelegate {

    // MARK: NSURLSessionDownloadDelegate
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
    }

}

extension ComicImageDownloader: ComicImageNetworkDataSource {
    func retrieveImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        completion: (result: Result<NSURL>) -> ()) -> ComicImageNetworkDataSourceAsyncResult {
            
        let URL: NSURL?
        switch imageKind {
        case .DefaultImage:
            URL = comic.imageURL
        }
        if let URL = URL {
            return .Success(retrieveComicImageFrom(URL,
                completion: { result in
                    completion(result: result)
            }))
        }
        else {
            return .Failure(nil) // FIXME
        }
    }
}