require 'xcodeproj'

project_path = 'HorizonLockApp.xcodeproj'
project = Xcodeproj::Project.new(project_path)
target = project.new_target(:application, 'HorizonLockApp', :ios, '15.0')

file_ref = project.main_group.new_file('HorizonLockApp/main.swift')
target.add_file_references([file_ref])

target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.minh.horizonlock'
  config.build_settings['INFOPLIST_FILE'] = 'HorizonLockApp/Info.plist'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  
  # DÒNG QUAN TRỌNG NHẤT ĐỂ FIX LỖI @MAIN
  config.build_settings['OTHER_SWIFT_FLAGS'] = '$(inherited) -parse-as-library'
  
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
  config.build_settings['AD_HOC_CODE_SIGNING_ALLOWED'] = 'YES'
end

project.save