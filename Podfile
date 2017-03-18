platform :ios, '8.0'
use_frameworks!

target 'Peerflix' do
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxOptional'

  pod 'Alamofire'
  pod 'Freddy'
  pod 'MarqueeLabel'
end

target 'PeerflixTests' do
  pod 'Nimble'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '3.0'
      end
  end
end
