//
//  ComicDownloader.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/19/15.
//
//

import Foundation

final class ComicDownloader: NSObject, NSURLSessionDataDelegate, ComicNetworkDataSource {
    
    // MARK: ivars
    
    private let _semaphore = dispatch_semaphore_create(1);
    private let _URLSession : NSURLSession
    
    // MARK: init/deinit
    
    init(sessionConfiguration: NSURLSessionConfiguration) {
        let concurrentQueue = NSOperationQueue()
        concurrentQueue.qualityOfService = NSQualityOfService.UserInitiated
        _URLSession = NSURLSession(configuration: sessionConfiguration,
            delegate: nil,
            delegateQueue: concurrentQueue)
    }
    
    // MARK: ComicDataSource
    
    func downloadComicOfKind(kind: ComicKind) -> CancellableAsynchronousTask<Result<Comic>> {
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
        var dataTask: NSURLSessionDataTask?
        let asynchronousTask = CancellableAsynchronousTask<Result<Comic>>(spawnBlock: { completionBlock in
            dispatch_semaphore_wait(self._semaphore, DISPATCH_TIME_FOREVER)
            dataTask = self._URLSession.dataTaskWithRequest(URLRequest) { data, response, downloadError in
                if let data = data, response = response as? NSHTTPURLResponse {
                    var parserError: NSError?
                    if let comic = ComicParsing.comicFromJSONData(data, error: &parserError) {
                        completionBlock(result: .Success(comic))
                    }
                    else {
                        completionBlock(result: .Failure(parserError))
                    }
                }
                else {
                    completionBlock(result: .Failure(downloadError))
                }
            }
            dispatch_semaphore_signal(self._semaphore)
            dataTask?.resume()
        }, cancelBlock: {
            dataTask?.cancel()
        })
        return asynchronousTask
    }
}
