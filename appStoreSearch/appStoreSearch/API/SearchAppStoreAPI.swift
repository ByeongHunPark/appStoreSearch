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
        
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion([])
            return
        }
        
        let countryCode = "kr"
        
//        let urlString = "https://itunes.apple.com/search?term=\(encodedTerm)&country=\(countryCode)&entity=software&limit=5&offset=\(offset)"
        let urlString = "https://itunes.apple.com/search?term=카카오톡&country=kr&entity=software&limit=1&offset=0"
        
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
                               let screenshotUrl = URL(string: screenshotUrlString) {
                                
//                                genres
//                                trackContentRating or contentAdvisoryRating
                                
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
                                                              description: description)
                                                
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
                               let screenshotUrl = URL(string: screenshotUrlString) {
                                
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
                                                              description: description)
                                                
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
