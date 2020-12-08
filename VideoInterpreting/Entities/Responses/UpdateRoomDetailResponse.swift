//
//  UpdateRoomDetailResponse.swift
//  VideoInterpreting
//
//  Created by Muhammad Zeeshan on 01/12/2020.
//

import Foundation
import ObjectMapper

public class UpdateRoomDetailResponse: ApiResponse {
    
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
