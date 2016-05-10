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
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(ComicListTableViewCell.self,
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
        
        cell.reactiveComic = presenter[UInt(indexPath.row)]
//        var text = ""
//        
//        if case let .Number(number) = reactiveComic.comicIdentifier {
//            text.appendContentsOf("\(number).")
//        }
//        if let comic = reactiveComic.comic.value {
//            text.appendContentsOf(comic.title)
//        }
//        
//        cell.textLabel?.text = text
        return cell
    }
}

extension ComicListViewController {
    
}
