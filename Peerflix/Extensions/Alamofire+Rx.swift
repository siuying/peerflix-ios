//
//  Alamofire+Rx.swift
//  TorrentStream
//
//  Created by Chan Fai Chong on 20/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import Freddy

extension DataRequest: ReactiveCompatible {
}

extension Reactive where Base: DataRequest {
    func responseJSON() -> Observable<JSON> {
        return Observable.create({ (observer) -> Disposable in
            let request = self.base.responseData(completionHandler: { (data) in
                if let error = data.error {
                    observer.onError(error)
                } else if let data = data.data {
                    do {
                        let json = try JSON(data: data)
                        observer.onNext(json)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                } else {
                    fatalError("unexpected")
                }
            })
            return Disposables.create { request.cancel() }
        })
    }
}
