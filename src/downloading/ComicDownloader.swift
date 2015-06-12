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
    
    private lazy var URLSession: NSURLSession = {
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let concurrentQueue = NSOperationQueue()
        concurrentQueue.qualityOfService = NSQualityOfService.UserInitiated
        return NSURLSession(configuration: sessionConfiguration,
            delegate: nil,
            delegateQueue: concurrentQueue)
    }()
    
    // MARK: init/deinit
    
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
            dataTask = self.URLSession.dataTaskWithRequest(URLRequest) { data, response, downloadError in
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
            dataTask?.resume()
        }, cancelBlock: {
            dataTask?.cancel()
        })
    }
}
