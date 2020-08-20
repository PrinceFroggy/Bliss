//
//  WebApiRequest.swift
//  Bliss
//
//  Created by Andrew Solesa on 2020-04-19.
//  Copyright © 2020 KSG. All rights reserved.
//

import UIKit

class WebApiRequest
{
    var urlBase = "🔥"

    var httpMethod = "GET"
    var headerAccept = "application/json"
    var headerContentType = "application/json"
    var httpBody: Data?
    
    func sendRequest<T:Decodable>(toUrlPath urlPath: String, completion: @escaping (T) -> Void)
    {
        //let encodedUrlPath = urlPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let url = URL(string: urlBase) else
        {
            print("\nFailed to construct url with \(urlBase)\(urlPath)")
            return
        }
        
        let sessionConfig = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: OperationQueue.main)
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod
        request.httpBody = httpBody
        request.setValue(headerAccept, forHTTPHeaderField: "Accept")
        request.setValue(headerContentType, forHTTPHeaderField: "Content-Type")
        
        let token = ""
        
        if !token.isEmpty
        {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest)
        { (data, response, error) in
            
            if let error = error
            {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print("\nTask request error: \(error.localizedDescription)")
                print("\n\(error)\n")
            }
            
            let r = response as! HTTPURLResponse
            
            if (100...199).contains(r.statusCode)
            {
                let results: T? = "Response was interim or informational" as? T
                
                completion(results!)
            }
            
            if let data = data, (200...299).contains(r.statusCode)
            {
                print("\nResponse status code is \(r.statusCode)\nHeaders:")
                
                var results: T? = nil
                
                do
                {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    //decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                    results = try decoder.decode(T.self, from: data)
                }
                catch
                {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    print("\nData decoding error: \(error.localizedDescription)")
                    print("\n\(error)\n")
                    return
                }
                print(results)
                completion(results!)
            }
            
            if (300...399).contains(r.statusCode)
            {
                let results: T? = "HTTP \(r.statusCode) - Request was redirected" as? T
                
                completion(results!)
            }
            
            if (400...499).contains(r.statusCode)
            {
                let results: T? = "HTTP \(r.statusCode) - The request caused an error" as? T
                
                completion(results!)
            }
            
            if (500...599).contains(r.statusCode)
            {
                let results: T? = "HTTP \(r.statusCode) - An error on the server happened" as? T
                
                completion(results!)
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        task.resume()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}
