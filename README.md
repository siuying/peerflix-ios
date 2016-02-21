![Logo](https://github.com/siuying/peerflix-ios/blob/master/web/logo_bigger.png?raw=true)

# Peerflix for iOS

Streaming torrent client for iOS.

![Demo](https://github.com/siuying/peerflix-ios/blob/master/web/peerflix.gif?raw=true)

## Why?

There is a [blog post](http://reality.hk/2016/02/21/making-peerflix-for-ios-or-how-to-embed-any-nodejs-app-in-ios-app/) for that.

## Building

1. Checkout project ``git clone project-url``
2. Download and install [JXcore](http://jxcore.com/downloads/), its just a binary.
3. Install npm package with JXcore: ``jx install``
4. Setup IJKPlayer ``./bin/setup_ijkplayer``, this will checkout submodules and
static libraries.
5. Open workspace ``Peerflix.xcworkspace`` and Run!

## Dependency

- [JXcore](http://jxcore.com/home/)
- [peerflix](https://github.com/mafintosh/peerflix)
- [ijkplayer](https://github.com/Bilibili/ijkplayer)

## License

This is licensed under MIT License.
