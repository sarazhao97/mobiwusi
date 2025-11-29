Pod::Spec.new do |s|
  s.name             = 'TencentOpenAPI'
  s.version          = '3.5.12'
  s.summary          = 'QQ分享的pod仓库'
  s.description      = <<-DESC
本仓库旨在收集最新的SDK方便使用cocoapods引入项目
                       DESC


  s.homepage         = 'https://gitee.com/cocoa-pods/TencentOpenAPI_iOS'
  s.license          = 'MIT'
  s.author           = { 'JackLi' => '522185660@qq.com' }
  s.source           = { :git => 'https://gitee.com/cocoa-pods/TencentOpenAPI_iOS.git', :tag => s.version.to_s }

  s.frameworks             = 'Security', 'CoreFoundation','MobileCoreServices','QuartzCore','SystemConfiguration', 'CoreGraphics', 'CoreTelephony', 'WebKit'
  s.libraries              = 'iconv', 'sqlite3', 'stdc++', 'z','z.1.1.3'

  s.ios.deployment_target  = '7.0'
  s.resources = '*.bundle'
  s.public_header_files  =  '*.framework/Headers/*.h'
  s.source_files = '*.framework/Headers/*.{h}'
  s.vendored_frameworks  =  '*.framework'
  s.pod_target_xcconfig    = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig   = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.requires_arc           = true

end
