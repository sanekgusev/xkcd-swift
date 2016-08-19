//
//  MainWireframeImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

import UIKit
import ReactiveCocoa

final class MainWireframeImpl: NSObject, MainWireframe {
    
    private let listInteractor: ComicListInteractor
    private let listPresenterFactory: (listRouter: ComicListRouter) -> ComicListPresenter
    private lazy var listPresenter: ComicListPresenter = self.listPresenterFactory(listRouter: self)
    
    private weak var window: UIWindow?
    private lazy var navigationController = UINavigationController()
    
    init(listInteractor: ComicListInteractor, listPresenterFactory: (listRouter: ComicListRouter) -> ComicListPresenter) {
        self.listInteractor = listInteractor
        self.listPresenterFactory = listPresenterFactory
    }
    
    func setupInitialUIWithWindow(window: UIWindow) {
        self.window = window
        setupAppearance()
        window.rootViewController = navigationController
        listPresenter.comicCount.producer.observeOn(UIScheduler()).startWithNext { comicCount in
            comicCount == nil ? self.handleNoComicsLoaded() : self.handleComicsLoaded()
        }
        listPresenter.refreshComicCount()
    }

}

extension MainWireframeImpl: ComicListRouter {
    private func handleComicsLoaded() {
        navigationController.rootViewController = ComicListViewController(presenter: listPresenter)
    }
    
    private func handleNoComicsLoaded() {
        navigationController.rootViewController = ComicListLoadingViewController(presenter: listPresenter)
    }
    
    func handleComicSelected(comic: ReactiveComic) {
        // TODO: create detail VC and push
    }
}

private extension MainWireframeImpl {
    func setupAppearance() {
        // TODO
    }
}
