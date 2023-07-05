//
//  ViewController.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/01.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var historySerachTableView: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    let searchAppStoreAPI = SearchAppStoreAPI.shared
    
    var searchResults: [App] = []
    
    var selectedIndexPath = [IndexPath]()
    
    var searchHistory: [String] = []
    var filteredSearchHistory: [String] = []
    var activityIndicator: UIActivityIndicatorView!
    
    var headerUse : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        hideKeyboardWhenTappedAround()
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
        historySerachTableView.tableHeaderView = UIView()
        historySerachTableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        tableView.keyboardDismissMode = .onDrag
        historySerachTableView.keyboardDismissMode = .onDrag
        
        
        searchBar.searchBarStyle = .minimal
        
        searchBar.searchTextField.clearButtonMode = .always
        if let button = searchBar.searchTextField.value(forKey: "_clearButton") as? UIButton{
            button.addTarget(self, action: #selector(clearBtnClicked), for: .touchUpInside)
        }
        
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DetailSegue", let app = sender as? App {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.app = app
        }
    }
    
    
    private func mainViewCheck(){
        if mainView.isHidden{
            tableView.isHidden = true
            mainView.isHidden = false
        }
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        
        topView.isHidden = false
        
        searchBar.text = ""
        
        tableViewToTop()
        
        mainViewCheck()
        headerUse = true
        
        cancelBtn.isHidden = true
        
        view.constraints.filter { $0.firstItem === searchBar && $0.firstAttribute == .trailing }.forEach { $0.isActive = false }
        
        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        
        view.constraints.filter { $0.firstItem === searchBar && $0.firstAttribute == .top }.forEach { $0.isActive = false }
        
        searchBar.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0).isActive = true
        
        filteredSearchHistory = searchHistory
        
        historySerachTableView.reloadData()
        
    }
    
    @IBAction func clearBtnClicked(_ sender: Any) {
        
        searchBar.text = ""
        
        tableViewToTop()
        
        mainViewCheck()
        
        headerUse = true
        
        searchBar.becomeFirstResponder()
        
    }
    
    func searchHistorySet(_ searchText: String){
        searchHistory.append(searchText)
        
        searchHistory = Array(Set(searchHistory))
        
        if let index = searchHistory.firstIndex(of: searchText) {
            searchHistory.remove(at: index)
        }
        
        searchHistory.insert(searchText, at: 0)
        
        filteredSearchHistory = searchHistory
    }
    
    func tableViewToTop(){
        
        let indexPath = IndexPath(row: 0, section: 0)
        if tableView.numberOfRows(inSection: indexPath.section) > indexPath.row {
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        
    }
    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty || searchBar.text == "" {
            filteredSearchHistory = searchHistory
            headerUse = true
        } else {
            filteredSearchHistory = searchHistory.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        
        historySerachTableView.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        topView.isHidden = true
        
        mainViewCheck()
        
        cancelBtn.isHidden = false
        
        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60).isActive = true
        
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        
        cancelBtn.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -8).isActive = true
        
        headerUse = false
        historySerachTableView.tableHeaderView = nil
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        
        view.isUserInteractionEnabled = false
        
        activityIndicator.startAnimating()
        
        tableViewToTop()
        
        // 앱스토어 API 호출
        searchAppStoreAPI.searchAppStore(with: searchText) { [weak self] results in
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
        
        searchHistorySet(searchText)
        
//        searchHistory.append(searchText)
//
//        searchHistory = Array(Set(searchHistory))
//
//        if let index = searchHistory.firstIndex(of: searchText) {
//            searchHistory.remove(at: index)
//        }
//
//        searchHistory.insert(searchText, at: 0)
//
//        filteredSearchHistory = searchHistory
        
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
                historySerachTableView.setEmptyMessage("최근 검색어가 없습니다.")
                
                headerUse = false
                
            } else {
                historySerachTableView.restore()
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
            
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == historySerachTableView{
            if headerUse{
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
                headerView.backgroundColor = UIColor.white
                
                let titleLabel = UILabel(frame: CGRect(x: 16, y: -10, width: headerView.frame.width - 16, height: headerView.frame.height))
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
            
            searchHistorySet(searchText)
            
            view.isUserInteractionEnabled = false
            
            activityIndicator.startAnimating()
            
            // 앱스토어 API 호출
            searchAppStoreAPI.searchAppStore(with: searchText) { [weak self] results in
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
            
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60).isActive = true
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            
            cancelBtn.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -8).isActive = true
            
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



