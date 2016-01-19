//
//  FileBrowser.swift
//  Sample
//
//  Created by Roy Marmelstein on 17/01/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import UIKit
import Zip

class FileBrowser: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectionCounter: UIBarButtonItem!
    @IBOutlet weak var zipButton: UIBarButtonItem!
    @IBOutlet weak var unzipButton: UIBarButtonItem!
    
    let fileManager = NSFileManager.defaultManager()
    
    var path: NSURL? {
        didSet {
            updateFiles()
        }
    }

    
    var files = [String]()
    
    var selectedFiles = [String]()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        if self.path == nil {
            let documentsUrl = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
            self.path = documentsUrl
        }
        updateSelection()
    }
    
    //MARK: File manager
    
    func updateFiles() {
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
            tableView.reloadData()
        }
    }
    
    //MARK: UITableView Data Source and Delegate
    
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
        cell.selectionStyle = .None
        let filePath = files[indexPath.row]
        let newPath = path.URLByAppendingPathComponent(filePath).path!
        var isDirectory: ObjCBool = false
        fileManager.fileExistsAtPath(newPath, isDirectory: &isDirectory)
        cell.textLabel?.text = files[indexPath.row]
        if isDirectory {
            cell.imageView?.image = UIImage(named: "Folder")
        }
        else {
            cell.imageView?.image = UIImage(named: "File")
        }
        cell.backgroundColor = (selectedFiles.contains(filePath)) ? UIColor(white: 0.9, alpha: 1.0):UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let filePath = files[indexPath.row]
        if let index = selectedFiles.indexOf(filePath) where selectedFiles.contains(filePath) {
            selectedFiles.removeAtIndex(index)
        }
        else {
            selectedFiles.append(filePath)
        }
        updateSelection()
    }
    
    func updateSelection() {
        tableView.reloadData()
        selectionCounter.title = "\(selectedFiles.count) Selected"

        zipButton.enabled = (selectedFiles.count > 0)
        if (selectedFiles.count == 1) {
            let filePath = selectedFiles.first
            let pathExtension = path!.URLByAppendingPathComponent(filePath!).pathExtension
            if pathExtension == "zip" {
                unzipButton.enabled = true
            }
            else {
                unzipButton.enabled = false
            }
        }
        else {
            unzipButton.enabled = false
        }
    }
    
    //MARK: Actions
    
    @IBAction func unzipSelection(sender: AnyObject) {
        let filePath = selectedFiles.first
        let pathURL = path!.URLByAppendingPathComponent(filePath!)
        do {
            try Zip.quickUnzipFile(pathURL)
            self.selectedFiles.removeAll()
            updateSelection()
            updateFiles()
        } catch {
            print("ERROR")
        }
    }
    
    @IBAction func zipSelection(sender: AnyObject) {
        var urlPaths = [NSURL]()
        for filePath in selectedFiles {
            urlPaths.append(path!.URLByAppendingPathComponent(filePath))
        }
        do {
            try Zip.quickZipFiles(urlPaths, fileName: "Archive")
            self.selectedFiles.removeAll()
            updateSelection()
            updateFiles()
        } catch {
            print("ERROR")
        }
    }

}
