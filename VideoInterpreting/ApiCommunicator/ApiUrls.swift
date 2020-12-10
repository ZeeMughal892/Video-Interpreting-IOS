//
//  ApiUrls.swift
//  The Linguist Hub - Video Interpreting
//
//  Created by Muhammad Zeeshan on 21/09/2020.
//  Copyright © 2020 Language Empire. All rights reserved.
//

import Foundation
import Alamofire

public class Connnectivity  {
    class var isInternetConnected : Bool {
        let connected = NetworkReachabilityManager()!.isReachable
        return connected;
    }
}

public struct ApiUrls {
    
    static let baseUrl = "https://192.168.18.23:4433/api/"
    static let localUrl = "https://videointerpreting.co.uk/api/"
    
    static let getToken = "\(ApiUrls.localUrl)Authentication/Token"
    static let endHostMeeting = "\(ApiUrls.localUrl)EndProcess/EndHostMeeting"
    static let updateRoomDetail = "\(ApiUrls.localUrl)EndProcess/UpdateRoomDetail"
    static let endParticipantMeeting = "\(ApiUrls.localUrl)EndProcess/EndParticipantMeeting"
    static let sendInvite = "\(ApiUrls.localUrl)Invitation/SendInvitationUser"
}
