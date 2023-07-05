//
//  appStoreSearchTests.swift
//  appStoreSearchTests
//
//  Created by 박병훈 on 2023/07/05.
//
import XCTest
@testable import appStoreSearch

class DetailViewControllerTests: XCTestCase {
    
    var detailViewController: DetailViewController!
    
    override func setUp() {
        super.setUp()
        
        // DetailViewController 인스턴스 생성
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
        
        // 테스트용 App 객체 생성
        let app = App(name: "Test App",
                      rating: 4.5,
                      userRatingCount: 100,
                      iconImage: UIImage(systemName: "testtube.2")!,
                      screenshotImage: UIImage(systemName: "testtube.2")!,
                      screenshotImageUrls: ["https://is5-ssl.mzstatic.com/image/thumb/PurpleSource126/v4/ba/bd/56/babd56b3-f364-3e46-3cc2-d89e60fa7034/69c855e1-ed42-434b-95ea-197709f7eb82_ios_5.5_01.png/392x696bb.png",
                            "https://is4-ssl.mzstatic.com/image/thumb/PurpleSource116/v4/80/11/81/801181f0-c238-7274-9603-514dfaf22ee4/23cd5522-2d10-468d-9fcc-d0b5f6e2bf69_ios_5.5_02.png/392x696bb.png"],
                      releaseNotes: "Release notes for Test App\nRelease notes for Test App\nRelease notes for Test App\nRelease notes for Test App\nRelease notes for Test App\n",
                      description: "This is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\n")
        
        // DetailViewController에 App 객체 할당
        detailViewController.app = app
        
        // DetailViewController의 뷰를 로드
        detailViewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        detailViewController = nil
        
        super.tearDown()
    }
    
    func testUIElements() {
        // UI 요소들이 올바로 설정되었는지 확인
        XCTAssertNotNil(detailViewController.appIconImageView.image)
        XCTAssertEqual(detailViewController.titleLabel.text, "Test App")
        XCTAssertEqual(detailViewController.ratingView.rating, 4.5)
        XCTAssertEqual(detailViewController.noteLabel.text, "Release notes for Test App\nRelease notes for Test App\nRelease notes for Test App\nRelease notes for Test App\nRelease notes for Test App\n")
        XCTAssertEqual(detailViewController.descriptionLabel.text, "This is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\n")
        
        XCTAssertEqual(detailViewController.noteMoreBtn.isHidden, false)
        XCTAssertEqual(detailViewController.descriptionMoreBtn.isHidden, false)
    }
    
    func testTruncatedText() {
        let longText = "This is a long description\n that needs to be truncated."
        let truncatedText = detailViewController.truncatedText(longText, maxLines: 1)
        
        XCTAssertEqual(truncatedText, "This is a long description")
    }
    
    func testNoteMoreBtnClicked() {
        let longText = "Release notes for Test App\nRelease notes for Test App\nRelease notes for Test App\nRelease notes for Test App\nRelease notes for Test App\n"
        
        XCTAssertEqual(detailViewController.noteLabel.text, detailViewController.truncatedText(longText, maxLines: 3))
        
        // noteMoreBtn을 클릭
        detailViewController.noteMoreBtn.sendActions(for: .touchUpInside)
        
        // noteLabel의 텍스트가 전체 내용으로 변경되었는지 확인
        XCTAssertEqual(detailViewController.noteLabel.text, longText)
        // noteMoreBtn이 숨겨져 있는지 확인
        XCTAssertTrue(detailViewController.noteMoreBtn.isHidden)
    }
    
    func testDescriptionMoreBtnClicked() {
        let longText = "This is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\nThis is a test app.\n"
        
        XCTAssertEqual(detailViewController.descriptionLabel.text, detailViewController.truncatedText(longText, maxLines: 3))
        
        // noteMoreBtn을 클릭
        detailViewController.descriptionMoreBtn.sendActions(for: .touchUpInside)
        
        // noteLabel의 텍스트가 전체 내용으로 변경되었는지 확인
        XCTAssertEqual(detailViewController.descriptionLabel.text, longText)
        // noteMoreBtn이 숨겨져 있는지 확인
        XCTAssertTrue(detailViewController.descriptionMoreBtn.isHidden)
    }
    
}
