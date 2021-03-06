#
# Be sure to run `pod lib lint ZZScreenBrightness.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZZScreenBrightness'
  s.version          = '0.1.0'
  s.summary          = "iOS类似二维码页渐变调整屏幕亮度"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "iOS类似二维码页渐变调整屏幕亮度,渐变调整屏幕亮度"

  s.homepage         = 'https://github.com/pengzz/ZZScreenBrightness'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pengzz' => 'pzz1284@163.com' }
  s.source           = { :git => 'https://github.com/pengzz/ZZScreenBrightness.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZZScreenBrightness/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZZScreenBrightness' => ['ZZScreenBrightness/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
