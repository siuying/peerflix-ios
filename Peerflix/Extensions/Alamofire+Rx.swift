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

extension Request {
    func rx_reponseJSON() -> Observable<JSON> {
        return Observable.create({ (observer) -> Disposable in
            let request = self.responseData({ (response: Response<NSData, NSError>) -> Void in
                switch response.result {
                case .Failure(let error):
                    observer.onError(error)
                case .Success(let data):
                    do {
                        let json = try JSON(data: data)
                        observer.onNext(json)
                        observer.onCompleted()
                    } catch let error {
                        observer.onError(error)
                    }
                }
            })

            return AnonymousDisposable {
                request.cancel()
            }
        })
    }
}