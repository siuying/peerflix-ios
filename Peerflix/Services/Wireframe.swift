//
//  Wireframe
//  Peerflix
//
//  Created by Chan Fai Chong on 21/2/2016.
//  Copyright © 2016 Ignition Soft. All rights reserved.
//

import Foundation
import RxSwift

protocol Wireframe {
    func setup()
    
    // remove temporary files
    func cleanup()
}

class DefaultWireframe: Wireframe {
    static let instance = DefaultWireframe()
    
    let disposeBag = DisposeBag()

    func setup() {
        NSNotificationCenter.defaultCenter()
            .rx_notification(UIApplicationWillTerminateNotification)
            .subscribeNext { (_) -> Void in
                self.cleanup()
            }
            .addDisposableTo(self.disposeBag)
    }

    func cleanup() {
        App.cleanTemporaryDirectory()
    }
}