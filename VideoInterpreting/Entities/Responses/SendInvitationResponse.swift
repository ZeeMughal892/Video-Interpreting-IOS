//
//  SendInvitationResponse.swift
//  VideoInterpreting
//
//  Created by Muhammad Zeeshan on 09/12/2020.
//

import Foundation
import ObjectMapper

public class SendInvitationResponse: ApiResponse {
    
    public var MeetingID: Int!
    public var UserInviteBy: String!
    public var UserEmail: String!
    public var Status: String!
    public var Message: String!
    public var MeetingDetailID: Int!
    public var MobileNo: String!
    public var InvitationType:String!
  
    public override func mapping(map: Map) {
        super.mapping(map: map)
        MeetingID <- map["MeetingID"]
        UserInviteBy <- map["UserInviteBy"]
        UserEmail <- map["UserEmail"]
        Status <- map["Status"]
        Message <- map["Message"]
        MeetingDetailID <- map["MeetingDetailID"]
        MobileNo <- map["MobileNo"]
        InvitationType <- map["InvitationType"]
    }
    public override init() {
        super.init()
    }
    public required init?(map: Map) {
        super.init(map: map)
    }
}
