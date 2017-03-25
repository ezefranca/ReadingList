//
//  Settings.swift
//  books
//
//  Created by Andrew Bennet on 23/10/2016.
//  Copyright © 2016 Andrew Bennet. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD
import SwiftyJSON

class Settings: UITableViewController {

    @IBOutlet weak var addTestDataCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if !DEBUG
        addTestDataCell.isHidden = true
        #endif
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            UIApplication.shared.openURL(URL(string: "https://andrewbennet.github.io/readinglist")!)
        }
        
        #if DEBUG
        if indexPath.section == 1 && indexPath.row == 0 {
            loadTestData()
        }
        #endif
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    #if DEBUG
    func loadTestData() {

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let testJsonData = JSON(data: NSData.fromMainBundle(resource: "example_books", type: "json") as Data)
        appDelegate.booksStore.deleteAllData()
        
        let requestDispatchGroup = DispatchGroup()
        var sortIndex = -1
        
        for testBook in testJsonData.array! {
            let parsedData = BookImport.fromJson(testBook)
            
            if parsedData.1.readState == .toRead {
                sortIndex += 1
            }
            let thisSort = sortIndex
            
            requestDispatchGroup.enter()
            DispatchQueue.global(qos: .background).async {
                GoogleBooksAPI.supplementMetadataWithImage(parsedData.0) {
                    DispatchQueue.main.sync {
                        appDelegate.booksStore.create(from: parsedData.0, readingInformation: parsedData.1, bookSort: thisSort)
                        requestDispatchGroup.leave()
                    }
                }
            }
        }

        requestDispatchGroup.notify(queue: .main) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    #endif
}