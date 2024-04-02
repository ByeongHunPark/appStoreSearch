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
                      description: "This is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\n",
                      genre: "software",
                      trackContentRating: "4+"
        )
        
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
        
        searchAppStoreAPI.searchAppStore(with: "", offset: 0) { apps in
            XCTAssertTrue(apps.isEmpty, "검색어 없는 검색결과 오류")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testSearchBarTextDidChange() throws {
        viewController.searchHistory = ["카카오"]
        let searchText = "카카오"
        
        viewController.searchBar(UISearchBar(), textDidChange: searchText)
        
        XCTAssertEqual(viewController.filteredSearchHistory, ["카카오"], "필터링 오류")
        
    }
    
    func testSearchBarCancelButtonClicked() throws {
        viewController.searchBar.text = "avbx"
        viewController.cancelBtn.sendActions(for: .touchUpInside)
        
        XCTAssertFalse(viewController.topView.isHidden, "topView가 hidden처리 됌.")
        XCTAssertEqual(viewController.searchBar.text, "", "searchBar text가 비워지지 않음.")
        XCTAssertFalse(viewController.mainView.isHidden, "mainview가 hidden처리 됌.")
        XCTAssertTrue(viewController.headerUse, "Header가 hidden처리 됌.")
        XCTAssertTrue(viewController.cancelBtn.isHidden, "cancelBtn이 hidden처리 됌.")
        
        XCTAssertEqual(viewController.filteredSearchHistory, viewController.searchHistory, "검색기록 목록과 필터링 목록이 다름.")
    }
    
    func testHistoryTableViewNumberOfRowsInSection() throws {
        
        let tableView = viewController.historySearchTableView
        
        let numberOfRows = viewController.filteredSearchHistory.count
        XCTAssertEqual(tableView!.numberOfRows(inSection: 0), numberOfRows, "필터링 목록과 tableView의 row가 다름")
    }
    
    func testHistoryTableViewCellForRowAt() throws {
        
        let tableView = viewController.historySearchTableView
        
        viewController.filteredSearchHistory = ["카카오", "다음"]
        tableView!.reloadData()
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView!.cellForRow(at: indexPath) as? SearchHistoryCell
        XCTAssertEqual(cell?.textLabel?.text, "카카오", "cell의 textLabel과 필터링 항목이 다름")
    }
    
    func testHistoryTableViewHeightForHeaderInSection() throws {
        
        let tableView = viewController.historySearchTableView
        
        tableView!.sectionHeaderHeight = 40
        
        let sectionHeaderHeight = viewController.tableView(tableView!, heightForHeaderInSection: 0)
        XCTAssertEqual(sectionHeaderHeight, tableView!.sectionHeaderHeight, "header의 높이가 설정과 다름.")
    }
    
    func testHistoryTableViewDidSelectRowAt() throws {
        let tableView = viewController.historySearchTableView
        viewController.searchHistory = ["다음", "카카오"]
        tableView!.reloadData()
        
        let indexPath = IndexPath(row: 0, section: 0)
        viewController.tableView(tableView!, didSelectRowAt: indexPath)
        
        XCTAssertEqual(viewController.searchBar.text, "다음", "searchBar.textd와 선택한 기록이 다름")
    }
    
    func testTableViewHasCells() {
        
        searchAppStoreAPI.searchAppStore(with: "카카오", offset: 0) { [self] apps in
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = viewController.tableView(viewController.tableView, cellForRowAt: indexPath)
            
            XCTAssertNotNil(cell, "cell이 존재하지 않음")
            XCTAssertTrue(cell is SearchResultCell, "cell이 SearchResultCell 타입이 아님.")
        }
    }
    
    func testTableViewSelection() {
        
        searchAppStoreAPI.searchAppStore(with: "카카오", offset: 0) { [self] apps in
            let indexPath = IndexPath(row: 0, section: 0)
            
            viewController.tableView.delegate?.tableView?(viewController.tableView, didSelectRowAt: indexPath)
            
            XCTAssertNotNil(detailViewController, "detailViewController가 존재하지 않음")
        }
        
    }
    
    func testUIElements() {
        
        let textNote = detailViewController.truncatedText(detailViewController.app.releaseNotes, maxLines: 3)
        let textDescription = detailViewController.truncatedText(detailViewController.app.description, maxLines: 3)
        
        XCTAssertNotNil(detailViewController.appIconImageView.image, "detailViewController.appIconImageView.image가 존재하지 않음")
        XCTAssertEqual(detailViewController.titleLabel.text, detailViewController.app.name, "detailViewController.titleLabel.text가 정보와 다름")
        XCTAssertEqual(detailViewController.ratingView.rating, detailViewController.app.rating, "detailViewController.ratingView.rating이 정보와 다름")
        XCTAssertEqual(detailViewController.noteLabel.text, textNote, "detailViewController.noteLabel.text가 정보와 다름")
        XCTAssertEqual(detailViewController.descriptionLabel.text, textDescription, "detailViewController.descriptionLabel.text가 정보와 다름")
        
        XCTAssertEqual(detailViewController.noteMoreBtn.isHidden, false, "detailViewController.noteMoreBtn이 hidden처리 됌")
        XCTAssertEqual(detailViewController.descriptionMoreBtn.isHidden, false, "detailViewController.descriptionMoreBtn이 hidden처리 됌")
    }
    
    func testTruncatedText() {
        let longText = "This is a long description\n that needs to be truncated."
        let truncatedText = detailViewController.truncatedText(longText, maxLines: 1)
        
        XCTAssertEqual(truncatedText, "This is a long description", "truncatedText 오류")
    }
    
    func testNoteMoreBtnClicked() {
        let textNote = detailViewController.truncatedText(detailViewController.app.releaseNotes, maxLines: 3)
        
        XCTAssertEqual(detailViewController.noteLabel.text, textNote, "detailViewController.noteLabel.text가 설정과 다름")
        
        // noteMoreBtn을 클릭
        detailViewController.noteMoreBtn.sendActions(for: .touchUpInside)
        
        // noteLabel의 텍스트가 전체 내용으로 변경되었는지 확인
        XCTAssertEqual(detailViewController.noteLabel.text, detailViewController.app.releaseNotes, "detailViewController.noteMoreBtn이 작동하지 않음")
        // noteMoreBtn이 숨겨져 있는지 확인
        XCTAssertTrue(detailViewController.noteMoreBtn.isHidden, "detailViewController.noteMoreBtn이 hidden처리 안됌")
    }
    
    func testDescriptionMoreBtnClicked() {
        let textDescription = detailViewController.truncatedText(detailViewController.app.description, maxLines: 3)
        
        XCTAssertEqual(detailViewController.descriptionLabel.text, textDescription, "detailViewController.descriptionLabel.text가 설정과 다름")
        
        // noteMoreBtn을 클릭
        detailViewController.descriptionMoreBtn.sendActions(for: .touchUpInside)
        
        // noteLabel의 텍스트가 전체 내용으로 변경되었는지 확인
        XCTAssertEqual(detailViewController.descriptionLabel.text, detailViewController.app.description, "detailViewController.descriptionMoreBtn이 작동하지 않음")
        // noteMoreBtn이 숨겨져 있는지 확인
        XCTAssertTrue(detailViewController.descriptionMoreBtn.isHidden, "detailViewController.descriptionMoreBtn이 hidden처리 안됌")
    }
    
    
}
