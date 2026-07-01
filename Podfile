platform :ios, '13.0'

target 'Chord' do
  pod 'Masonry'
  pod 'SVProgressHUD', '~> 2.3.1'

  pod 'Google-Mobile-Ads-SDK', '13.5.0'
  pod 'ActionSheetPicker-3.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
