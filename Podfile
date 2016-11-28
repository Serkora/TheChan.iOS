platform :ios, '10.0'
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'

# This line is needed until OGVKit is fully published to CocoaPods
# Remove once packages published:
source 'https://github.com/Serkora/OGVKit-Specs.git'

target 'TheChan' do
    pod 'Alamofire', '~> 4.0'
    pod 'Kingfisher'
    pod 'MWPhotoBrowser'
    pod 'Fuzi', '~> 1.0.0'
    pod 'RealmSwift'
    pod 'IQKeyboardManagerSwift'
    pod 'OGVKit', '0.5pre'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
