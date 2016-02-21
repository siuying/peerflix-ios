//
//  SearchViewModel.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift

extension SearchResult.Torrent: IdentifiableType {
    typealias Identity = String
    var identity : String {
        return self.URL?.absoluteString ?? ""
    }
}

struct SearchResultSection {
    var torrents: [SearchResult.Torrent]
    var id: String
    
    init(id: String, torrents: [SearchResult.Torrent]) {
        self.torrents = torrents
        self.id = id
    }
}

extension SearchResultSection: AnimatableSectionModelType {
    typealias Item = SearchResult.Torrent
    typealias Identity = String
    
    var items: [SearchResult.Torrent] {
        return self.torrents
    }
    
    var identity: String {
        return self.id
    }
    
    init(original: SearchResultSection, items: [SearchResult.Torrent]) {
        self = original
        self.torrents = items
    }
}

protocol SearchViewModelType {
    var engine: Observable<String> { get }
    var loaded: Observable<Bool>! { get }
    var sections: Observable<[SearchResultSection]>! { get }
}

class SearchViewModel: SearchViewModelType {
    var engine: Observable<String>
    var loaded: Observable<Bool>!
    var sections: Observable<[SearchResultSection]>!

    private let disposeBag = DisposeBag()

    init(
        input: (query: Observable<String>, openItem: Observable<SearchResult.Torrent>),
        torrent: TorrentService
    ) {
        let (query, openItem) = input
        let state = torrent.getState()

        self.loaded = state.map({ $0.status != .Init })
            .distinctUntilChanged()
            .shareReplay(1)            
            .observeOn(MainScheduler.instance)

        self.engine = torrent
            .getSearchEngine()
            .map({ $0.title })

        self.sections = self.configureSection(loaded: self.loaded, query: query, torrent: torrent)
        
        self.configActions(openItem, torrent: torrent)
    }
    
    func configureSection(loaded loaded: Observable<Bool>, query: Observable<String>, torrent: TorrentService) -> Observable<[SearchResultSection]>  {

        let searchResult:Variable<[SearchResult.Torrent]> = Variable([])
        
        // only query after service loaded
        let queryUntilLoaded: Observable<String> =  Observable
            .combineLatest(loaded, query) { (loaded, query) -> (Bool, String) in
                return (loaded, query)
            }
            .filter({ (loaded, _) in loaded })
            .map({ $1 })
        
        queryUntilLoaded
            .filter({ $0.unicodeScalars.count > 3 })            // only search longer query
            .debounce(1.0, scheduler: MainScheduler.instance)   // prevent query too much
            .flatMapLatest({
                torrent
                    .search($0)                                 // perform search
                    .catchErrorJustReturn(SearchResult.error)   // ignore errors
            })
            .map({$0.torrents})                                 // map result
            .bindTo(searchResult)                               // bind result
            .addDisposableTo(self.disposeBag)
        
        let currentQuery: Variable<String> = Variable("")
        query.bindTo(currentQuery)
            .addDisposableTo(self.disposeBag)
        
        Observable.combineLatest(currentQuery.asObservable(), torrent.getSearchEngine()
            .distinctUntilChanged()) { (query, engine) -> String in
                return query
            }
            .filter({ $0.unicodeScalars.count > 3 })
            .distinctUntilChanged()
            .asObservable()
            .flatMapLatest({ _ -> Observable<SearchResult> in
                torrent
                    .search(currentQuery.value)                 // perform search
                    .catchErrorJustReturn(SearchResult.error)   // ignore errors
            })
            .map({$0.torrents})                                 // map result
            .bindTo(searchResult)                               // bind result
            .addDisposableTo(self.disposeBag)


        return searchResult
            .asObservable()
            .map({ [SearchResultSection(id: "1", torrents: $0)] })
            .shareReplay(1)
    }
    
    func configActions(openItem: Observable<SearchResult.Torrent>, torrent: TorrentService) {
        let request = openItem
            .flatMapLatest({ torrent.playTorrent($0) })

        request
            .subscribeError({ (error) -> Void in
                print("ERROR: \(error)")
            })
            .addDisposableTo(self.disposeBag)
    }
}