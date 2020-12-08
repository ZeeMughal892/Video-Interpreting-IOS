//
//  ParticipantCell.swift
//  VideoInterpreting
//
//  Created by Muhammad Zeeshan on 04/12/2020.
//

import UIKit
import TwilioVideo

class ParticipantCell: UICollectionViewCell {
    
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var identityLabel: UILabel!
    @IBOutlet weak var networkQualityImage: UIImageView!
    @IBOutlet weak var muteView: UIView!
    @IBOutlet weak var emptyView: UIView!
    var isFirst: Bool = true
    
    func setRemoteParticipant(remoteParticipant: RemoteParticipant){
        if isFirst  {
            identityLabel.text = remoteParticipant.identity
            if remoteParticipant.remoteAudioTracks[0].isTrackEnabled {
                muteView.isHidden = true
            }else {
                muteView.isHidden = false
            }
            if remoteParticipant.remoteVideoTracks.count == 0 {
                videoView.isHidden = true
                emptyView.isHidden = false
            }else{
                if remoteParticipant.remoteVideoTracks[0].isTrackEnabled {
                    videoView.isHidden = false
                    emptyView.isHidden = true
                    remoteParticipant.remoteVideoTracks[0].remoteTrack!.addRenderer(videoView)
                    isFirst = false
                }else{
                    videoView.isHidden = true
                    emptyView.isHidden = false
                }
            }
            if let imageName = remoteParticipant.networkQualityLevel.imageName {
                networkQualityImage.image = UIImage(named: imageName)
            } else {
                networkQualityImage.image = nil
            }
        }else{
            identityLabel.text = remoteParticipant.identity
            if remoteParticipant.remoteAudioTracks[0].isTrackEnabled {
                muteView.isHidden = true
            }else{
                muteView.isHidden = false
            }
            if remoteParticipant.remoteVideoTracks.count == 0 {
                videoView.isHidden = true
                emptyView.isHidden = false
            }else{
                if remoteParticipant.remoteVideoTracks[0].isTrackEnabled {
                    videoView.isHidden = false
                    emptyView.isHidden = true
                }else{
                    videoView.isHidden = true
                    emptyView.isHidden = false
                }
            }
            if let imageName = remoteParticipant.networkQualityLevel.imageName {
                networkQualityImage.image = UIImage(named: imageName)
            } else {
                networkQualityImage.image = nil
            }
        }
    }
}

extension NetworkQualityLevel {
    var imageName: String? {
        switch self {
        case .unknown: return nil
        case .zero: return "network_quality_level_0"
        case .one: return "network_quality_level_1"
        case .two: return "network_quality_level_2"
        case .three: return "network_quality_level_3"
        case .four: return "network_quality_level_4"
        case .five: return "network_quality_level_5"
        @unknown default:
            return nil
        }
    }
}
