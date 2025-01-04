//
//  apiClient.swift
//  Q-swift
//
//  Created by Kehinde Bankole on 01/01/2025.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
}

enum ApiError: Error {
    case badUrl (String)
    
    var errorDescription : String?{
        switch self{
        case .badUrl(let message):
            return message
        }
    }
}

class APIClient  {
    
    
    func makeApiCall<T:Codable>(url:String , method:HTTPMethod) -> AnyPublisher<T, Error> {
        let url = URL(string: url)
        guard let availableUrl = url else{
            return Fail(error: ApiError.badUrl("invalid url")).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: availableUrl)
            .map(\.data)
            .decode(type:T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
}


class CharacterViewModel<T: Codable>: ObservableObject {
    @Published var data: CharactersResponse?
    @Published var errorMessage: String? = nil
    @Published var isLoading = false
    
    private var apiClient = APIClient()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchData(from url: String, method: HTTPMethod) {
        self.isLoading = true
        
        self.apiClient.makeApiCall(url: url, method: method)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isLoading = false
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { (response: CharactersResponse) in
                
                if(self.data != nil){
                    self.data?.results.append(contentsOf: response.results)
                }else{
                    self.data = response
                }
            })
            .store(in: &self.cancellables)
        
    }
}
