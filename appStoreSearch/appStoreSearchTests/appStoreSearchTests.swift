//
//  appStoreSearchTests.swift
//  appStoreSearchTests
//
//  Created by 박병훈 on 2023/07/05.
//
import XCTest
@testable import appStoreSearch

final class appStoreSearchTests: XCTestCase {
    
    var viewController : ViewController!
    var detailViewController : DetailViewController!
    let searchAppStoreAPI = SearchAppStoreAPI.shared
    
    override func setUpWithError() throws {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        
        viewController.loadViewIfNeeded()
        
        detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        
        let app = App(name: "Test App",
                      rating: 4.5,
                      userRatingCount: 100,
                      iconImage: UIImage(systemName: "testtube.2")!,
                      screenshotImage: UIImage(systemName: "testtube.2")!,
                      screenshotImageUrls: ["https://is5-ssl.mzstatic.com/image/thumb/PurpleSource126/v4/ba/bd/56/babd56b3-f364-3e46-3cc2-d89e60fa7034/69c855e1-ed42-434b-95ea-197709f7eb82_ios_5.5_01.png/392x696bb.png",
                                            "https://is4-ssl.mzstatic.com/image/thumb/PurpleSource116/v4/80/11/81/801181f0-c238-7274-9603-514dfaf22ee4/23cd5522-2d10-468d-9fcc-d0b5f6e2bf69_ios_5.5_02.png/392x696bb.png"],
                      releaseNotes: "Release notes for Test App\nRelease notes for Test App\nRelease notes for Test App\nRelease notes for Test App\nRelease notes for Test App\n",
                      description: "This is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\n")
        
        detailViewController.app = app
        
        detailViewController.loadViewIfNeeded()
        
        
    }
    
    override func tearDown() {
        viewController = nil
        
        detailViewController = nil
        super.tearDown()
    }
    
    
    func testSearchAppStore() throws {
        let expectation = XCTestExpectation(description: "Search App Store")
        
        searchAppStoreAPI.searchAppStore(with: "카카오") { apps in
            XCTAssertFalse(apps.isEmpty, "Search results should not be empty")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testSearchBarTextDidChange() throws {
        viewController.searchHistory = ["카카오"]
        let searchText = "카카오"
        
        viewController.searchBar(UISearchBar(), textDidChange: searchText)
        
        XCTAssertEqual(viewController.filteredSearchHistory, ["카카오"], "Filtered search history should contain the search text")
        
    }
    
    func testSearchBarCancelButtonClicked() throws {
        viewController.searchBar.text = "avbx"
        viewController.cancelBtn.sendActions(for: .touchUpInside)
        
        XCTAssertFalse(viewController.topView.isHidden, "Top view should be hidden")
        XCTAssertEqual(viewController.searchBar.text, "", "Search bar text should be empty")
        XCTAssertFalse(viewController.mainView.isHidden, "Main view should be hidden")
        XCTAssertTrue(viewController.headerUse, "Header use should be true")
        XCTAssertTrue(viewController.cancelBtn.isHidden, "Cancel button should be hidden")
        
        XCTAssertEqual(viewController.filteredSearchHistory, viewController.searchHistory, "Filtered search history should be equal to search history")
    }
    
    func testHistoryTableViewNumberOfRowsInSection() throws {
        
        let tableView = viewController.historySerachTableView
        
        let numberOfRows = viewController.filteredSearchHistory.count
        XCTAssertEqual(tableView!.numberOfRows(inSection: 0), numberOfRows, "Number of rows should be equal to the count of filtered search history")
    }
    
    func testHistoryTableViewCellForRowAt() throws {
        
        let tableView = viewController.historySerachTableView
        
        viewController.filteredSearchHistory = ["game", "app"]
        tableView!.reloadData()
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView!.cellForRow(at: indexPath) as? SearchHistoryCell
        XCTAssertEqual(cell?.textLabel?.text, "game", "Cell text label should be equal to the filtered search history item")
    }
    
    func testHistoryTableViewHeightForHeaderInSection() throws {
        
        let tableView = viewController.historySerachTableView
        
        tableView!.sectionHeaderHeight = 40
        
        let sectionHeaderHeight = viewController.tableView(tableView!, heightForHeaderInSection: 0)
        XCTAssertEqual(sectionHeaderHeight, tableView!.sectionHeaderHeight, "Section header height should be equal to the custom height")
    }
    
    func testHistoryTableViewDidSelectRowAt() throws {
        let tableView = viewController.historySerachTableView
        viewController.searchHistory = ["카카오", "다음"]
        tableView!.reloadData()
        
        let indexPath = IndexPath(row: 0, section: 0)
        viewController.tableView(tableView!, didSelectRowAt: indexPath)
        
        XCTAssertEqual(viewController.searchBar.text, "카카오", "Search bar text should be equal to the selected search history item")
    }
    
    func testTableViewHasCells() {
        
        searchAppStoreAPI.searchAppStore(with: "카카오") { [self] apps in
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath)
            
            XCTAssertNotNil(cell)
            XCTAssertTrue(cell is SearchResultCell)
        }
    }
    
    func testTableViewSelection() {
        
        searchAppStoreAPI.searchAppStore(with: "카카오") { [self] apps in
            let indexPath = IndexPath(row: 0, section: 0)
            
            // Simulate a cell selection
            viewController.tableView.delegate?.tableView?(viewController.tableView, didSelectRowAt: indexPath)
            
            XCTAssertNotNil(detailViewController)
            XCTAssertTrue(detailViewController != nil)
        }
        
    }
    
    func testUIElements() {
        let textNote = detailViewController.truncatedText(detailViewController.app.releaseNotes, maxLines: 3)
        let textDescription = detailViewController.truncatedText(detailViewController.app.description, maxLines: 3)
        
        XCTAssertNotNil(detailViewController.appIconImageView.image)
        XCTAssertEqual(detailViewController.titleLabel.text, "Test App")
        XCTAssertEqual(detailViewController.ratingView.rating, 4.5)
        XCTAssertEqual(detailViewController.noteLabel.text, textNote)
        XCTAssertEqual(detailViewController.descriptionLabel.text, textDescription)
        
        XCTAssertEqual(detailViewController.noteMoreBtn.isHidden, false)
        XCTAssertEqual(detailViewController.descriptionMoreBtn.isHidden, false)
    }
    
    func testTruncatedText() {
        let longText = "This is a long description\n that needs to be truncated."
        let truncatedText = detailViewController.truncatedText(longText, maxLines: 1)
        
        XCTAssertEqual(truncatedText, "This is a long description")
    }
    
    func testNoteMoreBtnClicked() {
        let textNote = detailViewController.truncatedText(detailViewController.app.releaseNotes, maxLines: 3)
        
        XCTAssertEqual(detailViewController.noteLabel.text, textNote)
        
        // noteMoreBtn을 클릭
        detailViewController.noteMoreBtn.sendActions(for: .touchUpInside)
        
        // noteLabel의 텍스트가 전체 내용으로 변경되었는지 확인
        XCTAssertEqual(detailViewController.noteLabel.text, detailViewController.app.releaseNotes)
        // noteMoreBtn이 숨겨져 있는지 확인
        XCTAssertTrue(detailViewController.noteMoreBtn.isHidden)
    }
    
    func testDescriptionMoreBtnClicked() {
        let textDescription = detailViewController.truncatedText(detailViewController.app.description, maxLines: 3)
        
        XCTAssertEqual(detailViewController.descriptionLabel.text, textDescription)
        
        // noteMoreBtn을 클릭
        detailViewController.descriptionMoreBtn.sendActions(for: .touchUpInside)
        
        // noteLabel의 텍스트가 전체 내용으로 변경되었는지 확인
        XCTAssertEqual(detailViewController.descriptionLabel.text, detailViewController.app.description)
        // noteMoreBtn이 숨겨져 있는지 확인
        XCTAssertTrue(detailViewController.descriptionMoreBtn.isHidden)
    }
    
    
}
