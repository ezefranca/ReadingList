//
//  SearchResultsViewController.swift
//  books
//
//  Created by Andrew Bennet on 29/11/2015.
//  Copyright © 2015 Andrew Bennet. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchByIsbn: UIViewController {
 
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    /// This must be populated by any controller segueing to this one
    var isbn13: String!
    var foundMetadata: BookMetadata?
    
    override func viewDidLoad() {
        spinner.startAnimating()
        
        // We've found an ISBN-13. Let's search for it online.
        OnlineBookClient<GoogleBooksParser>.getBookMetadata(from: GoogleBooksRequest.getIsbn(isbn13).url, maxResults: 1, onError: errorHandler, onSuccess: searchCompletionHandler)
    }
    
    func searchCompletionHandler(_ metadata: [BookMetadata]) {
        spinner.stopAnimating()
        
        guard metadata.count == 1 else {
            presentInfoAlert(title: "No Results", message: "No matching books found online")
            return
        }
        
        foundMetadata = metadata[0]
        self.performSegue(withIdentifier: "showIsbnSearchResultSegue", sender: self)
    }
    
    func errorHandler(_ error: Error?) {
        spinner.stopAnimating()
        var message = "An error occurred."
        
        if let error = error as? NSError {
            switch error.code {
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorNetworkConnectionLost:
                message = "No internet connection."
            default:
                break
            }
        }
        presentInfoAlert(title: "Error", message: message)
    }
    
    func presentInfoAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { _ in
                self.spinner.stopAnimating()
                self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createReadStateController = segue.destination as? CreateReadState {
            createReadStateController.bookMetadata = foundMetadata
        }
    }
}
