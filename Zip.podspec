#
# Be sure to run `pod lib lint Zip.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Zip"
  s.version          = "0.1.0"
  s.summary          = "Zip and unzip files in Swift."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                      A Swift framework for zipping and unzipping files. Simple and quick to use. Built on top of minizip.
                     DESC

  s.homepage         = "https://github.com/marmelroy/Zip"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Roy Marmelstein" => "marmelroy@gmail.com" }
  s.source           = { :git => "https://github.com/marmelroy/Zip.git", :tag => s.version.to_s }
  s.social_media_url   = "http://twitter.com/marmelroy"

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Zip','Zip/minizip/crypt.h','Zip/minizip/ioapi.h','Zip/minizip/ioapi.c','Zip/minizip/module.modulemap','Zip/minizip/unzip.h','Zip/minizip/unzip.c','Zip/minizip/zip.h','Zip/minizip/zip.c','Zip/minizip/ioapi.h','Zip/minizip/aes/'
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO'}
  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.libraries = 'libz'
  # s.dependency 'AFNetworking', '~> 2.3'
end
