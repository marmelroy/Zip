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

  s.source_files = 'Zip'
  s.xcconfig = {'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/minzip/"', 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'}
  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.libraries = 'libz.tbd'

  s.subspec 'minizip' do |ss|
  ss.source_files = 'Zip/minizip/aes/sha1.h','Zip/minizip/aes/sha1.c','Zip/minizip/aes/prng.h','Zip/minizip/aes/prng.c','Zip/minizip/aes/aeskey.h','Zip/minizip/aes/aeskey.c','Zip/minizip/aes/aestab.h','Zip/minizip/aes/aestab.c','Zip/minizip/aes/hmac.h','Zip/minizip/aes/hmac.c','Zip/minizip/aes/entropy.h','Zip/minizip/aes/entropy.c','Zip/minizip/aes/aescrypt.h','Zip/minizip/aes/aescrypt.c','Zip/minizip/aes/fileenc.h','Zip/minizip/aes/fileenc.c','Zip/minizip/aes/pwd2key.h','Zip/minizip/aes/pwd2key.c','Zip/minizip/crypt.h','Zip/minizip/ioapi.h','Zip/minizip/ioapi.c','Zip/minizip/unzip.h','Zip/minizip/unzip.c','Zip/minizip/zip.h','Zip/minizip/zip.c'
  ss.private_header_files = 'Zip/minizip/aes/sha1.h','Zip/minizip/aes/sha1.c','Zip/minizip/aes/prng.h','Zip/minizip/aes/prng.c','Zip/minizip/aes/aeskey.h','Zip/minizip/aes/aeskey.c','Zip/minizip/aes/aestab.h','Zip/minizip/aes/aestab.c','Zip/minizip/aes/hmac.h','Zip/minizip/aes/hmac.c','Zip/minizip/aes/entropy.h','Zip/minizip/aes/entropy.c','Zip/minizip/aes/aescrypt.h','Zip/minizip/aes/aescrypt.c','Zip/minizip/aes/fileenc.h','Zip/minizip/aes/fileenc.c','Zip/minizip/aes/pwd2key.h','Zip/minizip/aes/pwd2key.c','Zip/minizip/crypt.h','Zip/minizip/ioapi.h','Zip/minizip/ioapi.c','Zip/minizip/unzip.h','Zip/minizip/unzip.c','Zip/minizip/zip.h','Zip/minizip/zip.c'
  ss.frameworks = 'Security'
  end

  # s.dependency 'AFNetworking', '~> 2.3'
end
