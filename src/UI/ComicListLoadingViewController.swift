//
//  ComicListLoadingViewController.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 09/05/16.
//
//

import UIKit

final class ComicListLoadingViewController: UIViewController {

    private let presenter: ComicListLoadingPresenter
    
    required init(presenter: ComicListLoadingPresenter) {
        self.presenter = presenter
        super.init(nibName: NSStringFromClass(self.dynamicType), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
