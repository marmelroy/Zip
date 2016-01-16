![Zip - Zip and unzip files in Swift](https://cloud.githubusercontent.com/assets/889949/12374908/252373d0-bcac-11e5-8ece-6933aeae8222.png)

[![Build Status](https://travis-ci.org/marmelroy/Zip.svg?branch=master)](https://travis-ci.org/marmelroy/Zip) [![Version](http://img.shields.io/cocoapods/v/Zip.svg)](http://cocoapods.org/?q=Zip)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Zip
A Swift framework for zipping and unzipping files. Simple and quick to use.

## Usage

Import Zip at the top of the Swift file.

```swift
import Zip
```

## Quick functions

```swift
do {
    let bb8FilePath = NSBundle.mainBundle().URLForResource("bb8", withExtension: "zip")!
    try Zip().quickUnzipFile(bb8FilePath) // Unzip
    try Zip().quickZipFiles([bb8FilePath], fileName: "archive") // Zip
}
catch ErrorType {
  print("Something went wrong")
}
```


### Setting up with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Format into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "marmelroy/Zip"
```

### Setting up with [CocoaPods](http://cocoapods.org/?q=Zip)
```ruby
source 'https://github.com/CocoaPods/Specs.git'
pod 'Zip', '~> 0.1'
```
