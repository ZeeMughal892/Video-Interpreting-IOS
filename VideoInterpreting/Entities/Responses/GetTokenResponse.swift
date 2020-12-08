//
//  GetTokenResponse.swift
//  VideoInterpreting
//
//  Created by Muhammad Zeeshan on 01/12/2020.
//

import Foundation
import ObjectMapper

public class GetTokenResponse: ApiResponse {
    
    public var Identity: String!
    public var Token: String!
    public var RoomName: String!
    public var Status: String!
    public var Audio: Bool!
    public var Video:Bool!
    public var Message: String!
    public var MeetingStatusID: Int!
    public var StartDateTime:String!
    public var EndDateTime:String!
    public var MeetingID:Int!
    public var UserName: String!
    public var IsHost:Bool!
    public var MeetingDetailID:Int!
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        Identity <- map["Identity"]
        Token <- map["Token"]
        RoomName <- map["RoomName"]
        Status <- map["Status"]
        Audio <- map["Audio"]
        Video <- map["Video"]
        Message <- map["Message"]
        MeetingStatusID <- map["MeetingStatusID"]
        StartDateTime <- map["StartDateTime"]
        EndDateTime <- map["EndDateTime"]
        MeetingID <- map["MeetingID"]
        UserName <- map["UserName"]
        IsHost <- map["IsHost"]
        MeetingDetailID <- map["MeetingDetailID"]
    }
    public override init() {
        super.init()
    }
    public required init?(map: Map) {
        super.init(map: map)
    }
}
