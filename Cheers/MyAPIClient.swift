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

protocol RequestReturn{
    func failed()
    func success()
}

class MyAPIClient:NSObject, STPBackendAPIAdapter {



    typealias CompletionHandler = (_ json:[String:Any]?, _ error:ServerError?) -> Void
    
    struct ServerError: Error{
        var localizedDescription: String
        init(localizedDescription:String){
            self.localizedDescription = localizedDescription
        }
    }
    
    static let sharedClient = MyAPIClient()
    var defaultSource: STPCard? = nil
    let session: URLSession
    var sources: [STPCard] = []

    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5
        self.session = URLSession(configuration: configuration)
        super.init()
    }
    
  
    func createRequest( pathExtension: String, params: [String:Any]) -> URLRequest{
        let baseURL = URL(string: SERVER_BASE)!
        let url = baseURL.appendingPathComponent(pathExtension)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        request.httpBody = jsonData
        return request

    }

    func createRequest( pathExtension: String, params: [String:Any], completionHandler: @escaping CompletionHandler){
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
    
    
    //Referral system functions
    func createConnectAccount(completion: @escaping (_ error: Error?)->()){
        print("MYAPIClient: checkout")
        
        let pathExtension = "/connectCreateAccount"
        let params = ["email":"Charlesfayal@gmail.com"]
      
        
        _ = createRequest(pathExtension: pathExtension, params: params){
            (json, error) in
            if error != nil{
                completion(error)
            } else {
                print("Success acccount creation")
                guard let json = json else{
                    print("Json error should not be nil")
                    return
                }
                if let accountId = json["id"] as? String{
                    currentUser.connectId = accountId
                    completion(nil)
                } else {
                    print("Checkout Error: Could not retrieve id")
                }
            }
        }


    }
    
    
    func connectAddBank(bankToken: String, completion:@escaping (_ error: Error?)->()){
        print("MYAPIClient: connectAddBank")
        let pathExtension = "/connectBank"
        guard let connectId = currentUser.connectId else {
            print("No connect account ID, need to create acccount")
            
            return
        }
    
        let params = [userDataTypes.connectId: connectId,
                      "token": bankToken
            ] as [String : Any]
        
        _ = self.createRequest(pathExtension: pathExtension, params: params){
            (json, error) in
            if error != nil {
                completion(error)
            } else {
                completion(nil)
            }
            
        }

        
    }

    func connectAddBank(bankParams: STPBankAccountParams, completion:@escaping (_ error: Error?)->()){
        print("MYAPIClient: connectAddBank")
        let pathExtension = "/connectAddBank"
        guard let connectId = currentUser.connectId else {
            print("No connect account ID, need to create acccount")
            
            return
        }
        STPAPIClient.shared().createToken(withBankAccount: bankParams) { (token, error) in
            if error != nil {
                completion(error)
            } else {
                let params = [userDataTypes.connectId: connectId,
                              "token": token!.tokenId
                    ] as [String : Any]
                
                _ = self.createRequest(pathExtension: pathExtension, params: params){
                    (json, error) in
                    if error != nil {
                        completion(error)
                    } else {
                        completion(nil)
                    }

                }
            }
        }
    }
    
    func connectVerifyBank(amount1:Int, amount2:Int, completion:@escaping (_ error:Error?)->()){
        print("MYAPIClient: connectVerifyBank")
        let pathExtension = "/verifyBank"
        guard let connectId = currentUser.connectId else {
            print("No connect account ID, need to create acccount")
            return
        }
        
        let params = [userDataTypes.connectId: connectId,
                      "amount1": amount1,
                      "amount2": amount2 ] as [String : Any]
        _ = createRequest(pathExtension: pathExtension, params: params){
            (json, error) in
            if error != nil{
                completion(error)
            } else {
                completion(nil)
                print("Successfully verified bank")
            }
        }
    }
    
    func getBankAccounts( completion:@escaping (_ error:Error?) -> Void){
        print("MYAPIClient: getBankAccounts")
        let pathExtension = "/getBankAccounts"
        guard let connectId = currentUser.connectId else {
            print("No connect account ID, need to create acccount")
            return
        }
        
        let params = [userDataTypes.connectId: connectId,
                     ] as [String : Any]
        _ = createRequest(pathExtension: pathExtension, params: params){
            (json, error) in
            if error != nil{
                completion(error)
            } else {
                for account in json! {
                    currentUser.bankAccounts[account.key] = account.value
                }
                completion(nil)
                print("Successfully verified bank")
            }
        }
    }
    func payout(completion:@escaping (_ error:Error?)->()){
        print("MYAPIClient: checkout")
        let pathExtension = "/connectPayout"
        guard let connectId = currentUser.connectId else {
            print("No connect account ID, need to create acccount")
            
            return
        }
        let payoutAmount = 1000 // TODO get this for real *******
        let params = [userDataTypes.connectId: connectId,
                      "amount": payoutAmount] as [String : Any]
        _ = createRequest(pathExtension: pathExtension, params: params){
            (json, error) in
            if error != nil{
                completion(error)
            } else {
                completion(nil)
                print("Success payout")
                if let accountId = json!["id"] as? String{
                    currentUser.connectId = accountId
                } else {
                    print("Checkout Error: Could not retrieve id")
                }
            }
        }
    }
    
    
    /**
     Updates the user and particularly currentPeriodStart and currentPeriodEnd from the server
    */
    func updateCustomer(){
        print("Backend: Updating user")
        guard let user = currentUser else {
            print("Backend: No user to update")
            return
        }
        let pathExtension = "/updateUser"
        let params = [ "customerID":currentUser.stripeID!] as [String:Any]
        createRequest(pathExtension: pathExtension, params: params){
            (json, error) in
            if error != nil{
                //completion(error)
            } else {
                //completion(nil)
                print("Success getting user info")
                if let currentPeriodStart = json![userDataTypes.currentPeriodStart] as? TimeInterval{
                    currentUser.currentPeriodStart = currentPeriodStart
                } else { print("Backend: could not get current start period") }
                if let currentPeriodEnd = json![userDataTypes.currentPeriodEnd] as? TimeInterval{
                    currentUser.currentPeriodEnd = currentPeriodEnd
                } else { print("Backend: Ccould not get current end period") }
                if let email = json!["email"] as? String {
                    currentUser.userEmail = email
                }
                if let numSubscriptions = json!["numSubscriptions"] as? Int {
                    if numSubscriptions > 0 {
                        currentUser.membership = membershipLevels.premium
                    }
                }
            }

        }
  
    }
    /**
     Adds the user to a subscription and charges them
 */

    func createCharge(_ result: STPPaymentResult, amount: Int, completion:  @escaping (_ error: Error?)->Void){
        print("Create charge")
        let pathExtension = "/charge"
        
        guard let stripeID = currentUser.stripeID else {
            createCutomer(completion: { (customer, error) in
                if error != nil {
                    print("Backend: Could not create customer for charge")
                    completion(error)
                } else {
                    currentUser.stripeID = customer?.stripeID
                  /*  self.createCharge(result, amount: amount, completion: {
                    (error) in
                        completion(error)
                    })*/
                }
            })
            return
        }
        let params: [String: Any] = [
            "customerID": stripeID ,
            "amount": amount,
            "sourceID":result.source.stripeID]
        let request = createRequest(pathExtension: pathExtension, params: params){
            (json, error) in
            if error != nil{
                completion(error)
            } else {
                completion(nil)
                print("Success")
                if let currentPeriodStart = json![userDataTypes.currentPeriodStart] as? TimeInterval{
                    currentUser.currentPeriodStart = currentPeriodStart
                } else { print("Backend: could not get current start period") }
                if let currentPeriodEnd = json![userDataTypes.currentPeriodEnd] as? TimeInterval{
                    currentUser.currentPeriodEnd = currentPeriodEnd
                } else { print("Backend: Ccould not get current end period") }
            }

        }

    }
    
    func createCutomer( completion: @escaping (_ customer:STPCustomer? , _ error:Error?) -> Void){
        print("createCustomer")
        let pathExtension = "/createCustomer"
        var params: [String: Any] = [:]
        if let email = currentUser.userEmail {
            params["email" ] = email
        }
        let request = createRequest(pathExtension: pathExtension, params: params)
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                let decodedError = self.decodeResponse(urlResponse,data: data!, error: error as NSError?)
                if decodedError != nil{
                    completion(nil,error)
                }
                let deserializer = STPCustomerDeserializer(data: data, urlResponse: urlResponse, error: error)
                if let deserError = deserializer.error {
                    print("Error in retrieving customer")
                    completion(nil, deserError)
                    return
                } else if let customer = deserializer.customer {
                    currentUser.stripeID = customer.stripeID
                    completion(customer, nil)
                }
            }
        }
        task.resume()
        
    }
    
    func retrieveCustomer(_ customerID:String, completion:@escaping (_ customer:STPCustomer? , _ error:Error?)-> Void){
        print("/retrieveCustomer")
        let pathExtension = "/retrieveCustomer"
        let params: [String: Any] = ["customerID": customerID]
        let request = createRequest(pathExtension: pathExtension, params: params)
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
        
        /**
         *  Retrieve the cards to be displayed inside a payment context. On your backend, retrieve the Stripe customer associated with your currently logged-in user (see https://stripe.com/docs/api#retrieve_customer ), and return the raw JSON response from the Stripe API. (For an example Ruby implementation of this API, see https://github.com/stripe/example-ios-backend/blob/master/web.rb#L40 ). Back in your iOS app, after you've called this API, deserialize your API response into an `STPCustomer` object (you can use the `STPCustomerDeserializer` class to do this). See MyAPIClient.swift in our example project to see this in action.
         *
         *  @see STPCard
         *  @param completion call this callback when you're done fetching and parsing the above information from your backend. For example, `completion(customer, nil)` (if your call succeeds) or `completion(nil, error)` if an error is returned.
         *
         *  @note If you are on Swift 3, you must declare the completion block as `@escaping` or Xcode will give you a protocol conformance error. https://bugs.swift.org/browse/SR-2597
         */

    func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        print("retrieveCustomer function")
        guard let _ = currentUser else {
            print("Current user was nil, will try to grab but otherwise will fail")
            MyFireBaseAPIClient.sharedClient.startObservingUser(completion: {
                self.retrieveCustomer({ (customer, error) in
                    completion(customer,error)
                })
            })
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
        print("unsubscribeUser")
        
        let pathExtension =  "/unsubscribeUser"
        guard let customerId = currentUser.stripeID else {
            completion("Error", "Please contact support@GetToastApp.com - Error stripeID")
            print("Backend Error: - No customer ID in current User")
            return
        }
        let params = ["customerID":customerId] as [String:String]
        
        let request = createRequest(pathExtension: pathExtension, params: params)
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                let (decodedError, _) = self.decodeResponse(urlResponse,data:data!, error: error as NSError?)
                if decodedError != nil {
                    completion("Error unsubscribing","Please contact support@GetToastApp.com - error \(error?.localizedDescription)")
                    return
                }
                guard data != nil else {
                    print("Backend: No data returned")
                    completion("Error unsubscribing","Please contact support@GetToastApp.com - No data")
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                    if let error = json["Error"]{
                        print("Error unsubscribing -\(error)")
                        completion("Error","Failed to Unsubscribe, Please contact support@GetToastApp.com - error \(error)")
                        return

                    }
                    guard let status = json["status"] as? String, let message = json["message"] as? String else {
                        completion("Error unsubscribing","Please contact support@GetToastApp.com")
                        return
                    }
                    if status == "Success" {
                        print("Success unsubscribing")
                        currentUser.membership = membershipLevels.basic
                        
                    }
                    completion(status,message)
                } catch {
                    print("Error serializing json")
                    completion("Error unsubscribing","Please contact support@GetToastApp.com")
                }
            }
        }
        task.resume()
    }
    /**
     *  Adds a payment source to a customer. On your backend, retrieve the Stripe customer associated with your logged-in user. Then, call the Update Customer method on that customer as described at https://stripe.com/docs/api#update_customer (for an example Ruby implementation of this API, see https://github.com/stripe/example-ios-backend/blob/master/web.rb#L60 ). If this API call succeeds, call `completion(nil)`. Otherwise, call `completion(error)` with the error that occurred.
     *
     *  @param source     a valid payment source, such as a card token.
     *  @param completion call this callback when you're done adding the token to the customer on your backend. For example, `completion(nil)` (if your call succeeds) or `completion(error)` if an error is returned.
     *
     */
     func attachSource(toCustomer source: STPSource, completion: @escaping STPErrorBlock) {
        print("attachSource")

        let pathExtension = "/customer/sources"
        print("Sending source \(source.stripeID)")
        let params: [String: Any] = [
            "sourceID": source.stripeID,
            "customerID": currentUser.stripeID!
            ]
        let request = createRequest(pathExtension: pathExtension, params: params)
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                let (decodedError, _) = self.decodeResponse(urlResponse,data:data!, error: error as NSError?)
                if decodedError != nil {
                    print("Backend: Error with attachSource - \(error?.localizedDescription)")
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
        task.resume()
    }
    
    /**
     Changes the default source (card) that a customer uses to pay
 */
    func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
        print("selectDefaultCustomerSource")
        let pathExtension = "/customer/default_source"
        let params = [
            "sourceID": source.stripeID,
            "customerID": currentUser.stripeID
        ]
        let request = createRequest(pathExtension: pathExtension, params: params)
        let task = self.session.dataTask(with: request) { (data, urlResponse, error) in
            DispatchQueue.main.async {
                let (decodedError, _) = self.decodeResponse(urlResponse,data:data!, error: error as NSError?)
                if decodedError != nil {
                    print("Backend: Error with default source -\(error?.localizedDescription)")
                    completion(decodedError)
                    return}
                }
                completion(nil)
            }
    task.resume()

    }
}

