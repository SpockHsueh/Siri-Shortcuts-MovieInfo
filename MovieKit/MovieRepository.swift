//
//  MovieRepository.swift
//  MovieKit
//
//  Created by Spock on 2019/4/14.
//  Copyright © 2019 Spock. All rights reserved.
//

import Foundation

public class MovieRepository {
    
    public static let shared = MovieRepository()
    private init() {}
    private let apiKey = "badd7b8ed0cbcf0d27a917a90a35e502"
    private let baseAPIURL = "https://api.themoviedb.org/3"
    private let urlSession = URLSession.shared
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    public enum Endpoint: String, CustomStringConvertible, CaseIterable {
        case nowPlaying = "now_playing"
        case upcoming
        case popular
        case topRated = "top_rated"
        
        public var description: String {
            switch self {
            case .nowPlaying: return "Now Playing"
            case .upcoming: return "Upcoming"
            case .popular: return "Popular"
            case .topRated: return "Top Rated"
            }
        }
        
        public init?(description: String) {
            guard let first = Endpoint.allCases.first(where: { $0.description == description }) else {
                return nil
            }
            self = first
        }
        
    }
    
    public enum MovieError: Error {
        case apiError
        case invalidEndpoint
        case invalidResponse
        case noData
        case serializationError
    }
    
    public func fetchMovies(from endpoint: Endpoint, params: [String: String]? = nil, successHandler: @escaping (_ response: MoviesResponse) -> Void, errorHandler: @escaping(_ error: Error) -> Void) {
        
        guard var urlComponents = URLComponents(string: "\(baseAPIURL)/movie/\(endpoint.rawValue)") else {
            errorHandler(MovieError.invalidEndpoint)
            return
        }
        
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            errorHandler(MovieError.invalidEndpoint)
            return
        }
        
        urlSession.dataTask(with: url) { (data, response, error) in
            if error != nil {
                errorHandler(MovieError.apiError)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                errorHandler(MovieError.invalidResponse)
                return
            }
            
            guard let data = data else {
                errorHandler(MovieError.noData)
                return
            }
            
            do {
                let moviesResponse = try self.jsonDecoder.decode(MoviesResponse.self, from: data)
                successHandler(moviesResponse)
            } catch {
                errorHandler(MovieError.serializationError)
            }
            }.resume()
        
    }
    
    
    public func fetchMovie(id: Int, successHandler: @escaping (_ response: Movie) -> Void, errorHandler: @escaping(_ error: Error) -> Void) {
        guard let url = URL(string: "\(baseAPIURL)/movie/\(id)?api_key=\(apiKey)&append_to_response=videos,credits") else {
            errorHandler(MovieError.invalidEndpoint)
            return
        }
        
        urlSession.dataTask(with: url) { (data, response, error) in
            if error != nil {
                errorHandler(MovieError.apiError)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                errorHandler(MovieError.invalidResponse)
                return
            }
            
            guard let data = data else {
                errorHandler(MovieError.noData)
                return
            }
            
            do {
                let movie = try self.jsonDecoder.decode(Movie.self, from: data)
                successHandler(movie)
            } catch {
                errorHandler(MovieError.serializationError)
            }
            }.resume()
        
    }
    
}
