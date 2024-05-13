require_relative 'swiftui'

platform :ios, '17.0'
use_modular_headers!

@swiftui_previews_enabled = true unless ENV['CI'] == 'true'

target 'CocoapodsSwiftUIPreviews' do
  pod 'FirstPod', path: 'FirstPod'
  pod 'SecondPod', path: 'SecondPod'
  pod 'ThirdPod', path: 'ThirdPod'
  pod 'FourthPod', path: 'FourthPod'
end
