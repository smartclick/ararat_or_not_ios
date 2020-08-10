//
//  Networking.swift
//  AraratOrNot
//
//  Created by Sevak Soghoyan on 8/3/20.
//  Copyright © 2020 Sevak Soghoyan. All rights reserved.
//
import Foundation

public enum HTTPMethods: String {
    case POST,PUT,DELETE,GET
}

public struct Networking {
    //MARK:- Public methods
    public static func checkImageFromUrl(imageUrlLink: String,
                                         completion: @escaping (Result<ImageResponse,NetworkError>) -> Void) {
        let parameters = ["url": imageUrlLink]
        performTask(endpointAPI: IAraratAPI.image, httpMethod: .POST, contentType: "application/x-www-form-urlencoded", httpBody: parameters.percentEncoded()!, type: ImageResponse.self, completion: completion)
    }
    
    public static func checkImage(imageData: Data,
                                  completion: @escaping (Result<ImageResponse,NetworkError>) -> Void) {
        let boundary = UUID().uuidString
        let httpBody = NSMutableData()
        httpBody.append(convertFileData(fileData: imageData,
                                        using: boundary))
        httpBody.appendString("--\(boundary)--")
        performTask(endpointAPI: IAraratAPI.image, httpMethod: .POST, contentType: "multipart/form-data; boundary=\(boundary)", httpBody: httpBody as Data, type: ImageResponse.self, completion: completion)
    }
    
    public static func sendFeedback(imageId: String,
                                    isCorrect: Bool,
                                    completion: @escaping (Result<MessageResponse,NetworkError>) -> Void) {
        let feedbackAPI = IAraratAPI.feedback(imageId: imageId)
        let parameters = ["is_correct": isCorrect]
        performTask(endpointAPI: feedbackAPI, httpMethod: .POST, contentType: "application/x-www-form-urlencoded", httpBody: parameters.percentEncoded()!, type: MessageResponse.self, completion: completion)
    }
    
    public static func performTask<T: Decodable>(endpointAPI: EndpointType,
                                   httpMethod: HTTPMethods,
                                   contentType: String,
                                   httpBody: Data,
                                   type: T.Type,
                                   completion: @escaping (Result<T,NetworkError>) -> Void) {
        let urlString = (endpointAPI.baseURL + endpointAPI.path).removingPercentEncoding!
        guard let url = URL(string: urlString) else {
            completion(.failure(.domainError))
            return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = httpBody
        performNetworkTask(type: T.self, urlRequest: urlRequest, completion: completion)
    }
    
    //MARK:- Private methods
    private static func performNetworkTask<T: Decodable>(type: T.Type,
                                                         urlRequest: URLRequest,
                                                         completion: @escaping (Result<T,NetworkError>) -> Void) {
        let urlSession = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, error) in
            guard let data = data,
                let response = urlResponse as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
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
