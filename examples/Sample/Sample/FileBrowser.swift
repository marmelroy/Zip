//
//  FileBrowser.swift
//  Sample
//
//  Created by Roy Marmelstein on 17/01/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit

class FileBrowser: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var selectionCounter: UIBarButtonItem!
    
    let fileManager = NSFileManager.defaultManager()
    
    
    var path: NSURL? {
        didSet {
            if let filePath = path {
                var tempFiles = [String]()
                do  {
                    self.title = filePath.lastPathComponent
                    tempFiles = try self.fileManager.contentsOfDirectoryAtPath(filePath.path!)
                } catch {
                    if path == "/System" {
                        tempFiles = ["Library"]
                    }
                    if path == "/Library" {
                        tempFiles = ["Preferences"]
                    }
                    if path == "/var" {
                        tempFiles = ["mobile"]
                    }
                    if path == "/usr" {
                        tempFiles = ["lib", "libexec", "bin"]
                    }

                }
                self.files = tempFiles.sort(){$0 < $1}
            }
        }
    }

    var files = [String]()
    
    override func viewDidLoad() {
        if self.path == nil {
            let documentsUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
            self.path = documentsUrl
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "FileCell"
        var cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) {
            cell = reuseCell
        }
        guard let path = path else {
            return cell
        }
        let newPath = path.URLByAppendingPathComponent(files[indexPath.row]).path!
        var isDirectory: ObjCBool = false
        fileManager.fileExistsAtPath(newPath, isDirectory: &isDirectory)
        cell.textLabel?.text = files[indexPath.row]
        if isDirectory {
            cell.imageView?.image = UIImage(named: "Folder")
        }
        else {
            cell.imageView?.image = UIImage(named: "File")
        }
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}
