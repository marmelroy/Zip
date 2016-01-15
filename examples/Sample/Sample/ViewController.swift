//
//  ViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 13/01/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit
import Zip

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let destinationPath = tempUnzipPath()!
            let fileAbsolutePath = NSBundle.mainBundle().pathForResource("master", ofType: "zip")
            let fileAbsoluteURL = NSURL(string: fileAbsolutePath!)!
            print(destinationPath)
            try Zip().unzipFile(fileAbsoluteURL)
            try Zip().zipFiles([fileAbsoluteURL], fileName: "zipTest")

        }
        catch {
            print("oops")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tempUnzipPath() -> NSURL? {
        var path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        path += "/\(NSUUID().UUIDString)"
        let url = NSURL(fileURLWithPath: path)
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
        return url
    }

}

