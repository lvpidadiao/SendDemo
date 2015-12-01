//
//  AlamofireManager.swift
//  SendDemo
//
//  Created by ProfessorTrevor on 15/11/23.
//  Copyright © 2015年 ProfessorTrevor. All rights reserved.
//

import Foundation
import Alamofire

class SendNetworkCommunication: NSObject, NSURLSessionTaskDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate {
//    var Manager: Alamofire.Manager = {
//        let serverTrustPolicies: [String: ServerTrustPolicy] = [
//        "192.168.0.109:443": .DisableEvaluation
//        ]
//        
//        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
////        let man = Alamofire.Manager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
//        return man
//    }()
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
    }
    
}