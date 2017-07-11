//
//  RESTClient.swift
//  Cheers
//
//  Created by Charles Fayal on 6/11/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation
import AFNetworking

protocol RequestReturn{
    func failed()
    func success()
}

class RESTClient:NSObject{
    
    typealias CompletionHandler = (_ json:[String:Any]?, _ error:ServerError?) -> Void
    
    struct ServerError: Error{
        var localizedDescription: String
        init(localizedDescription:String){
            self.localizedDescription = localizedDescription
        }
    }
    
    let session: URLSession

    
     override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        self.session = URLSession(configuration: configuration)
        super.init()
    }
    
    
    func createRequest( pathExtension: String, params: [String:Any]) -> URLRequest{
        print(#function)
        let baseURL = URL(string: ConfigUtil.SERVER_BASE)!
        let url = baseURL.appendingPathComponent(pathExtension)
        print("URL: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        request.httpBody = jsonData
        return request
    }
    
    func createRequest( pathExtension: String, params: [String:Any], completionHandler: @escaping CompletionHandler){
        print(#function)
        let request = self.createRequest(pathExtension: pathExtension, params: params)
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                let (decodedError, json) =  self.decodeResponse(urlResponse, data: data, error: error as NSError?)
                completionHandler(json, decodedError)
            }
        }
        task.resume()
    }
    
    func decodeResponse(_ response: URLResponse?,data: Data?, error: NSError?) -> (ServerError?, [String:AnyObject]?){
        if let httpResponse = response as? HTTPURLResponse
            , httpResponse.statusCode != 200 {
            return (ServerError(localizedDescription: "FailingStatusCode: \(httpResponse.statusCode)"), nil)
        } else if error != nil  {
            print("Error in decode response \(error.debugDescription)")
            return (ServerError(localizedDescription: error!.localizedDescription) ,nil)
        } else {
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                if let errorMessage = json["Error"] {
                    return (ServerError(localizedDescription: errorMessage as! String) , nil)
                } else {
                    return (nil, json)
                }
            }catch {
                return (ServerError(localizedDescription: "Could not serialize response") , nil)
                
            }
        }
    }
    

}
