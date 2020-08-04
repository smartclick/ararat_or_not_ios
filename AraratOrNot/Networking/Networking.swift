//
//  Networking.swift
//  AraratOrNot
//
//  Created by Sevak Soghoyan on 8/3/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//

import Foundation

public struct Networking {
    //MARK:- Public methods
    public static func checkImageFromUrl(imageUrlLink: String,
                                         completion: @escaping (Result<ImageResponse,NetworkError>) -> Void) {
        let urlString = IAraratAPI.image.baseURL.appendingPathComponent(IAraratAPI.image.path).absoluteString.removingPercentEncoding
        guard let url = URL(string: urlString ?? "") else {
            completion(.failure(.domainError))
            return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        let parameters = ["url": imageUrlLink]
        urlRequest.httpBody = parameters.percentEncoded()
        Networking.performNetworkTask(type: ImageResponse.self, urlRequest: urlRequest, completion: completion)
    }
    
    public static func checkImage(image: UIImage,
                                  completion: @escaping (Result<ImageResponse,NetworkError>) -> Void) {
        let urlString = IAraratAPI.image.baseURL.appendingPathComponent(IAraratAPI.image.path).absoluteString.removingPercentEncoding
        guard let url = URL(string: urlString ?? "") else {
            completion(.failure(.domainError))
            return }
        let boundary = UUID().uuidString
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        let httpBody = NSMutableData()
        httpBody.append(convertFileData(fileData: image.pngData()!,
                                        using: boundary))
        
        httpBody.appendString("--\(boundary)--")
        
        urlRequest.httpBody = httpBody as Data
        Networking.performNetworkTask(type: ImageResponse.self, urlRequest: urlRequest, completion: completion)
    }
    
    public static func sendFeedback(imageId: String,
                                    isCorrect: Bool,
                                    completion: @escaping (Result<MessageResponse,NetworkError>) -> Void) {
        let feedbackAPI = IAraratAPI.feedback(imageId: imageId)
        let urlString = feedbackAPI.baseURL.appendingPathComponent(feedbackAPI.path).absoluteString.removingPercentEncoding
        guard let url = URL(string: urlString ?? "") else {
            completion(.failure(.domainError))
            return }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        let parameters = ["is_correct": isCorrect ? "1": "0"]
        urlRequest.httpBody = parameters.percentEncoded()
        Networking.performNetworkTask(type: MessageResponse.self, urlRequest: urlRequest, completion: completion)
    }
    
    //MARK:- Private methods
    private static func performNetworkTask<T: Decodable>(type: T.Type,
                                                         urlRequest: URLRequest,
                                                         completion: @escaping (Result<T,NetworkError>) -> Void) {
        let urlSession = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
            guard let data = data,
                let response = urlResponse as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    completion(.failure(.domainError))
                    return
            }
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                if let response = decodeData(type: MessageResponse.self, data: data),let errorText = response.error {
                    completion(.failure(.apiError(errorMessage: errorText)))
                } else {
                    completion(.failure(.statusCodeError))
                }
                return
            }
            
            if let response = decodeData(type: T.self, data: data) {
                completion(.success(response))
            } else {
                completion(.failure(.decodingError))
            }
        }
        urlSession.resume()
    }    
    
    private static func decodeData<T: Decodable>(type: T.Type, data: Data) -> T? {
        let jsonDecoder = JSONDecoder()
        do {
            let response = try jsonDecoder.decode(T.self, from: data)
            return response
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private static func convertFileData(fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"Ararat.png\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return data as Data
    }
}
