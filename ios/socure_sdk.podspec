#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint socure_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'socure_sdk'
  s.version          = '1.0.0'
  s.summary          = 'Socure SDK Flutter wrapper.'
  s.description      = <<-DESC
Socure SDK Flutter wrapper.
                       DESC
  s.homepage         = 'http://envel.ai'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Envel Inc' => 'hello@envel.ai' }
  s.source           = { :path => '.' }
  #s.source           = { :git => "https://github.com/socure-inc/socure-ios-sdk.git", :tag => "dv-#{s.version}"}

  s.source_files = 'Classes/**/*'
  s.platform = :ios, '12.0'

  s.vendored_frameworks = "Frameworks/SocureSDK/Framework/SocureSdk.xcframework"
  s.preserve_paths = "Frameworks/SocureSDK/Framework/SocureSdk.xcframework"

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.dependency 'Flutter'
  s.dependency 'TrustKit'
end
