//
//  EndProcessResponse.swift
//  The Linguist Hub - Video Interpreting
//
//  Created by Muhammad Zeeshan on 24/11/2020.
//  Copyright © 2020 Language Empire. All rights reserved.
//

import Foundation
import ObjectMapper

public class EndProcessResponse: ApiResponse {
    
    public var MeetingDetailID: String!
    public var ParticipantSID: String!
    public var Status: String!
    public var Message: String!
    public var MeetingID: Bool!
    public var RoomSID:Bool!
    public var HasMeetingEnd: String!
    public var MeetingEndDateTime: Int!
  
    public override func mapping(map: Map) {
        super.mapping(map: map)
        MeetingDetailID <- map["MeetingDetailID"]
        ParticipantSID <- map["ParticipantSID"]
        Status <- map["Status"]
        Message <- map["Message"]
        MeetingID <- map["MeetingID"]
        RoomSID <- map["RoomSID"]
        HasMeetingEnd <- map["HasMeetingEnd"]
        MeetingEndDateTime <- map["MeetingEndDateTime"]
    }
    public override init() {
        super.init()
    }
    public required init?(map: Map) {
        super.init(map: map)
    }
}
