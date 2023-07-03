//
//  ViewController.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/01.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults: [App] = []
    var recentSearches: [String] = []
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchRecentSearches()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    private func fetchRecentSearches() {
        // Fetch recent searches from data source
        recentSearches = ["Music Player", "Calculator", "Weather App", "Music Downloader"]
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // 검색어 입력이 없을 경우 최근 검색어 목록 표시
            searchResults = []
            //            tableView.reloadData()
        } else {
            // 최근 검색어에서 일치하는 항목 필터링
            searchResults = recentSearches.map { App(name: $0, rating: 0, userRatingCount: 0, iconImage: UIImage(), screenshotImage: UIImage(), screenshotImageUrls: [String](), description: "") }
            //            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        print("click")
        activityIndicator.startAnimating()
        
        // 앱스토어 API 호출
        searchAppStore(with: searchText) { [weak self] results in
            DispatchQueue.main.async {
                print("main")
                self?.searchResults = results
                self?.tableView.reloadData()
                
                self?.activityIndicator.stopAnimating()
            }
        }
        
        print("add")
        // 최근 검색어에 추가
        recentSearches.append(searchText)
        //        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        let app = searchResults[indexPath.row]
        cell.configure(with: app)
        
        return cell
    }
    
    // MARK: - Navigation
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("aaa")
        let app = searchResults[indexPath.row]
        performSegue(withIdentifier: "DetailSegue", sender: app)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("bbbb")
        if segue.identifier == "DetailSegue", let app = sender as? App {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.app = app
        }
    }
    
    // MARK: - App Store API
    
    func searchAppStore(with term: String, completion: @escaping ([App]) -> Void) {
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion([])
            return
        }
        
        let countryCode = "kr"
        
        let urlString = "https://itunes.apple.com/search?term=\(encodedTerm)&country=\(countryCode)&entity=software"
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let results = json["results"] as? [[String: Any]] else {
                completion([])
                return
            }
            
            var apps = [App]()
            
            for result in results {
                if let name = result["trackName"] as? String,
                   let artist = result["artistName"] as? String,
                   let rating = result["averageUserRating"] as? Double,
                   let userRatingCount = result["userRatingCount"] as? Int,
                   let iconUrlString = result["artworkUrl100"] as? String,
                   let screenshotUrls = result["screenshotUrls"] as? [String],
                   let iconUrl = URL(string: iconUrlString),
                   let iconData = try? Data(contentsOf: iconUrl),
                   let screenshotUrlString = screenshotUrls.first,
                   let screenshotUrl = URL(string: screenshotUrlString),
                   let screenshotData = try? Data(contentsOf: screenshotUrl),
                   let iconImage = UIImage(data: iconData),
                   let screenshotImage = UIImage(data: screenshotData) {
                    
                    let description = result["description"] as? String ?? ""
                    
                    let app = App(name: name, rating: rating, userRatingCount: userRatingCount,  iconImage: iconImage, screenshotImage: screenshotImage, screenshotImageUrls: screenshotUrls, description: description)
                    apps.append(app)
                }
            }
            
            completion(apps)
        }
        
        task.resume()
        
    }
}
