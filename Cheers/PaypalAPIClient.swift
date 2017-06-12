//
//  MyPaypalAPIClient.swift
//  Cheers
//
//  Created by Charles Fayal on 6/11/17.
//  Copyright © 2017 Cheers. All rights reserved.
//

import Foundation


//TODO: Need to chekc up on payout to ensure it went through 

class PaypalAPIClient:RESTClient{
    static let sharedClient = PaypalAPIClient()
    
    func createPayout(amount:Int, recipient_type: String,receiver:String, completion:@escaping (_ error: Error?)->()){
        print("PaypalAPIClient: createPayout")
        let pathExtension = "/paypal/v1/payout"
        
        let params = ["recipient_type": recipient_type,
                      "receiver": receiver,
                      "amount": amount
            ] as [String : Any]
        
        _ = self.createRequest(pathExtension: pathExtension, params: params){
            (json, error) in
            if error != nil {
                completion(error)
            } else {
                if let json = json {
                    if let data = json["data"] as? [String:String]{
                        if let payout_batch_id = data["payout_batch_id"]{
                            print(payout_batch_id)
                            self.getPayout(payout_batch_id: payout_batch_id, completion: { (error) in
                                if error != nil {
                                    
                                    print(error?.localizedDescription)
                                } else {
                                    
                                }
                            })
                        }
                    }
                }
                completion(nil)
            }
            
        }
    }
    
    func getPayout(payout_batch_id:String, completion:@escaping (_ error: Error?)->()){
        print("PaypalAPIClient: getPayout")
        let pathExtension = "/paypal/v1/getPayout"
        
        let params = ["payout_batch_id": payout_batch_id
            ] as [String : Any]
        
        _ = self.createRequest(pathExtension: pathExtension, params: params){
            (json, error) in
            if error != nil {
                completion(error)
            } else {
                if let json = json {
                    print(json)
                    if let data = json["data"] as? [String:String]{
                        print(data)
                    }
                }
                completion(nil)
            }
            
        }
    }
}
