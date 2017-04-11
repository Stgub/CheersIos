//
//  StripeAPIAdapter.swift
//  Cheers
//
//  Created by Charles Fayal on 4/3/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation
import Stripe
import AFNetworking


class MyAPIClient:NSObject, STPBackendAPIAdapter {

    static let sharedClient = MyAPIClient()
    var defaultSource: STPCard? = nil
    let session: URLSession
    var baseURLString: String? = nil
    var sources: [STPCard] = []
    
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        self.session = URLSession(configuration: configuration)
        super.init()
    }
    
    
    func decodeResponse(_ response: URLResponse?, error: NSError?) -> NSError? {
        if let httpResponse = response as? HTTPURLResponse
            , httpResponse.statusCode != 200 {

            return error //?? NSError.networkingError(httpResponse.statusCode)
        }
        return error
    }
    

    func createCharge(_ result: STPPaymentResult, amount: Int, completion:  @escaping (_ error: Error?)->Void){
        print("Create charge")

        guard let baseURLString = baseURLString, let baseURL = URL(string: baseURLString) else {
            print("Error with base string")
            return
        }
        let path = "/charge"
        let url = baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let json: [String: Any] = [
            "customerID": "cus_AOKsWJgyCIX2I1",
            "amount": amount,
            "source":result.source.stripeID]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
        task.resume()

    }
    
    func createCutomer( completion: @escaping (_ customer:STPCustomer? , _ error:Error?) -> Void){

        print("createCustomer")
        guard let baseURLString = baseURLString, let baseURL = URL(string: baseURLString) else {
            print("Error with base string")
            return
        }
        let path = "/createCustomer"
        let url = baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        var json: [String: Any] = [:]
        if let email = currentUser.userEmail {
            json["email" ] = email
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                let deserializer = STPCustomerDeserializer(data: data, urlResponse: urlResponse, error: error)
                if let error = deserializer.error {
                    print("Error in retrieving customer")
                    completion(nil, error)
                    return
                } else if let customer = deserializer.customer {
                    currentUser.setStripeID(stripeID: customer.stripeID){
                        (error) in
                        if error != nil {
                            completion(nil,error)
                        } else {
                            completion(customer, nil)
                        }
                    }
                }
            }
        }
        task.resume()
        
    }
    
    func retrieveCustomer(_ customerID:String, completion:@escaping (_ customer:STPCustomer? , _ error:Error?)-> Void){
        guard let baseURLString = baseURLString, let baseURL = URL(string: baseURLString) else {
            print("Error with base string")
            return
        }
        let path = "/retrieveCustomer"
        let url = baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let json: [String: Any] = ["customerID": customerID]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                let deserializer = STPCustomerDeserializer(data: data, urlResponse: urlResponse, error: error)
                if let error = deserializer.error {
                    print("Error in retrieving customer")
                    completion(nil, error)
                    return
                } else if let customer = deserializer.customer {
                    completion(customer, nil)
                }
            }
        }
        task.resume()

    }
    func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        print("retrieveCustomer function")
        guard let _ = currentUser else {
            return
        }
       guard let baseURLString = baseURLString, let baseURL = URL(string: baseURLString) else {
            print("Error with base string")
            return
        }
        if let customerID = currentUser.stripeID {
            self.retrieveCustomer(customerID){
                (customer,error) in
                if let error = error {
                    print("Error in retrieving customer \(error)")
                    completion(nil, error)
                    return
                } else if let customer = customer {
                    completion(customer, nil)
                }
            }
        } else {
            self.createCutomer(completion: { (customer, error) in
                if let error = error {
                    print("Error in creating customer \(error)")
                    completion(nil, error)
                    return
                } else if let customer = customer {
                    completion(customer, nil)
                }
            })
            
        }
    }
 
    
    func unusubscribeCustomer(completion:@escaping (_ status:String,_ message:String)->Void){
        print("postStripeToken")
        
        let URL = SERVER_BASE + "/unsubscribeUser"
        guard let customerId = currentUser.stripeID else {
            completion("Error", "Please contact support@GetToastApp.com - Error stripeID")
            print("Backend Error: - No customer ID in current User")
            return
        }
        let params = ["customerID":customerId] as [String:String]
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = Set(["text/html","application/json"])
        manager.post(URL, parameters: params, success: { (operation, responseObject) -> Void in
            if let response = responseObject as? [String: String] {
                if let error = response["Error"] {
                    print(response)
                    completion("Error", "Please try again")
                    print("Error unsubscribing- \(error)")
                } else {
                    //Protect these
                    currentUser.setMembership(membership: membershipLevels.basic){error in
                        if error != nil {
                            completion("Error","Please try again")
                        } else {
                            let status = response["status"]
                            let message = response["message"]
                            completion(status!,message!)
                        }
      
                    }

                }
            }else{ print("Backend Error: Could not convert to [String: String]")}
            
        },
                     failure:
            {
                requestOperation, error in
                print("Chuck: Error -\(error)")
                completion("Error","Please try again. Error -\(error?.localizedDescription)")
                
        })
        
    }
    /**
     *  Adds a payment source to a customer. On your backend, retrieve the Stripe customer associated with your logged-in user. Then, call the Update Customer method on that customer as described at https://stripe.com/docs/api#update_customer (for an example Ruby implementation of this API, see https://github.com/stripe/example-ios-backend/blob/master/web.rb#L60 ). If this API call succeeds, call `completion(nil)`. Otherwise, call `completion(error)` with the error that occurred.
     *
     *  @param source     a valid payment source, such as a card token.
     *  @param completion call this callback when you're done adding the token to the customer on your backend. For example, `completion(nil)` (if your call succeeds) or `completion(error)` if an error is returned.
     *
     *  @note If you are on Swift 3, you must declare the completion block as `@escaping` or Xcode will give you a protocol conformance error. https://bugs.swift.org/browse/SR-2597
     */
    public func attachSource(toCustomer source: STPSource, completion: @escaping STPErrorBlock) {
        print("attachSource")
        guard let baseURLString = baseURLString, let baseURL = URL(string: baseURLString) else {
            if let token = source as? STPToken, let card = token.card {
                self.sources.append(card)
                self.defaultSource = card
            }
            completion(nil)
            return
        }
        let path = "/customer/sources"
        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let json: [String: Any] = ["sourceID": source.stripeID]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
        task.resume()
    }
    

    
    
    
    func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
        print("selectDefaultCustomerSource")
        let baseURLString = SERVER_BASE
        let baseURL = URL(string: baseURLString)!
       // guard let baseURLString = baseURLString, let baseURL = URL(string: baseURLString) else {
      /*  guard let baseURLString = SERVER_BASE, let baseURL = URL(string: baseURLString) else {

            if let token = source as? STPToken {
                self.defaultSource = token.card
            }
            completion(nil)
            return
        }*/
        let path = "/customer/default_source"
        let url = baseURL.appendingPathComponent(path)
        let params = [
            "source": source.stripeID,
            ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        //let request = URLRequest.request(url, method: .POST, params: params as [String : AnyObject])
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                if let error = self.decodeResponse(urlResponse, error: error as NSError?) {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
        task.resume()
    }
}
