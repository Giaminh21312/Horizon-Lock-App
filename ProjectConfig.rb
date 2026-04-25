require 'xcodeproj'

project_path = 'HorizonLockApp.xcodeproj'
project = Xcodeproj::Project.new(project_path)

# Tạo target cho iOS 15
target = project.new_target(:application, 'HorizonLockApp', :ios, '15.0')

# Sửa lỗi ở đây: Tạo reference cho file trước khi add vào target
file_path = 'HorizonLockApp/main.swift'
file_ref = project.main_group.new_file(file_path)
target.add_file_references([file_ref])

# Cấu hình Build Settings
target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = 'HorizonLockApp/Info.plist'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
end

project.save
puts "Project Xcode đã được tạo thành công rồi nhé ông!"