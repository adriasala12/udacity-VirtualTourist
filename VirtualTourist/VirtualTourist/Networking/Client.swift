//
//  Client.swift
//  VirtualTourist
//
//  Created by Adrià Sala Roget on 12/05/2020.
//  Copyright © 2020 Adrià Sala Roget. All rights reserved.
//

import Foundation

class Client {
    
    static func randomPage() -> Int {
        return Int.random(in: 1...4000)
    }
    
    enum Endpoints {
                
        static let apiKey = "3170a4090f7879b880f08a68154851c6"
        static let apiSecret = "7f27b697407588c3"
        static let baseURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let numOfPhotos = 21
        
        case searchURL(latitude: Double, longitude: Double, page: Int)
    
        var urlString: String {
            switch self {
            case .searchURL(let latitude, let longitude, let page):
                return Endpoints.baseURL + "&api_key=\(Endpoints.apiKey)" + "&lat=\(latitude)" + "&lon=\(longitude)" + "&per_page=\(Endpoints.numOfPhotos)" + "&page=\(page)" + "&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: urlString)!
        }
        
    }
    
    class func getFlickrUrls(latitude: Double, longitude: Double, completion: @escaping ([PhotoInfo]) -> Void) {
        
        let url = Endpoints.searchURL(latitude: latitude, longitude: longitude, page: randomPage()).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let data = data else {
                print("No data for flickr urls")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let results = try decoder.decode(SearchResponse.self, from: data)
                completion(results.photos.photo)
            } catch {
                print(error)
                return
            }
            
        })
        task.resume()
    }
    
    class func getFlickrImageData(forUrl url: URL, completion: @escaping (Data) -> Void) {
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            if let data = data {
                completion(data)
            }
            
        })
        task.resume()
    }
    
    
    
    
    
    
    
    
    
}
