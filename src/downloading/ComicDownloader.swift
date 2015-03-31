//
//  ComicDownloader.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/19/15.
//
//

import Foundation

final class ComicDownloader: NSObject {
    
    // MARK: ivars
    
    private lazy var URLSession: NSURLSession = {
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let concurrentQueue = NSOperationQueue()
        concurrentQueue.qualityOfService = NSQualityOfService.UserInitiated
        return NSURLSession(configuration: sessionConfiguration,
            delegate: self,
            delegateQueue: concurrentQueue)
    }()
    
    // MARK: init/deinit
    
    // MARK: Private
    
    private func retrieveComicFrom(URL: NSURL, completion: (result: ComicResult) -> ()) -> AsyncCancellable {
        let URLRequest = NSURLRequest(URL:URL)
        let dataTask = URLSession.dataTaskWithRequest(URLRequest) { data, response, downloadError in
            if let data = data, response = response as? NSHTTPURLResponse {
                var parserError: NSError?
                if let comic = ComicParsing.comicFromJSONData(data, error: &parserError) {
                    completion(result: .Success(comic))
                }
                else {
                    completion(result: .Failure(parserError))
                }
            }
            else {
                completion(result: .Failure(downloadError))
            }
        }
        return dataTask
    }
}

extension ComicDownloader: NSURLSessionDataDelegate {

    // MARK: NSURLSessionDataDelegate
    
}

extension ComicDownloader: ComicNetworkDataSource {

    // MARK: ComicDataSource
    
    func retrieveComicOfKind(kind: ComicNetworkDataSourceComicKind, completion: (result: ComicResult) -> ()) -> AsyncCancellable {
        let URLComponents = NSURLComponents()
        URLComponents.scheme = "http"
        URLComponents.host = "xkcd.com"
        switch kind {
        case .MostRecent:
            URLComponents.path = "/info.0.json"
        case .ByNumber(number: let number):
            URLComponents.path = "/\(number)/info.0.json"
        }
        return retrieveComicFrom(URLComponents.URL!, completion: completion)
    }
}
