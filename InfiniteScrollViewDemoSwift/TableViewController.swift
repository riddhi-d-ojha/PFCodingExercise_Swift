//
//  TableViewController.swift
//  InfiniteScrollViewDemoSwift
//
//  Created by Riddhi Ojha on 10/13/17.
//  Copyright © 2017 Riddhi Ojha. All rights reserved.
//

import UIKit
private let useAutosizingCells = true

class TableViewController: UITableViewController {
    
    fileprivate let cellIdentifier = "Cell"
    fileprivate var currentPage = 0
    fileprivate var numPages = 0
    fileprivate var properties = [ListModel]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if useAutosizingCells && tableView.responds(to: #selector(getter: UIView.layoutMargins)) {
            tableView.estimatedRowHeight = 88
            tableView.rowHeight = UITableViewAutomaticDimension
        }
        
        // Set custom indicator
        tableView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        
        // Set custom indicator margin
        tableView.infiniteScrollIndicatorMargin = 40
        
        // Set custom trigger offset
        tableView.infiniteScrollTriggerOffset = 500
        
        // Add infinite scroll handler
        tableView.addInfiniteScroll { [weak self] (tableView) -> Void in
            self?.performFetch {
                tableView.finishInfiniteScroll()
            }
        }
        // load initial data
        tableView.beginInfiniteScroll(true)
    }
    
    fileprivate func performFetch(_ completionHandler: (() -> Void)?) {
        fetchData { (fetchResult) in
            do {
                let (newProperties, nextPage) = try fetchResult()
                
                // create new index paths
                let listCount = self.properties.count
                let (start, end) = (listCount, newProperties.count + listCount)
                let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
                
                // update data source
                self.properties.append(contentsOf: newProperties)
                self.currentPage = nextPage
                
                // update table view
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: indexPaths, with: .automatic)
                self.tableView.endUpdates()
            } catch {
                self.showAlertWithError(error)
            }
            
            completionHandler?()
        }
    }
    
    fileprivate func showAlertWithError(_ error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("tableView.errorAlert.title", comment: ""),
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("tableView.errorAlert.dismiss", comment: ""),
                                      style: .cancel,
                                      handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("tableView.errorAlert.retry", comment: ""),
                                      style: .default,
                                      handler: { _ in self.performFetch(nil) }))
        
        self.present(alert, animated: true, completion: nil)
    }

}

// MARK: - Actions

extension TableViewController {
    
    @IBAction func handleRefresh() {
//        let sortedKeysAndValues = Array(dictionary).sort({ $0.0 < $1.0 })
        
        let alertController = UIAlertController(title: "Sort By", message: "", preferredStyle: .actionSheet)
    
        let priceSort1 = UIAlertAction(title: "Sort by price - Low to high", style: .default, handler: { (action) -> Void in
            self.properties.sort{
                ($0).price_value! < ($1).price_value!
            }
            self.tableView.reloadData()
        })
        
        let priceSort2 = UIAlertAction(title: "Sort by price - High to Low", style: .default, handler: { (action) -> Void in
            self.properties.sort{
                ($0).price_value! > ($1).price_value!
            }
            self.tableView.reloadData()
        })
        
        let  bedrooms1 = UIAlertAction(title: "Sort by bedroom - Few to More", style: .default, handler: { (action) -> Void in
            self.properties.sort{
                ($0).bedrooms! < ($1).bedrooms!
            }
            self.tableView.reloadData()
        })
        
        let bedrooms2 = UIAlertAction(title: "Sort by bedroom - More to Few", style: .default, handler: { (action) -> Void in
            self.properties.sort{
                ($0).bedrooms! > ($1).bedrooms!
            }
            self.tableView.reloadData()
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        alertController.addAction(priceSort1)
        alertController.addAction(priceSort2)
        alertController.addAction(bedrooms1)
        alertController.addAction(bedrooms2)
        alertController.addAction(cancelButton)
        
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
        
    }
    
    
}

// MARK: - UITableViewDelegate

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}
// MARK: - UITableViewDataSource

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let list = properties[indexPath.row]
        
        cell.textLabel?.text = list.author
        cell.detailTextLabel?.text = "Price \(list.priceInString!) | Bedrooms \(list.bedrooms!)"
        
        if useAutosizingCells && tableView.responds(to: #selector(getter: UIView.layoutMargins)) {
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.numberOfLines = 0
        }
        
        return cell
    }
    
}

// MARK: - API

fileprivate enum ResponseError: Error {
    case load
    case noData
    case deserialization
}

extension ResponseError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .load:
            return NSLocalizedString("responseError.load", comment: "")
        case .deserialization:
            return NSLocalizedString("responseError.deserialization", comment: "")
        case .noData:
            return NSLocalizedString("responseError.noData", comment: "")
        }
    }
    
}

typealias FetchResult = () throws -> ([ListModel], Int)

extension TableViewController {
    
    fileprivate func apiURL(_ numHits: Int, page: Int) -> URL {
        let string = "https://www.propertyfinder.ae/mobileapi?page=\(page)&order=pd"
        let url = URL(string: string)
        
        return url!
    }
    
    fileprivate func fetchData(_ handler: @escaping ((FetchResult) -> Void)) {
        let hits = Int(tableView.bounds.height) / 44
        let requestURL = apiURL(hits, page: currentPage)
        
        let task = URLSession.shared.dataTask(with: requestURL, completionHandler: {
            (data, _, error) -> Void in
            DispatchQueue.main.async {
                handler({ (Void) -> ([ListModel], Int) in
                    return try self.handleResponse(data, error: error)
                })
                
                UIApplication.shared.stopNetworkActivity()
            }
        })
        
        UIApplication.shared.startNetworkActivity()
        
        // I run task.resume() with delay because my network is too fast
        let delay = (properties.count == 0 ? 0 : 5)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            task.resume()
        })
    }
    
    fileprivate func handleResponse(_ data: Data?, error: Error?) throws -> ([ListModel], Int) {
        let resultsKey = "res"
        
        if error != nil { throw ResponseError.load }
        
        guard let data = data else { throw ResponseError.noData }
        let raw = try? JSONSerialization.jsonObject(with: data, options: [])
        
        guard let response = raw as? [String: AnyObject],
              let entries = response[resultsKey] as? [[String: AnyObject]] else { throw ResponseError.deserialization }
        
        let newProperties = entries.flatMap { return ListModel($0) }
        
        return (newProperties, currentPage + 1)
    }
    
}
