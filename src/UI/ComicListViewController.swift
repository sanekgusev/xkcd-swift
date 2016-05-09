//
//  ComicListViewController.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 09/05/16.
//
//

import UIKit

final class ComicListViewController: UITableViewController {

    private let presenter: ComicListPresenter
    
    required init(presenter: ComicListPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ComicListViewController {
    
}

extension ComicListViewController {
    
}
