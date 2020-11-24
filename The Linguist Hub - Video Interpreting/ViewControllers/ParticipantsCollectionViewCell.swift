//
//  ParticipantsCollectionViewCell.swift
//  The Linguist Hub - Video Interpreting
//
//  Created by Muhammad Zeeshan on 15/10/2020.
//  Copyright © 2020 Language Empire. All rights reserved.
//

import UIKit
import TwilioVideo

class ParticipantsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var imgNetwork: UIImageView!
    @IBOutlet weak var imgNoMic: UIImageView!
    @IBOutlet weak var viewPlaceholder: UIView!
        
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var lblParticipantName: UILabel!
    @IBOutlet weak var participantVideo: VideoView!
    @IBOutlet weak var imgParticipantNetwork: UIImageView!
    @IBOutlet weak var imgParticipantNoMic: UIImageView!
}
