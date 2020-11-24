//
//  User.swift
//  The Linguist Hub - Video Interpreting
//
//  Created by Muhammad Zeeshan on 22/10/2020.
//  Copyright © 2020 Language Empire. All rights reserved.
//
import UIKit
import Foundation

struct User: MSGUser {
    
    var displayName: String
    
    var avatar: UIImage?
    
    var avatarUrl: URL?
    
    var isSender: Bool
    
}
