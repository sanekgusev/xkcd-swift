//
//  AppConfigurationImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

import Foundation

final class AppConfigurationImpl: AppConfiguration {
    
    var wireframe: MainWireframe {
        return MainWireframeImpl(listInteractor: comicListInteractor,
                                 listPresenterFactory: { ComicListPresenterImpl(interactor: self.comicListInteractor, router: $0) })
    }

}

private extension AppConfigurationImpl {
    
    var comicNetworkingService: ComicNetworkingService {
        return ComicNetworkingServiceImpl(sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                          completionQueueQualityOfService: .Utility)
    }
    
    var comicParsingService: ComicParsingService {
        return ComicParsingServiceImpl(qos: QOS_CLASS_UTILITY)
    }
    
    var comicRepository: ComicRepository {
        return ComicRepositoryImpl(networkingService: comicNetworkingService,
                                   parsingService: comicParsingService)
    }
    
    var comicListInteractor: ComicListInteractor {
        return ComicListInteractorImpl(comicRepository: comicRepository)
    }
    
    
}