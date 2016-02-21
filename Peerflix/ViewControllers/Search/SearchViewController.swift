//
//  SearchViewController.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import UIKit

import RxSwift
import RxDataSources
import RxOptional

class SearchViewController: UIViewController {
    @IBOutlet var tableView : UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var initIndicator: UIActivityIndicatorView!

    var viewModel: SearchViewModelType!
    
    var services: ServiceFactory = DefaultServiceFactory.instance
    var torrent: TorrentService {
        return self.services.torrent
    }
    var router: Router {
        return self.services.router
    }

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // make search bar as table header
        self.tableView.tableHeaderView = self.searchBar

        let query: Observable<String> = self.searchBar
            .rx_text
            .asObservable()
            .map({ $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) })
            .shareReplay(1)

        let openItem: Observable<NSURL> = self.tableView.rx_modelSelected(SearchResult.Torrent.self)
            .map({ $0.URL })
            .filterNil()

        self.viewModel = SearchViewModel(
            input: (query: query, openItem: openItem),
            dependency: (torrent: self.torrent, router: self.router)
        )
        
        // Show loading indicator until service is loaded
        
        self.viewModel
            .loaded
            .startWith(false)
            .subscribeNext({ (loaded) -> Void in
                if loaded {
                    self.initIndicator.stopAnimating()
                } else {
                    self.initIndicator.startAnimating()
                }
            })
            .addDisposableTo(self.disposeBag)

        // Convert Sections into table view data source
        
        let datasource = RxTableViewSectionedAnimatedDataSource<SearchResultSection>()
        datasource.configureCell = { (table, indexPath, element) in
            let cell = table.dequeueReusableCellWithIdentifier(SearchResultCell.CellID, forIndexPath: indexPath) as! SearchResultCell
            cell.bindViewModel(element)
            return cell
        }
        self
            .viewModel
            .sections
            .bindTo(self.tableView.rx_itemsAnimatedWithDataSource(datasource))
            .addDisposableTo(self.disposeBag)
    }
}