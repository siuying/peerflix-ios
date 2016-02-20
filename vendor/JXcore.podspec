Pod::Spec.new do |spec|
  spec.name         = 'JXcore'
  spec.version      = '0.3.11'
  spec.license      = { :type => 'JXCORE', :file => 'jx_iosFATsm/JXCORE_LICENSE' }
  spec.homepage     = 'https://github.com/jxcore/jxcore'
  spec.authors      = { 'JXcore Contributors' => 'https://github.com/jxcore/jxcore/graphs/contributors' }
  spec.summary      = 'ARC Evented IO for Chakra, SpiderMonkey & V8 JavaScript.'
  spec.source       = { :http => 'https://jxcore.s3.amazonaws.com/0311/jx_iosFATsm.zip' }
  spec.public_header_files = '**/*.h'
  spec.preserve_paths = 'jx_iosFATsm'
  spec.vendored_libraries = [
    'jx_iosFATsm/libcares',
    'jx_iosFATsm/libchrome_zlib',
    'jx_iosFATsm/libhttp_parser',
    'jx_iosFATsm/libjx',
    'jx_iosFATsm/libleveldb',
    'jx_iosFATsm/libleveldown',
    'jx_iosFATsm/libmozjs',
    'jx_iosFATsm/libopenssl',
    'jx_iosFATsm/libsnapppy',
    'jx_iosFATsm/libsqlite3',
    'jx_iosFATsm/libuv'
  ]
  spec.libraries = [
    'cares',
    'chrome_zlib',
    'http_parser',
    'jx',
    'leveldb',
    'leveldown',
    'mozjs',
    'openssl',
    'snapppy',
    'sqlite3',
    'uv'
  ]
end
