//
//  Utils.swift
//  The Linguist Hub - Video Interpreting
//
//  Created by Muhammad Zeeshan on 14/10/2020.
//  Copyright © 2020 Language Empire. All rights reserved.
//

import Foundation
struct PlatformUtils {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}
