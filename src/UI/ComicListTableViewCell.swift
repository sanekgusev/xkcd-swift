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

    var reactiveComic: ReactiveComicWrapper? {
        didSet {
            if let identifier = reactiveComic?.comicIdentifier,
                case let .Number(number) = identifier {
                numberLabel.text = "\(number)."
            }
            else {
                numberLabel.text = nil
            }
            
            comicDisposable.innerDisposable =
                reactiveComic?.comic.producer.startWithNext(handleComicChanged)
            loadingDisposable.innerDisposable =
                reactiveComic?.loading.producer.startWithNext(handleLoadingChanged)
            lastLoadErrorDisposable.innerDisposable =
                reactiveComic?.lastLoadError.producer.startWithNext(handleLastLoadErrorChanged)
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
        
    }
    
    private func handleLoadingChanged(loading: Bool) {
        
    }
    
    private func handleLastLoadErrorChanged(lastLoadError: ComicRepositoryError?) {
        
    }
}
