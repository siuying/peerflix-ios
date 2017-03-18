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
    @IBOutlet var settingButton: UIBarButtonItem!

    var viewModel: SearchViewModelType!
    
    var services: ServiceFactory = DefaultServiceFactory.instance
    var torrent: TorrentService {
        return self.services.torrent
    }

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // make search bar as table header
        self.tableView.tableHeaderView = self.searchBar

        let query: Observable<String> = self.searchBar
            .rx.text.asObservable()
            .map({ $0?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "" })
            .shareReplay(1)
        
        let openItem: Observable<SearchResult.Torrent> = self.tableView.rx.modelSelected(SearchResult.Torrent.self)
            .asObservable()

        self.viewModel = SearchViewModel(
            input: (query: query, openItem: openItem),
            torrent: self.torrent
        )

        // set search engine
        self.viewModel
            .engine
            .subscribe(onNext: { (title) -> Void in
                self.settingButton.title = title
            })
            .addDisposableTo(self.disposeBag)
        
        // Show loading indicator until service is loaded
        
        self.viewModel
            .loaded
            .startWith(false)
            .subscribe(onNext: { loaded in
                if loaded {
                    self.initIndicator.stopAnimating()
                } else {
                    self.initIndicator.startAnimating()
                }
            })
            .addDisposableTo(self.disposeBag)

        // Convert Sections into table view data source
        
        let datasource = RxTableViewSectionedAnimatedDataSource<SearchResultSection>()
        datasource.configureCell = { (ds, table, indexPath, element) in
            let cell = table.dequeueReusableCell(withIdentifier: SearchResultCell.CellID, for: indexPath) as! SearchResultCell
            cell.bindViewModel(element)
            return cell
        }
        self
            .viewModel
            .sections
            .bindTo(self.tableView.rx.items(dataSource: datasource))
            .addDisposableTo(self.disposeBag)
        
        // settings
        
        self.settingButton.rx.tap
            .subscribe(onNext:self.showSearchOptions)
            .addDisposableTo(self.disposeBag)
    }
    
    fileprivate func showSearchOptions() {
        let engines : [TorrentServiceAPI.SearchEngine] = [.DMHY, .PirateBay, .Nyaa]
        let alert = UIAlertController(title: "Select a Search Engine", message: nil, preferredStyle: .alert)
        for engine in engines {
            alert.addAction(UIAlertAction(title: engine.title, style: .default, handler: { [weak self] (_) -> Void in
                self?.torrent.setSearchEngine(engine)
            }))
        }
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
}
