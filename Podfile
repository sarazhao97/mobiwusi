# Uncomment the next line to define a global platform for your project
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
# platform :ios, '9.0'

# 添加警告抑制配置
warn_for_unused_master_specs_repo = false


target 'shareExtension' do
  platform :ios, '13.0'
  use_frameworks!
  pod 'SnapKit', '~> 5.7'
end

target 'Mobiusi_iOS' do
  platform :ios, '13.0'
  use_frameworks!
  pod 'YYModel'
  pod 'YYText',:git => 'https://github.com/LoveSVN/YYText.git'
  pod 'Masonry'
  pod 'SDWebImage'
  pod 'AFNetworking', '~>3.0'
  pod 'JXCategoryView'
  pod 'SVProgressHUD'
  pod 'UITableView+FDTemplateLayoutCell',:git => 'https://github.com/LoveSVN/UITableView-FDTemplateLayoutCell.git'
  pod  'ZWPlaceHolder', :git => 'https://github.com/LoveSVN/ZWPlaceHolder.git'
  pod 'IQKeyboardManager'
  pod 'TZImagePickerController'
  pod 'UMPush'
  pod 'SnapKit', '~> 5.7'
  pod 'lottie-ios'
  pod 'WechatOpenSDK-XCFramework'
	pod 'TencentOpenAPI', :path => 'Mobiusi_iOS/Third/TencentOpenAPI'
#  pod 'AFServiceSDK'
  pod 'Reveal-SDK', '~> 52',:configurations => ['Debug']
  
  
  def sdkSetup(installer)
    installer.generated_projects.each do |project|
      project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
              # Only exclude arm64 for simulator builds, not device builds
              config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = '$(inherited) arm64'
              # Override the global EXCLUDED_ARCHS setting that was causing issues
              config.build_settings['EXCLUDED_ARCHS'] = '$(inherited)'
              config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
              # Remove VALID_ARCHS restriction to allow both simulator and device builds
              # config.build_settings['VALID_ARCHS'] = 'x86_64'
            end
      end
    end
  end
  
  def deleteUIWebView(installer)
     installer.generated_projects.each do |project|
        project.targets.each do |target|
            if target.name.eql?('AFNetworking')
#                删除.h文件引用
              target.headers_build_phase.files.reject! do |file|
                  file_path = file.file_ref.real_path.to_s
                  if file_path.include?('UIWebView+AFNetworking')
                      puts "Removing header file reference: #{file_path}"
                      true
                  else
                      false
                  end
              end
#                删除.m文件引用
              target.source_build_phase.files.reject! do |file|
                  file_path = file.file_ref.real_path.to_s
                  if file_path.include?('UIWebView+AFNetworking')
                      puts "Removing source file reference: #{file_path}"
                      true
                  else
                      false
                  end
              end
            end
            
        end
     end
  end
  
  post_install do |installer|
    sdkSetup(installer)
    deleteUIWebView(installer)
  end
  
end
