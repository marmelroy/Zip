#
# Be sure to run `pod lib lint Zip.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Zip"
  s.version          = "2.1.1"
  s.summary          = "Zip and unzip files in Swift."
  s.swift_version    = "5.3"
  s.swift_versions   = ["4.2", "5.0", "5.1", "5.3"]

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                      A Swift framework for zipping and unzipping files. Simple and quick to use. Built on top of minizip.
                     DESC

  s.homepage         = "https://github.com/marmelroy/Zip"
  s.license          = 'MIT'
  s.author           = { "Roy Marmelstein" => "marmelroy@gmail.com" }
  s.source           = { :git => "https://github.com/marmelroy/Zip.git", :tag => s.version.to_s}
  s.social_media_url   = "http://twitter.com/marmelroy"

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '3.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  s.source_files = 'Zip/*.{swift,h}', 'Zip/minizip/*.{c,h}', 'Zip/minizip/include/*.{c,h}'
  s.public_header_files = 'Zip/*.h'
  s.pod_target_xcconfig = {'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Zip/Zip/minizip/**','LIBRARY_SEARCH_PATHS' => '$(SRCROOT)/Zip/Zip/'}
  s.libraries = 'z'
  s.preserve_paths  = 'Zip/minizip/module/module.modulemap'
end
