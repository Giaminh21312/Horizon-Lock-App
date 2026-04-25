require 'xcodeproj'
project_path = 'HorizonLockApp.xcodeproj'
project = Xcodeproj::Project.new(project_path)
target = project.new_target(:application, 'HorizonLockApp', :ios, '15.0')
target.add_file_references(Dir.glob('HorizonLockApp/*.swift'))
target.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = 'HorizonLockApp/Info.plist'
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
end
project.save