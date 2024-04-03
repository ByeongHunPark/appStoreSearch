//
//  ViewController.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/01.
//

import UIKit

class ViewController: UIViewController{
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var historySearchTableView: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var tabbar: UITabBar!
        
    let searchAppStoreAPI = SearchAppStoreAPI.shared
    
    var searchResults: [App] = []
    
    var searchHistory: [String] = []
    var filteredSearchHistory: [String] = []
    var activityIndicator: UIActivityIndicatorView!
    
    var headerUse : Bool = true
    
    var offset : Int = 0
    
    var addSearch : Bool = true
    
    let overlayView = UIView(frame: UIScreen.main.bounds)
    
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
        
        historySearchTableView.delegate = self
        historySearchTableView.dataSource = self
        historySearchTableView.tableHeaderView = UIView()
        historySearchTableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        tableView.keyboardDismissMode = .onDrag
        historySearchTableView.keyboardDismissMode = .onDrag
        
        tabbar.selectedItem = tabbar.items?[4]
        
        searchBar.searchBarStyle = .minimal
        
        searchBar.searchTextField.clearButtonMode = .always
        if let button = searchBar.searchTextField.value(forKey: "_clearButton") as? UIButton{
            button.addTarget(self, action: #selector(clearBtnClicked), for: .touchUpInside)
        }
        
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        
        view.addSubview(activityIndicator)
    }
    
    func fetchSearchResults(for searchText: String) {
        // API 호출을 시작하기 전에 필요한 UI 업데이트를 수행할 수 있습니다.
        
        // 백그라운드에서 API를 호출합니다.
        DispatchQueue.global().async {
            // API 호출 및 결과를 받아오는 로직을 구현합니다.
            self.searchAppStoreAPI.searchAppStore(with: searchText, offset: self.offset) { [weak self] results in
                // API 호출이 완료되면 메인 스레드에서 UI를 업데이트합니다.
                DispatchQueue.main.async {
                    self?.searchResults = results
                    self?.tableView.reloadData()
                }
            }
        }
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
        
        offset = 0
        
        tableViewToTop()
        
        mainViewCheck()
        headerUse = true
        
        cancelBtn.isHidden = true
        
        view.constraints.filter { $0.firstItem === searchBar && $0.firstAttribute == .trailing }.forEach { $0.isActive = false }
        
        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        
        view.constraints.filter { $0.firstItem === searchBar && $0.firstAttribute == .top }.forEach { $0.isActive = false }
        
        searchBar.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0).isActive = true
        
        filteredSearchHistory = searchHistory
        
        historySearchTableView.reloadData()
        
    }
    
    @IBAction func clearBtnClicked(_ sender: Any) {
        
        searchBar.text = ""
        
        offset = 0
        
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
        
        UserDefaults.standard.set(Array(searchHistory), forKey: "searchHistory")
        UserDefaults.standard.synchronize()
        
        filteredSearchHistory = searchHistory
        
        historySearchTableView.reloadData()
    }
    
    func tableViewToTop(){
        
        let indexPath = IndexPath(row: 0, section: 0)
        if tableView.numberOfRows(inSection: indexPath.section) > indexPath.row {
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        
    }
    
    func indicatorStart(_ start:Bool){
        if start{
            view.addSubview(overlayView)
            activityIndicator.startAnimating()
        }else{
            overlayView.removeFromSuperview()
            activityIndicator.stopAnimating()
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
            
            headerUse = false
            historySearchTableView.tableHeaderView = nil
        }
        
//        self.fetchSearchResults(for: searchText)
        
        historySearchTableView.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        topView.isHidden = true
        
        mainViewCheck()
        
        cancelBtn.isHidden = false
        
        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60).isActive = true
        
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        
        cancelBtn.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -8).isActive = true
        
        headerUse = false
        
        if searchBar.text != "" {
            filteredSearchHistory = searchHistory.filter { $0.lowercased().contains(searchBar.text!.lowercased()) }
        }
        
        historySearchTableView.tableHeaderView = nil
        historySearchTableView.reloadData()
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        
        if searchText != ""{
            view.isUserInteractionEnabled = false
            
            indicatorStart(true)
            
            tableViewToTop()
            
            // 앱스토어 API 호출
            searchAppStoreAPI.searchAppStore(with: searchText, offset: offset) { [weak self] results in
                DispatchQueue.main.async {
                    self?.searchResults = results
                    self?.tableView.isHidden = false
                    self?.view.isUserInteractionEnabled = true
                    self?.tableView.reloadData()
                    self?.indicatorStart(false)
                }
            }
            
            mainView.isHidden = true
            
            searchHistorySet(searchText)
            
            searchBar.resignFirstResponder()
        }else{
            let alertController = UIAlertController(title: "검색어가 없습니다.", message: "검색어를 입력해주세요.", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "확인", style: .default) { (action) in
                alertController.dismiss(animated: true)
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true)
        }
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate, SearchResultCellDelegate {
    // MARK: - UITableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView{
            return searchResults.count
        }else{
            
            if searchHistory.count == 0 {
                historySearchTableView.setEmptyMessage("최근 검색어가 없습니다.")
                
                headerUse = false
                
            } else {
                historySearchTableView.restore()
            }
            
            return filteredSearchHistory.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
                      
            let app = searchResults[indexPath.row]
            
            cell.selectionStyle = .none
            
            cell.delegate = self
            
            cell.configure(with: app)
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryCell", for: indexPath) as! SearchHistoryCell
            cell.textLabel?.text = filteredSearchHistory[indexPath.row]
            cell.searchLabel.text = filteredSearchHistory[indexPath.row]
            
            if headerUse{
                cell.textLabel?.isHidden = false
                cell.iconImageView.isHidden = true
                cell.searchLabel.isHidden = true
            }else{
                cell.textLabel?.isHidden = true
                cell.iconImageView.isHidden = false
                cell.searchLabel.isHidden = false
            }
            
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == historySearchTableView{
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
        if tableView == historySearchTableView{
            if headerUse{
                return 40
            }else{
                return 0
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView{
            
            let app = searchResults[indexPath.row]
            performSegue(withIdentifier: "DetailSegue", sender: app)
            
        }else{
            
            let searchText = self.searchBar.text != "" ? filteredSearchHistory[indexPath.row] : searchHistory[indexPath.row]
            
            searchHistorySet(searchText)
            
            view.isUserInteractionEnabled = false
            
            indicatorStart(true)
            
            // 앱스토어 API 호출
            searchAppStoreAPI.searchAppStore(with: searchText, offset: 0) { [weak self] results in
                DispatchQueue.main.async {
                    
                    self?.searchResults = results
                    self?.headerUse = false
                    self?.tableView.isHidden = false
                    self?.view.isUserInteractionEnabled = true
                    self?.tableView.reloadData()
                    self?.indicatorStart(false)
                }
            }
            
            topView.isHidden = true
            mainView.isHidden = true
            
            cancelBtn.isHidden = false
            
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -60).isActive = true
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            
            cancelBtn.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -8).isActive = true
            
            searchBar.text = searchText
            searchBar.resignFirstResponder()
        }
    }
    
    func searchResultCell(_ cell: SearchResultCell, didSelectItemAt indexPath: IndexPath) {
        let tableViewIndexPath = tableView.indexPath(for: cell)
        
        let app = searchResults[tableViewIndexPath!.row]
        performSegue(withIdentifier: "DetailSegue", sender: app)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.tableView.isHidden{
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let screenHeight = scrollView.frame.height
            
            if offsetY > contentHeight - screenHeight && addSearch{
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        addSearch = false
        view.isUserInteractionEnabled = false
        offset = offset + 5
        
        guard let searchText = searchBar.text else { return }
        
        indicatorStart(true)
        
        searchAppStoreAPI.addSearch(with: searchText, offset: offset, app: searchResults) { [weak self] results in
            DispatchQueue.main.async {
                self?.searchResults = results
                self?.topView.isHidden = true
                self?.mainView.isHidden = true
                self?.tableView.isHidden = false
                self?.view.isUserInteractionEnabled = true
                self?.tableView.reloadData()
                self?.addSearch = true
                self?.indicatorStart(false)
            }
        }
        
        
    }
    
}
