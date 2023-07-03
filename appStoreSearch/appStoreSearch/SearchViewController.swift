////
////  SearchViewController.swift
////  appStoreSearch
////
////  Created by 박병훈 on 2023/07/03.
////
//
//import Foundation
//import UIKit
//
//class SearchViewController : UIViewController {
//    
//    // UI Components
//    private let searchBar: UISearchBar = {
//        let searchBar = UISearchBar()
//        searchBar.placeholder = "Search"
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//        return searchBar
//    }()
//    
//    private let tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        return tableView
//    }()
//    
//    private var searchResults: [App] = []
//    private var recentSearches: [String] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupUI()
//        fetchRecentSearches()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = .white
//        searchBar.delegate = self
//        tableView.dataSource = self
//        
//        view.addSubview(searchBar)
//        view.addSubview(tableView)
//        
//        NSLayoutConstraint.activate([
//            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            
//            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    private func fetchRecentSearches() {
//        // Fetch recent searches from data source
//        recentSearches = ["Music Player", "Calculator", "Weather App", "Music Downloader"]
//        tableView.reloadData()
//    }
//    
//    private func searchAppStore(with term: String) {
//        // Call App Store API and update searchResults
//        // Mock implementation
//        searchResults = [
//            App(name: "Music App", rating: 4.5, iconImage: UIImage(named: "music-icon")!, screenshotImage: UIImage(named: "music-screenshot")!, description: "A great music app"),
//            App(name: "Weather App", rating: 4.0, iconImage: UIImage(named: "weather-icon")!, screenshotImage: UIImage(named: "weather-screenshot")!, description: "Check the weather"),
//            App(name: "Calculator App", rating: 4.8, iconImage: UIImage(named: "calculator-icon")!, screenshotImage: UIImage(named: "calculator-screenshot")!, description: "Perform calculations"),
//        ]
//        tableView.reloadData()
//    }
//}
//
//// MARK: - UISearchBarDelegate
//
//extension SearchViewController: UISearchBarDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if let searchText = searchBar.text {
//            searchAppStore(with: searchText)
//        }
//        searchBar.resignFirstResponder()
//    }
//}
//
//// MARK: - UITableViewDataSource
//
//extension SearchViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return searchResults.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
//        let app = searchResults[indexPath.row]
//        cell.textLabel?.text = app.name
//        cell.detailTextLabel?.text = app.description
//        cell.imageView?.image = app.iconImage
//        return cell
//    }
//}
