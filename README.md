![Zip - Zip and unzip files in Swift](https://cloud.githubusercontent.com/assets/889949/12374908/252373d0-bcac-11e5-8ece-6933aeae8222.png)

[![Build Status](https://travis-ci.org/marmelroy/Zip.svg?branch=master)](https://travis-ci.org/marmelroy/Zip) [![Version](http://img.shields.io/cocoapods/v/Zip.svg)](http://cocoapods.org/?q=Zip)

# Zip
A Swift framework for zipping and unzipping files. Simple and quick to use. Built on top of [minizip](https://github.com/nmoinvaz/minizip).

## Usage

Import Zip at the top of the Swift file.

```swift
import Zip
```

## Quick functions

The easiest way to use Zip is through quick functions. Both take local file paths as NSURLs, throw if an error is encountered and return an NSURL to the destination if successful.
```swift
do {
    let filePath = NSBundle.mainBundle().URLForResource("file", withExtension: "zip")!
    let unzipDirectory = try Zip.quickUnzipFile(filePath) // Unzip
    let zipFilePath = try Zip.quickZipFiles([filePath], fileName: "archive") // Zip
}
catch {
  print("Something went wrong")
}
```

## Advanced Zip

For more advanced usage, Zip has functions that let you set custom  destination paths, work with password protected zips and use a progress handling closure. These functions throw if there is an error but don't return.
```swift
do {
    let filePath = NSBundle.mainBundle().URLForResource("file", withExtension: "zip")!
    let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL

    try Zip.unzipFile(filePath, destination: documentsDirectory, overwrite: true, password: "password", progress: { (progress) -> () in
        print(progress)
    }) // Unzip

    let zipFilePath = documentsFolder.URLByAppendingPathComponent("archive.zip")
    try Zip.zipFiles([filePath], zipFilePath: zipFilePath, password: "password", progress: { (progress) -> () in
        print(progress)
    }) //Zip

}
catch {
  print("Something went wrong")
}
```

## Custom File Extensions

Zip supports '.zip' and '.cbz' files out of the box. To support additional zip-derivative file extensions:
```
Zip.addCustomFileExtension("file-extension-here")
```

### Setting up with [CocoaPods](http://cocoapods.org/?q=Zip)
```ruby
source 'https://github.com/CocoaPods/Specs.git'
pod 'Zip', '~> 0.5', :submodules => true
```
