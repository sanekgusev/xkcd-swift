//
//  ComicListTableViewCell.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 10/05/16.
//
//

import UIKit
import ReactiveCocoa

final class ComicListTableViewCell: UITableViewCell {
    
    private let comicDisposable = SerialDisposable()
    private let loadingDisposable = SerialDisposable()
    private let lastLoadErrorDisposable = SerialDisposable()
    
    @IBOutlet
    private var numberLabel: UILabel!
    
    @IBOutlet
    private var titleLabel: UILabel!
    
    @IBOutlet
    private var refreshButton: UIButton!
    
    @IBOutlet
    private var refreshIndicator: UIActivityIndicatorView!

    var reactiveComic: ReactiveComicType? {
        didSet {
            if let identifier = reactiveComic?.comicIdentifier,
                case let .Number(number) = identifier {
                numberLabel.text = "\(number)."
            }
            else {
                numberLabel.text = nil
            }
            
            let scheduler = UIScheduler()
            
            comicDisposable.innerDisposable =
                reactiveComic?.comic.producer.observeOn(scheduler).startWithNext(handleComicChanged)
            loadingDisposable.innerDisposable =
                reactiveComic?.loading.producer.observeOn(scheduler).startWithNext(handleLoadingChanged)
            lastLoadErrorDisposable.innerDisposable =
                reactiveComic?.lastLoadError.producer.observeOn(scheduler).startWithNext(handleLastLoadErrorChanged)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        comicDisposable.innerDisposable = nil
        loadingDisposable.innerDisposable = nil
        lastLoadErrorDisposable.innerDisposable = nil
    }
    
    private func handleComicChanged(comic: Comic?) {
        titleLabel.text = comic?.title
    }
    
    private func handleLoadingChanged(loading: Bool) {
        loading ? refreshIndicator.startAnimating() : refreshIndicator.stopAnimating()
        refreshButton.hidden = !loading
    }
    
    private func handleLastLoadErrorChanged(lastLoadError: ComicRepositoryError?) {
        
    }
    
    @IBAction
    private func refreshButtonAction() {
        reactiveComic?.retrieveComic()
    }

}
