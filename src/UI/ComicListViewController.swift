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
    
    private static let reuseIdentifier = "ComicCellReuseIdentifier"
    
    required init(presenter: ComicListPresenter) {
        self.presenter = presenter
        super.init(style: .Plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.registerNib(UINib(nibName: "ComicListTableViewCell", bundle: nil),
            forCellReuseIdentifier: self.dynamicType.reuseIdentifier)
    }
}

extension ComicListViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.comicCount.value.map({ Int($0) }) ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.dynamicType.reuseIdentifier,
                                                               forIndexPath: indexPath) as! ComicListTableViewCell
        let reactiveComic = presenter[UInt(indexPath.row)]
        cell.reactiveComic = reactiveComic
        if let reactiveComic = reactiveComic where
            reactiveComic.comic.value == nil &&
            !reactiveComic.loading.value {
            reactiveComic.retrieveComic()
        }
        return cell
    }
}

extension ComicListViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
}
