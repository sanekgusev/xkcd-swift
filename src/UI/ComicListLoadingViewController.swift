//
//  ComicListLoadingViewController.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 09/05/16.
//
//

import UIKit
import ReactiveCocoa

final class ComicListLoadingViewController: UIViewController {

    private let presenter: ComicListLoadingPresenter
    
    private var refreshingDisposable: ScopedDisposable?
    
    @IBOutlet
    private var activityIndicator: UIActivityIndicatorView!
    
    required init(presenter: ComicListLoadingPresenter) {
        self.presenter = presenter
        super.init(nibName: NSStringFromClass(self.dynamicType), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshingDisposable = ScopedDisposable(presenter.refreshing.producer.startWithNext({ [weak self] refreshing in
            refreshing ?
                self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }))
    }
}
