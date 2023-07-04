//
//  ViewController.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/01.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var historySerachTableView: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var searchResults: [App] = []
    
    var searchHistory: [String] = []
    var filteredSearchHistory: [String] = []
    var activityIndicator: UIActivityIndicatorView!
    
    var headerUse : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        if let savedSearchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory"){
            searchHistory = savedSearchHistory
        }
        
        filteredSearchHistory = searchHistory
        
        searchBar.delegate = self
        searchBar.placeholder = "게임, 앱, 스토리 등"
        
        historySerachTableView.delegate = self
        historySerachTableView.dataSource = self
        
        historySerachTableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        searchBar.searchBarStyle = .minimal
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
            
            let subtitle = json["subtitle"] as? String
            
            var apps = [App]()
            
            for result in results {
                if let name = result["trackName"] as? String,
                   let rating = result["averageUserRating"] as? Double,
                   let userRatingCount = result["userRatingCount"] as? Int,
                   let iconUrlString = result["artworkUrl100"] as? String,
                   let screenshotUrls = result["screenshotUrls"] as? [String],
                   let iconUrl = URL(string: iconUrlString),
                   let iconData = try? Data(contentsOf: iconUrl),
                   let iconImage = UIImage(data: iconData),
                   let description = result["description"] as? String,
                   let releaseNotes = result["releaseNotes"] as? String,
                   let screenshotUrlString = screenshotUrls.first,
                   let screenshotUrl = URL(string: screenshotUrlString),
                   let screenshotData = try? Data(contentsOf: screenshotUrl),
                   let screenshotImage = UIImage(data: screenshotData) {
                    
                    let subtitle = result["subtitle"] as? String
                    
                    let app = App(name: name, rating: rating, userRatingCount: userRatingCount,  iconImage: iconImage, screenshotImage: screenshotImage, screenshotImageUrls: screenshotUrls, releaseNotes: releaseNotes, description: description)
                    apps.append(app)
                }
            }
            
            completion(apps)
        }
        
        task.resume()
        
    }
    
    private func mainViewCheck(){
        if mainView.isHidden{
            tableView.isHidden = true
            mainView.isHidden = false
        }
    }
//
//    @IBAction func cancelBtnClicked(_ sender: Any) {
//
//        topView.isHidden = false
//
//        searchBar.text = ""
//        searchBar.resignFirstResponder()
//
//        mainViewCheck()
//        headerUse = true
//
//        cancelBtn.isHidden = true
//
////        searchBar.setShowsCancelButton(false, animated: true)
//
//        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
//
//        view.constraints.filter { $0.firstItem === searchBar && $0.firstAttribute == .top }.forEach { $0.isActive = false }
//
//        searchBar.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0).isActive = true
//
//        filteredSearchHistory = searchHistory
//
//        historySerachTableView.reloadData()
//    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty || searchBar.text == "" {
            // 검색어 입력이 없을 경우 최근 검색어 목록 표시
            filteredSearchHistory = searchHistory
            
        } else {
            // 최근 검색어에서 일치하는 항목 필터링
            filteredSearchHistory = searchHistory.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        
        mainViewCheck()
        
        historySerachTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        topView.isHidden = true
        
        cancelBtn.isHidden = false
        
//        searchBar.setShowsCancelButton(true, animated: true)
        
        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -70).isActive = true
        
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        
        cancelBtn.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 0).isActive = true
        
        headerUse = false
        historySerachTableView.tableHeaderView = nil
        
        historySerachTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        topView.isHidden = false
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        mainViewCheck()
        headerUse = true
        
        cancelBtn.isHidden = true
        
//        searchBar.setShowsCancelButton(false, animated: true)
        
        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
        view.constraints.filter { $0.firstItem === searchBar && $0.firstAttribute == .top }.forEach { $0.isActive = false }
        
        searchBar.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0).isActive = true
        
        filteredSearchHistory = searchHistory
        
        historySerachTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        
        view.isUserInteractionEnabled = false
        
        activityIndicator.startAnimating()
        
        // 앱스토어 API 호출
        searchAppStore(with: searchText) { [weak self] results in
            DispatchQueue.main.async {
                self?.searchResults = results
                self?.topView.isHidden = true
                self?.mainView.isHidden = true
                self?.tableView.isHidden = false
                self?.view.isUserInteractionEnabled = true
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }
        searchHistory.append(searchText)
        
        let removedDuplicate: Set = Set(searchHistory)
        
        UserDefaults.standard.set(Array(removedDuplicate), forKey: "searchHistory")
        UserDefaults.standard.synchronize()
        
        searchBar.resignFirstResponder()
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView{
            return searchResults.count
        }else{
            
            if searchHistory.count == 0 {
                // 검색 기록이 없는 경우 최근 검색어가 없음을 나타내는 라벨을 보여줌
                historySerachTableView.setEmptyMessage("최근 검색어가 없습니다.")
            } else {
                historySerachTableView.restore() // 라벨을 숨김
            }
            
            return filteredSearchHistory.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
            let app = searchResults[indexPath.row]
            
            cell.selectionStyle = .none
            
            cell.configure(with: app)
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryCell", for: indexPath) as! SearchHistoryCell
            cell.textLabel?.text = filteredSearchHistory[indexPath.row]
            cell.searchLabel.text = filteredSearchHistory[indexPath.row]
            
            if searchBar.text != ""{
                cell.textLabel?.isHidden = true
                cell.iconImageView.isHidden = false
                cell.searchLabel.isHidden = false
            }else{
                cell.textLabel?.isHidden = false
                cell.iconImageView.isHidden = true
                cell.searchLabel.isHidden = true
            }
            
            searchHistory.append(filteredSearchHistory[indexPath.row]
)
            
            let removedDuplicate: Set = Set(searchHistory)
            
            UserDefaults.standard.set(Array(removedDuplicate), forKey: "searchHistory")
            UserDefaults.standard.synchronize()
            
            searchBar.resignFirstResponder()
            
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == historySerachTableView{
            if headerUse{
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
                headerView.backgroundColor = UIColor.white
                
                let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height))
                titleLabel.textColor = UIColor.black
                titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
                titleLabel.text = "최근 검색어"
                headerView.addSubview(titleLabel)
                
                return headerView
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == historySerachTableView{
            if headerUse{
                return 40
            }else{
                return 0
            }
        }else{
            return 0
        }
    }
    
    // MARK: - Navigation
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView{
            let app = searchResults[indexPath.row]
            performSegue(withIdentifier: "DetailSegue", sender: app)
        }else{
            let searchText = searchHistory[indexPath.row]
            
            view.isUserInteractionEnabled = false
            
            activityIndicator.startAnimating()
            
            // 앱스토어 API 호출
            searchAppStore(with: searchText) { [weak self] results in
                DispatchQueue.main.async {
                    
                    self?.searchResults = results
                    self?.mainView.isHidden = true
                    self?.tableView.isHidden = false
                    self?.view.isUserInteractionEnabled = true
                    self?.tableView.reloadData()
                    self?.activityIndicator.stopAnimating()
                }
            }
            
            topView.isHidden = true
            mainView.isHidden = true
            tableView.isHidden = false
            
            cancelBtn.isHidden = false
            
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -70).isActive = true
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            
            cancelBtn.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 0).isActive = true
            
            searchBar.text = searchText
            searchBar.resignFirstResponder()
        }
    }
    
}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        label.text = message
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.sizeToFit()
        
        self.backgroundView = label
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
