require 'xcodeproj'

# 1. Khởi tạo Project
project_path = 'HorizonLockApp.xcodeproj'
project = Xcodeproj::Project.new(project_path)

# 2. Tạo Target chính cho iOS 15
target = project.new_target(:application, 'HorizonLockApp', :ios, '15.0')

# 3. Thêm file code vào Project
# Lưu ý: Phải tạo file reference trong main_group trước
file_path = 'HorizonLockApp/main.swift'
file_ref = project.main_group.new_file(file_path)
target.add_file_references([file_ref])

# 4. Cấu hình Build Settings "Vàng"
target.build_configurations.each do |config|
  # Thông tin định danh App
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.minh.horizonlock'
  config.build_settings['PRODUCT_NAME'] = 'HorizonLock'
  
  # Chỉ định file Info.plist
  config.build_settings['INFOPLIST_FILE'] = 'HorizonLockApp/Info.plist'
  
  # Cấu hình Swift & iOS Target
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  
  # QUAN TRỌNG: Fix lỗi 'main' attribute bằng cách ép kiểu Library
  config.build_settings['OTHER_SWIFT_FLAGS'] = '$(inherited) -parse-as-library'
  
  # Cấu hình để ESign có thể ký đè lên dễ dàng (Bỏ qua ký chứng chỉ Apple)
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
  config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
  config.build_settings['ENTITLEMENTS_REQUIRED'] = 'NO'
  config.build_settings['AD_HOC_CODE_SIGNING_ALLOWED'] = 'YES'
  
  # Tối ưu cho chip Apple Silicon & Intel trên GitHub Actions
  config.build_settings['ARCHS'] = 'arm64'
end

# 5. Lưu Project
project.save
puts "---------------------------------------------------"
puts "✅ Project Config đã xong! Sẵn sàng để build IPA."
puts "🚀 Target: iOS 15.0 | Mode: S26 Ultra Horizon Lock"
puts "---------------------------------------------------"