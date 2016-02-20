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
    var tableView : UITableView!
    var searchBar: UISearchBar!

    var viewModel: SearchViewModelType!
    var torrent: TorrentService!
    let disposeBag = DisposeBag()

    init(torrent: TorrentService) {
        super.init(nibName: nil, bundle: nil)
        self.torrent = torrent
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView = UITableView(frame: self.view.bounds)
        self.tableView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.view.addSubview(self.tableView)
        self.tableView.registerClass(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.CellID)

        self.searchBar = UISearchBar()
        self.searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.tableHeaderView = self.searchBar
        
        self.searchBar.widthAnchor.constraintEqualToAnchor(self.tableView.widthAnchor).active = true
        self.searchBar.heightAnchor.constraintEqualToConstant(40).active = true
        
        let query: Observable<String> = self.searchBar
            .rx_text
            .asObservable()
            .map({ $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) })
            .shareReplay(1)

        let openItem: Observable<NSURL> = self.tableView.rx_modelSelected(SearchResult.Torrent.self)
            .map({ $0.URL })
            .filterNil()

        self.viewModel = SearchViewModel(input: (query: query, openItem: openItem), torrent: self.torrent)
        
        
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