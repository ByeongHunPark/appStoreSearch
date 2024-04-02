//
//  searchAppStoreAPI.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/05.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class SearchAppStoreAPI: ObservableObject{
    
    static let shared = SearchAppStoreAPI()
    
    private init(){
        
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        AF.request(url).responseData { response in
            guard let data = response.data else {
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        }
    }
    
    func searchAppStore(with term: String, offset: Int,completion: @escaping ([App]) -> Void) {
        print("searchAppStore")
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion([])
            return
        }
        
        let countryCode = "kr"
        
        let urlString = "https://itunes.apple.com/search?term=\(encodedTerm)&country=\(countryCode)&media=software&limit=5&offset=\(offset)"
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        AF.request(url, method: .post)
            .validate()
            .responseData { response in
                switch response.result{
                case .success(let data):
                    print("Success")
                    do{
                        let json = try JSON(data: data)
                        
                        guard let results = json["results"].arrayObject as? [[String: Any]] else {
                            completion([])
                            return
                        }
                        
                        print(json)
                        
                        var apps = [App]()
                        
                        let group = DispatchGroup()
                        let queue = DispatchQueue(label: "imageDownloadQueue", attributes: .concurrent)
                        
                        for result in results {
                            if let name = result["trackName"] as? String,
                               let rating = result["averageUserRating"] as? Double,
                               let userRatingCount = result["userRatingCount"] as? Int,
                               let iconUrlString = result["artworkUrl100"] as? String,
                               let screenshotUrls = result["screenshotUrls"] as? [String],
                               let iconUrl = URL(string: iconUrlString),
                               let description = result["description"] as? String,
                               let releaseNotes = result["releaseNotes"] as? String,
                               let screenshotUrlString = screenshotUrls.first,
                               let screenshotUrl = URL(string: screenshotUrlString),
                               let genres = result["genres"] as? [String],
                               let genre = genres.first,
                               let trackContentRating = result["trackContentRating"] as? String
                            {
                                group.enter()
                                
                                queue.async(group: group) {
                                    self.downloadImage(from: iconUrl) { iconImage in
                                        self.downloadImage(from: screenshotUrl) { screenshotImage in
                                            if let iconImage = iconImage, let screenshotImage = screenshotImage {
                                                let app = App(name: name,
                                                              rating: rating,
                                                              userRatingCount: userRatingCount,
                                                              iconImage: iconImage,
                                                              screenshotImage: screenshotImage,
                                                              screenshotImageUrls: screenshotUrls,
                                                              releaseNotes: releaseNotes,
                                                              description: description,
                                                              genre: genre,
                                                              trackContentRating: trackContentRating
                                                              
                                                )
                                                
                                                DispatchQueue.main.async(flags: .barrier) {
                                                    objc_sync_enter(apps)
                                                    apps.append(app)
                                                    objc_sync_exit(apps)
                                                }
                                            }
                                            group.leave()
                                        }
                                    }
                                }
                            }
                        }
                        
                        group.notify(queue: .main) {
                            let sortedApps = results.compactMap { result -> App? in
                                guard let name = result["trackName"] as? String else {
                                    return nil
                                }
                                return apps.first { $0.name == name }
                            }
                            
                            completion(sortedApps)
                        }
                        
                    }catch {
                        print("Error: \(error)")
                        completion([])
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    completion([])
                }
            }
        
    }
    
    func addSearch(with term: String, offset: Int, app: [App] ,completion: @escaping ([App]) -> Void) {
        print("addSearch")
        var removeDuplicate : [App] = []
        var uniqueNames: Set<String> = []
        
        var oldApp = app
        
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion([])
            return
        }
        
        let countryCode = "kr"
        
        let urlString = "https://itunes.apple.com/search?term=\(encodedTerm)&country=\(countryCode)&entity=software&limit=5&offset=\(offset)"
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        AF.request(url, method: .post)
            .validate()
            .responseData { response in
                switch response.result{
                case .success(let data):
                    print("Success")
                    do{
                        let json = try JSON(data: data)
                        
                        guard let results = json["results"].arrayObject as? [[String: Any]] else {
                            completion([])
                            return
                        }
                        
                        var apps = app
                        
                        let group = DispatchGroup()
                        let queue = DispatchQueue(label: "imageDownloadQueue", attributes: .concurrent)
                        
                        for result in results {
                            if let name = result["trackName"] as? String,
                               let rating = result["averageUserRating"] as? Double,
                               let userRatingCount = result["userRatingCount"] as? Int,
                               let iconUrlString = result["artworkUrl100"] as? String,
                               let screenshotUrls = result["screenshotUrls"] as? [String],
                               let iconUrl = URL(string: iconUrlString),
                               let description = result["description"] as? String,
                               let releaseNotes = result["releaseNotes"] as? String,
                               let screenshotUrlString = screenshotUrls.first,
                               let screenshotUrl = URL(string: screenshotUrlString),
                               let genres = result["genres"] as? [String],
                               let genre = genres.first,
                               let trackContentRating = result["trackContentRating"] as? String
                            {
                                
                                group.enter()
                                
                                queue.async(group: group) {
                                    self.downloadImage(from: iconUrl) { iconImage in
                                        self.downloadImage(from: screenshotUrl) { screenshotImage in
                                            if let iconImage = iconImage, let screenshotImage = screenshotImage {
                                                let app = App(name: name,
                                                              rating: rating,
                                                              userRatingCount: userRatingCount,
                                                              iconImage: iconImage,
                                                              screenshotImage: screenshotImage,
                                                              screenshotImageUrls: screenshotUrls,
                                                              releaseNotes: releaseNotes,
                                                              description: description,
                                                              genre: genre,
                                                              trackContentRating: trackContentRating)
                                                
                                                DispatchQueue.main.async(flags: .barrier) {
                                                    objc_sync_enter(apps)
                                                    apps.append(app)
                                                    objc_sync_exit(apps)
                                                }
                                            }
                                            group.leave()
                                        }
                                    }
                                }
                            }
                        }
                        
                        group.notify(queue: .main) {
                            let sortedApps = results.compactMap { result -> App? in
                                guard let name = result["trackName"] as? String else {
                                    return nil
                                }
                                return apps.first { $0.name == name }
                            }
                            
                            oldApp.append(contentsOf: sortedApps)

                            for app in oldApp {
                                if !uniqueNames.contains(app.name) {
                                    removeDuplicate.append(app)
                                    uniqueNames.insert(app.name)
                                }
                            }
                            
                            completion(removeDuplicate)
                        }
                        
                    }catch {
                        print("Error: \(error)")
                        completion([])
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    completion([])
                }
            }
    }
}

/* MARK: API Json
 
 {
   "results" : [
     {
       "price" : 0,
       "isGameCenterEnabled" : false,
       "primaryGenreName" : "Social Networking",
       "formattedPrice" : "무료",
       "currentVersionReleaseDate" : "2024-03-28T00:44:35Z",
       "trackViewUrl" : "https:\/\/apps.apple.com\/kr\/app\/%EC%B9%B4%EC%B9%B4%EC%98%A4%ED%86%A1\/id362057947?uo=4",
       "trackCensoredName" : "카카오톡",
       "artistViewUrl" : "https:\/\/apps.apple.com\/kr\/developer\/kakao-corp\/id362057950?uo=4",
       "ipadScreenshotUrls" : [
         "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/PurpleSource122\/v4\/59\/8d\/97\/598d97ae-9cb4-62df-a286-8b9c7f017c8c\/f40b6197-5836-4def-a28f-767c3a4ccf00_Kakaotalk_iPad_SC_KR_01.jpg\/552x414bb.jpg",
         "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/PurpleSource122\/v4\/55\/23\/af\/5523afa6-c182-c7b1-dce3-af389873bc5a\/45b12d72-8056-4bf3-b0e2-a073293cedb3_Kakaotalk_iPad_SC_KR_02.jpg\/576x768bb.jpg",
         "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/PurpleSource122\/v4\/cc\/71\/0a\/cc710a43-f0e3-f864-4576-077e24ef36c9\/bf04e113-634e-4600-9269-9cd34624d4c6_Kakaotalk_iPad_SC_KR_03.jpg\/576x768bb.jpg",
         "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/PurpleSource112\/v4\/9f\/95\/b3\/9f95b3d9-5916-c59c-f022-3ec5055c8758\/7ec17922-631d-4292-a7c2-730998509973_Kakaotalk_iPad_SC_KR_05.jpg\/576x768bb.jpg",
         "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/PurpleSource112\/v4\/15\/12\/9a\/15129a6e-3a6d-dbc8-8431-c300600bfdf3\/c737ee50-6597-46fb-8342-7706cb5f4084_Kakaotalk_iPad_SC_KR_04.jpg\/576x768bb.jpg"
       ],
       "bundleId" : "com.iwilab.KakaoTalk",
       "artworkUrl512" : "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/Purple211\/v4\/ea\/e7\/8c\/eae78c65-802f-5f81-ce19-49698cce2ec5\/AppIcon-0-0-1x_U007emarketing-0-0-0-10-0-0-sRGB-85-220.png\/512x512bb.jpg",
       "averageUserRatingForCurrentVersion" : 2.98462000000000005073275133327115327119,
       "advisories" : [

       ],
       "genreIds" : [
         "6005",
         "6007"
       ],
       "trackName" : "카카오톡",
       "languageCodesISO2A" : [
         "EN",
         "FR",
         "DE",
         "ID",
         "IT",
         "JA",
         "KO",
         "PT",
         "RU",
         "ZH",
         "ES",
         "TH",
         "ZH",
         "TR",
         "VI"
       ],
       "trackId" : 362057947,
       "contentAdvisoryRating" : "4+",
       "features" : [
         "iosUniversal"
       ],
       "primaryGenreId" : 6005,
       "currency" : "KRW",
       "userRatingCount" : 136080,
       "trackContentRating" : "4+",
       "minimumOsVersion" : "15.0",
       "supportedDevices" : [
         "iPhone5s-iPhone5s",
         "iPadAir-iPadAir",
         "iPadAirCellular-iPadAirCellular",
         "iPadMiniRetina-iPadMiniRetina",
         "iPadMiniRetinaCellular-iPadMiniRetinaCellular",
         "iPhone6-iPhone6",
         "iPhone6Plus-iPhone6Plus",
         "iPadAir2-iPadAir2",
         "iPadAir2Cellular-iPadAir2Cellular",
         "iPadMini3-iPadMini3",
         "iPadMini3Cellular-iPadMini3Cellular",
         "iPodTouchSixthGen-iPodTouchSixthGen",
         "iPhone6s-iPhone6s",
         "iPhone6sPlus-iPhone6sPlus",
         "iPadMini4-iPadMini4",
         "iPadMini4Cellular-iPadMini4Cellular",
         "iPadPro-iPadPro",
         "iPadProCellular-iPadProCellular",
         "iPadPro97-iPadPro97",
         "iPadPro97Cellular-iPadPro97Cellular",
         "iPhoneSE-iPhoneSE",
         "iPhone7-iPhone7",
         "iPhone7Plus-iPhone7Plus",
         "iPad611-iPad611",
         "iPad612-iPad612",
         "iPad71-iPad71",
         "iPad72-iPad72",
         "iPad73-iPad73",
         "iPad74-iPad74",
         "iPhone8-iPhone8",
         "iPhone8Plus-iPhone8Plus",
         "iPhoneX-iPhoneX",
         "iPad75-iPad75",
         "iPad76-iPad76",
         "iPhoneXS-iPhoneXS",
         "iPhoneXSMax-iPhoneXSMax",
         "iPhoneXR-iPhoneXR",
         "iPad812-iPad812",
         "iPad834-iPad834",
         "iPad856-iPad856",
         "iPad878-iPad878",
         "Watch4-Watch4",
         "iPadMini5-iPadMini5",
         "iPadMini5Cellular-iPadMini5Cellular",
         "iPadAir3-iPadAir3",
         "iPadAir3Cellular-iPadAir3Cellular",
         "iPodTouchSeventhGen-iPodTouchSeventhGen",
         "iPhone11-iPhone11",
         "iPhone11Pro-iPhone11Pro",
         "iPadSeventhGen-iPadSeventhGen",
         "iPadSeventhGenCellular-iPadSeventhGenCellular",
         "iPhone11ProMax-iPhone11ProMax",
         "iPhoneSESecondGen-iPhoneSESecondGen",
         "iPadProSecondGen-iPadProSecondGen",
         "iPadProSecondGenCellular-iPadProSecondGenCellular",
         "iPadProFourthGen-iPadProFourthGen",
         "iPadProFourthGenCellular-iPadProFourthGenCellular",
         "iPhone12Mini-iPhone12Mini",
         "iPhone12-iPhone12",
         "iPhone12Pro-iPhone12Pro",
         "iPhone12ProMax-iPhone12ProMax",
         "iPadAir4-iPadAir4",
         "iPadAir4Cellular-iPadAir4Cellular",
         "iPadEighthGen-iPadEighthGen",
         "iPadEighthGenCellular-iPadEighthGenCellular",
         "iPadProThirdGen-iPadProThirdGen",
         "iPadProThirdGenCellular-iPadProThirdGenCellular",
         "iPadProFifthGen-iPadProFifthGen",
         "iPadProFifthGenCellular-iPadProFifthGenCellular",
         "iPhone13Pro-iPhone13Pro",
         "iPhone13ProMax-iPhone13ProMax",
         "iPhone13Mini-iPhone13Mini",
         "iPhone13-iPhone13",
         "iPadMiniSixthGen-iPadMiniSixthGen",
         "iPadMiniSixthGenCellular-iPadMiniSixthGenCellular",
         "iPadNinthGen-iPadNinthGen",
         "iPadNinthGenCellular-iPadNinthGenCellular",
         "iPhoneSEThirdGen-iPhoneSEThirdGen",
         "iPadAirFifthGen-iPadAirFifthGen",
         "iPadAirFifthGenCellular-iPadAirFifthGenCellular",
         "iPhone14-iPhone14",
         "iPhone14Plus-iPhone14Plus",
         "iPhone14Pro-iPhone14Pro",
         "iPhone14ProMax-iPhone14ProMax",
         "iPadTenthGen-iPadTenthGen",
         "iPadTenthGenCellular-iPadTenthGenCellular",
         "iPadPro11FourthGen-iPadPro11FourthGen",
         "iPadPro11FourthGenCellular-iPadPro11FourthGenCellular",
         "iPadProSixthGen-iPadProSixthGen",
         "iPadProSixthGenCellular-iPadProSixthGenCellular",
         "iPhone15-iPhone15",
         "iPhone15Plus-iPhone15Plus",
         "iPhone15Pro-iPhone15Pro",
         "iPhone15ProMax-iPhone15ProMax"
       ],
       "description" : "* 업데이트를 하기 전에 항상 폰 백업 혹은 '이메일 계정 연결', '친구목록 내보내기' 등으로 중요한 데이터를 보관하시기를 권장합니다.\n\n** 카카오톡은 무료 앱입니다. 업데이트 또는 앱 설치 과정에서 일부 사용자에게 보여지는 앱스토어 $1결제 관련 메시지는 실제로 비용이 청구되지 않습니다. 자세한 내용은 애플에 문의해주시기 바랍니다.\n================================\n카카오톡을 이용하면  푸쉬 기능을 통해  즉각적으로 메시지를 받을 수 있고  사진, 동영상, 연락처 등의 멀티미디어도 간편하게 주고 받을 수 있습니다. 이제 SMS에서 벗어나 카카오톡으로 친구, 동료, 가족들과 보다 편리하고 다양한 멀티미디어 채팅을 시작해 보세요.\n\n- 카카오톡의 주요 기능 -\n\n* 전세계 어디서나 무료로 즐기는 그룹채팅 및 1:1 채팅\n카카오톡을 설치한 친구들간에는 국내뿐 아니라 해외에 있는 친구들과도 무료로 채팅을 즐길 수 있습니다.  기본적인 1:1 채팅뿐 아니라,  그룹 채팅을 통해 여러 친구들과 동시에  메시지, 사진, 동영상, 음악, 연락처 등을 간편하게 주고 받을 수 있습니다. \n(카카오톡은 WIFI 또는 셀룰러 데이터를 이용합니다) \n\n*모임이 편리해지는 톡게시판\n모임 안내를 공지로 올리고, 일정과 투표로 더 쉽게 모여보세요. 게시판에 사진과 동영상, 파일을 올려두면 언제든지 찾아 볼 수 있습니다. \n\n*카톡하다 궁금할 때 #검색 \n카톡하다 궁금한게 생기면 따로 찾지말고 #검색으로 원하던 답을 한 눈에 찾아 보세요. \n\n*링크로 연결되는 오픈채팅\n친구 추가 없이 채팅하고 싶을 때 링크를 만들어서 대화할 수 있어요. 좋아하는 관심사나 스터디\/모임으로 활용해 보세요. \n\n*전세계 어디서나 보이스톡, 뽀샤시한 얼굴로 페이스톡\n무제한 무료통화가 가능한 보이스톡으로 친구들과 이야기를 나누어 보세요. 페이스톡 영상통화는 감각적인 필터로 여러분의 얼굴을 더 아름답게 보여줄 수 있습니다. \n\n*카톡만 있다면 송금할 준비 끝 \n계좌번호, 공인인증서, OTP 없이 카톡 친구에게 메시지 보내 듯 쉽게 송금할 수 있습니다.\n\n*유용하고 안전한 주문, 배송, 결제 등의 정보성 메시지, 알림톡\n스팸 문자에 불편하고 스미싱 문자에 불안하셨나요? 대표전화에는 문자 회신 못해 답답하셨나요?\n주문\/결제\/예약 내역이나 배송현황과 같이 여러분에게 꼭 필요한 정보들은 카카오톡 채널 알림톡으로 보내 드립니다.\n\n*톡에서 하는 데이터 관리! 톡서랍\n매일 톡에서 주고받는 데이터를 자동으로 보관하고, 톡서랍 플러스에서 손쉽게 관리해보세요!\n\n[서비스 접근 권한 안내]\n* 선택 접근 권한\n- 위치정보 : 지도 기능 사용시 위치 정보 검색 및 위치 공유\n- 연락처 : 친구 추가 및 연락처, 프로필 전송\n- 사진 : 프로필, 채팅방에 사진 및 멀티미디어 파일 제공\n- 마이크 : 보이스톡,페이스톡, 라이브톡 통화 및 음성메시지 녹음\n- 카메라 : 친구추가를 위한 QR코드 촬영, 페이스톡 통화, 채팅방 멀티미디어 파일 제공, QR코드 인식, 카카오페이 신용카드 번호 인식 \n- 캘린더: 기기 캘린더의 일정 수정 및 등록\n\n* 선택 접근 권한은 동의하지 않아도 서비스 이용이 가능합니다.\n* 선택 접근 권한 미동의시 서비스 일부 기능의 정상적인 이용이 어려울 수 있습니다.\n\n* '카카오톡', '알림톡', '오픈채팅', '페이스톡' 등 카카오톡 애플리케이션에 표시된 다수의 서비스 명칭은 주식회사 카카오의 등록 상표 또는 상표입니다. 애플리케이션 내부에는 ® 및 TM 을 표시하지 않았습니다.",
       "artistId" : 362057950,
       "kind" : "software",
       "appletvScreenshotUrls" : [

       ],
       "releaseDate" : "2010-03-18T03:17:28Z",
       "averageUserRating" : 2.98462000000000005073275133327115327119,
       "genres" : [
         "소셜 네트워킹",
         "생산성"
       ],
       "fileSizeBytes" : "468942848",
       "userRatingCountForCurrentVersion" : 136080,
       "releaseNotes" : "[v10.6.3]\n• 버그 수정 및 안정성 개선\n\n[v10.6.0] \n• 멀티프로필을 기본프로필로 변경할 수 있어요. \n• 이제 누구나 팀채팅을 만들 수 있어요.\n• 친구 메모 기능 추가 \n: 친구 프로필의 편집 버튼을 눌러 메모를 기록할 수 있어요.\n• 장문 메시지에서 글자 크기를 조절하고 음성으로 들을 수 있어요.\n• 투표 종료 전 알림 기능 추가\n• 실험실 조용한 채팅방 정식화 \n• 펑 텍스트 스타일 기능 추가",
       "artistName" : "Kakao Corp.",
       "sellerUrl" : "https:\/\/www.kakaocorp.com\/service\/KakaoTalk",
       "screenshotUrls" : [
         "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/PurpleSource122\/v4\/29\/42\/11\/29421100-6488-fd8b-3078-940a85efe14b\/62c3d928-00bd-41d6-961f-3e91faabc09d_Kakaotalk_iOS_SC_KR_01.jpg\/392x696bb.jpg",
         "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/PurpleSource122\/v4\/9a\/20\/c2\/9a20c252-ccd1-93a9-5b25-c28274688e4f\/e7a871ac-678d-475d-b0d0-be370ea3225f_Kakaotalk_iOS_SC_KR_02.jpg\/392x696bb.jpg",
         "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/PurpleSource122\/v4\/e4\/54\/ef\/e454ef6a-fb8b-c131-976f-6d09a6c0dd47\/66f985c5-567f-403b-a6cf-df45f0af2497_Kakaotalk_iOS_SC_KR_03.jpg\/392x696bb.jpg",
         "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/PurpleSource122\/v4\/98\/3a\/0d\/983a0d96-fef6-7d19-a5df-e9c2179b44e2\/0f0f11f7-765e-4a14-b9bc-3572b3106ac8_Kakaotalk_iOS_SC_KR_04.jpg\/392x696bb.jpg",
         "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/PurpleSource122\/v4\/2f\/b9\/67\/2fb96724-3844-3243-b9d6-637efd5f9792\/a8804301-6e1c-4318-ad0c-13c89e9de9dd_Kakaotalk_iOS_SC_KR_06.jpg\/392x696bb.jpg"
       ],
       "sellerName" : "Kakao Corp.",
       "isVppDeviceBasedLicensingEnabled" : true,
       "wrapperType" : "software",
       "artworkUrl60" : "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/Purple211\/v4\/ea\/e7\/8c\/eae78c65-802f-5f81-ce19-49698cce2ec5\/AppIcon-0-0-1x_U007emarketing-0-0-0-10-0-0-sRGB-85-220.png\/60x60bb.jpg",
       "artworkUrl100" : "https:\/\/is1-ssl.mzstatic.com\/image\/thumb\/Purple211\/v4\/ea\/e7\/8c\/eae78c65-802f-5f81-ce19-49698cce2ec5\/AppIcon-0-0-1x_U007emarketing-0-0-0-10-0-0-sRGB-85-220.png\/100x100bb.jpg",
       "version" : "10.6.3"
     }
   ],
   "resultCount" : 1
 }

 
 */

