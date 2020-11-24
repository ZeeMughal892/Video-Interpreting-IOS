//
//  MeetingViewController.swift
//  The Linguist Hub - Video Interpreting
//
//  Created by Muhammad Zeeshan on 23/11/2020.
//  Copyright © 2020 Language Empire. All rights reserved.
//

import UIKit
import TwilioVideo
import RappleProgressHUD
import CallKit

class MeetingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var room: Room?
    var camera: CameraSource?
    var localAudioTrack: LocalAudioTrack?
    var localDataTrack = LocalDataTrack()
    var localVideoTrack : LocalVideoTrack?
    var localParticipant : LocalParticipant!
    var remoteParticipants: [RemoteParticipant] = []
    var remoteVideoTracks : [RemoteVideoTrack] = []
    
    @IBOutlet weak var placeholder: UIView!
    var remoteParticipantIdentity:String!
    var i = 0
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnMic: UIButton!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var btnEndCall: UIButton!
    @IBOutlet weak var btnSwitchCamera: UIButton!
    @IBOutlet weak var btnAudio: UIButton!
    @IBOutlet weak var lblLocalUsername: PaddingLabel!
    @IBOutlet weak var btnAddParticipant: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtLocalUsername: UILabel!
    
    var audioDevice: DefaultAudioDevice = DefaultAudioDevice()
    @IBOutlet weak var primaryVideoView: VideoView!
    public static var authModel = GetTokenResponse()
    @IBOutlet weak var btnSpare: UIButton!
        
    var endMeetingModel = EndProcessResponse()

    
    deinit {
        // We are done with camera
        if let camera = self.camera {
            camera.stopCapture()
            self.camera = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        placeholder.isHidden = true
        
        if !MeetingViewController.authModel.IsHost {
            btnSpare.isHidden = false
            self.btnAddParticipant.isHidden = true
        }
        if PlatformUtils.isSimulator {
            self.primaryVideoView.removeFromSuperview()
        } else {
            self.startPreview()
            self.prepareLocalMedia()
            let connectOptions = ConnectOptions(token: MeetingViewController.authModel.Token) { (builder) in
                builder.roomName = MeetingViewController.authModel.RoomName
                builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()
                builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [LocalVideoTrack]()
                builder.dataTracks = self.localDataTrack != nil ? [self.localDataTrack!] : [LocalDataTrack]()
                builder.encodingParameters = EncodingParameters(audioBitrate: 160000, videoBitrate: 25000000)
                builder.isDominantSpeakerEnabled = true
                builder.isNetworkQualityEnabled = true
                builder.region = "ie1"
                builder.isAutomaticSubscriptionEnabled = true
                let videoOptions = VideoBandwidthProfileOptions(){
                    (builder) in
                    builder.mode = BandwidthProfileMode.collaboration
                    builder.trackSwitchOffMode = .predicted
                    builder.dominantSpeakerPriority = .high
                    builder.maxTracks = 3
                    let renderDimensions = VideoRenderDimensions()
                    renderDimensions.low = VideoDimensions(width: 352, height: 288)
                    renderDimensions.standard = VideoDimensions(width: 640, height: 480)
                    renderDimensions.high = VideoDimensions(width: 1280, height: 720)
                    builder.renderDimensions = renderDimensions
                }
                builder.networkQualityConfiguration = NetworkQualityConfiguration(localVerbosity: NetworkQualityVerbosity.minimal, remoteVerbosity: NetworkQualityVerbosity.minimal)
                builder.bandwidthProfileOptions = BandwidthProfileOptions(videoOptions: videoOptions)
                builder.preferredAudioCodecs = [ IsacCodec() ]
                builder.preferredVideoCodecs = [ Vp9Codec() ]
            }
            room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
        }
    }
   
    @IBAction func actionAddParticipant(_ sender: Any) {
        print("Add Participant")
    }
    @IBAction func actionAudioSwitch(_ sender: Any) {
     
    }
    @IBAction func actionCameraSwitch(_ sender: Any) {
        flipCamera()
        print("Camera Switch")
    }
    @IBAction func actionEndCall(_ sender: Any) {
        if MeetingViewController.authModel.IsHost {
            RappleActivityIndicatorView.startAnimating()
            let request = EndProcessRequest()
            request.MeetingDetailID = MeetingViewController.authModel.MeetingDetailID
            request.ParticipantSID = localParticipant.sid
            ApiManager.api.EndHostMeeting(method: MethodTypes.Post.rawValue, url: ApiUrls.endHostMeeting, request: request, viewController: self).done { response in
                self.endMeetingModel = response
                if self.room != nil && self.room?.state != Room.State.disconnected {
                    self.room?.disconnect()
                    let mainVC = self.storyboard?.instantiateViewController(withIdentifier:"StartMeetingViewController") as! StartMeetingViewController
                    mainVC.modalPresentationStyle = .fullScreen
                    self.present(mainVC,animated:true,completion:nil)
                }
            }.catch
            {
                error in Modals.CreateAlert(title: "", message: error.localizedDescription, ViewController: self)
                RappleActivityIndicatorView.stopAnimation()
            }
        }else{
            RappleActivityIndicatorView.startAnimating()
            let request = EndProcessRequest()
            request.MeetingDetailID = MeetingViewController.authModel.MeetingDetailID
            request.ParticipantSID = localParticipant.sid
            ApiManager.api.EndParticipantMeeting(method: MethodTypes.Post.rawValue, url: ApiUrls.endParticipantMeeting, request: request, viewController: self).done { response in
                self.endMeetingModel = response
                if self.room != nil && self.room?.state != Room.State.disconnected {
                    self.room?.disconnect()
                    let mainVC = self.storyboard?.instantiateViewController(withIdentifier:"StartMeetingViewController") as! StartMeetingViewController
                    mainVC.modalPresentationStyle = .fullScreen
                    self.present(mainVC,animated:true,completion:nil)
                }
            }.catch
            {
                error in Modals.CreateAlert(title: "", message: error.localizedDescription, ViewController: self)
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    @IBAction func actionVideo(_ sender: Any) {
        if localVideoTrack != nil {
            let enable = !localVideoTrack!.isEnabled
            localVideoTrack?.isEnabled = enable
            if enable {
                self.btnVideo.setImage(UIImage(named: "IcoVideoCamera"), for: .normal)
                placeholder.isHidden = true
                primaryVideoView.isHidden = false
                txtLocalUsername.text = localParticipant.identity
                self.btnSwitchCamera.isHidden = false
                lblLocalUsername.text = ""
            }else{
                self.btnVideo.setImage(UIImage(named: "IcoNoVideoCamera"), for: .normal)
                placeholder.isHidden = false
                primaryVideoView.isHidden = true
                txtLocalUsername.text = ""
                self.btnSwitchCamera.isHidden = true
                lblLocalUsername.text = localParticipant.identity
            }
        }
    }
    @IBAction func actionMic(_ sender: Any) {
        if(localAudioTrack != nil){
            let enable = !localAudioTrack!.isEnabled
            localAudioTrack?.isEnabled = enable
            if (!enable) {
                self.btnAudio.setImage(UIImage(named: "IcoMic"), for: .normal)
            } else {
                self.btnAudio.setImage(UIImage(named: "IcoNoMic"), for: .normal)
            }
        }
    }
    @IBAction func actionChat(_ sender: Any) {
        print("Chat")
    }   
    func startPreview() {
        if PlatformUtils.isSimulator {
            return
        }
        let frontCamera = CameraSource.captureDevice(position: .front)
        let backCamera = CameraSource.captureDevice(position: .back)
        if (frontCamera != nil || backCamera != nil) {
            camera = CameraSource(delegate: self)
            localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")
            localVideoTrack!.addRenderer(self.primaryVideoView)
            if (frontCamera != nil && backCamera != nil) {
                let tap = UITapGestureRecognizer(target: self, action: #selector(MeetingViewController.flipCamera))
                self.primaryVideoView.addGestureRecognizer(tap)
            }
            camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
                if let error = error {
                    Modals.CreateAlert(title: "", message: "Capture failed with error.\ncode = \((error as NSError).code) error = \(error.localizedDescription)", ViewController: self)
                } else {
                    self.primaryVideoView.shouldMirror = (captureDevice.position == .front)
                }
            }
        }
        else {
            Modals.CreateAlert(title: "", message: "No front or back capture device found!", ViewController: self)
        }
    }
    @objc func flipCamera() {
        var newDevice: AVCaptureDevice?
        if let camera = self.camera, let captureDevice = camera.device {
            if captureDevice.position == .front {
                newDevice = CameraSource.captureDevice(position: .back)
            } else {
                newDevice = CameraSource.captureDevice(position: .front)
            }
            if let newDevice = newDevice {
                camera.selectCaptureDevice(newDevice) { (captureDevice, videoFormat, error) in
                    if let error = error {
                        Modals.CreateAlert(title: "", message: "Error selecting capture device.\ncode = \((error as NSError).code) error = \(error.localizedDescription)", ViewController: self)
                    } else {
                        self.primaryVideoView.shouldMirror = (captureDevice.position == .front)
                    }
                }
            }
        }
    }
    func prepareLocalMedia() {
        if (localAudioTrack == nil) {
            localAudioTrack = LocalAudioTrack(options: nil, enabled: true, name: "Microphone")
            if (localAudioTrack == nil) {
                self.showToast(message: "Failed to create audio track", font: .systemFont(ofSize: 12.0))
            }
        }
        if (localVideoTrack == nil) {
            self.startPreview()
        }
    }
    
    func addRemoteParticipant(remoteParticipant: RemoteParticipant){
        remoteParticipantIdentity = remoteParticipant.identity
        if remoteParticipant.remoteVideoTracks.count > 0 {
            let remoteVideoTrackPublication = remoteParticipant.remoteVideoTracks[0]
            if remoteVideoTrackPublication.isTrackSubscribed {
                addRemoteParticipantVideo(remoteVideoTrack: remoteVideoTrackPublication.remoteTrack!)
            }
        }
        remoteParticipant.delegate = self
    }
    func addRemoteParticipantVideo(remoteVideoTrack: RemoteVideoTrack){
        for participant in room!.remoteParticipants {
            let remoteVideoPublication = participant.remoteVideoTracks[0]
            if remoteVideoPublication.trackSid == remoteVideoTrack.sid {
                remoteParticipants.append(participant)
                remoteVideoTracks.append(remoteVideoTrack)
            }
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GeneralTableViewCell {
           cell.collectionView.reloadData()
        }
    }
    func removeRemoteParticipant(remoteParticipant: RemoteParticipant){
        guard let index = remoteParticipants.firstIndex(where: { $0.identity == remoteParticipant.identity }) else { return }
        remoteParticipants.remove(at: index)
        removeRemoteParticipantVideo(remoteVideoTrack: remoteParticipant.remoteVideoTracks[0].remoteTrack!)
        
    }
    func removeRemoteParticipantVideo(remoteVideoTrack: RemoteVideoTrack){
        guard let indexa = remoteVideoTracks.firstIndex(where: { $0.sid == remoteVideoTrack.sid }) else { return }
        remoteVideoTracks.remove(at: indexa)
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GeneralTableViewCell {
            cell.collectionView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeneralTableViewCell") as! GeneralTableViewCell
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? GeneralTableViewCell{
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            //cell.collectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.collectionView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 960.0
    }
}

extension MeetingViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return remoteVideoTracks.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParticipantsCollectionViewCell", for: indexPath) as! ParticipantsCollectionViewCell
        //cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        if indexPath.row <= remoteParticipants.count - 1 {
            if remoteVideoTracks[indexPath.row].isEnabled{
                cell.viewPlaceholder.isHidden = true
                cell.participantVideo.isHidden = false
                cell.videoView.isHidden = false
                cell.participantVideo.shouldMirror = true
                cell.lblParticipantName.text = remoteParticipants[indexPath.row].identity
                remoteVideoTracks[indexPath.row].addRenderer(cell.participantVideo)
            }else{
                cell.participantVideo.isHidden = true
                cell.viewPlaceholder.isHidden = false
                cell.videoView.isHidden = true
                cell.lblUsername.text = remoteParticipants[indexPath.row].identity
            }
            cell.imgNetwork.isHidden = false
            cell.imgParticipantNetwork.isHidden = false
            if remoteParticipants[indexPath.row].networkQualityLevel == NetworkQualityLevel.zero {
                cell.imgNetwork.image = UIImage(named: "network_quality_level_0")
                cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_0")
            }else if remoteParticipants[indexPath.row].networkQualityLevel == NetworkQualityLevel.one {
                cell.imgNetwork.image = UIImage(named: "network_quality_level_1")
                cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_1")
            }else if remoteParticipants[indexPath.row].networkQualityLevel == NetworkQualityLevel.two {
                cell.imgNetwork.image = UIImage(named: "network_quality_level_2")
                cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_2")
            }else if remoteParticipants[indexPath.row].networkQualityLevel == NetworkQualityLevel.three {
                cell.imgNetwork.image = UIImage(named: "network_quality_level_3")
                cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_3")
            }else if remoteParticipants[indexPath.row].networkQualityLevel == NetworkQualityLevel.four {
                cell.imgNetwork.image = UIImage(named: "network_quality_level_4")
                cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_4")
            }else if remoteParticipants[indexPath.row].networkQualityLevel == NetworkQualityLevel.five {
                cell.imgNetwork.image = UIImage(named: "network_quality_level_5")
                cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_5")
            }else{
                cell.imgNetwork.isHidden = true
                cell.imgParticipantNetwork.isHidden = true
            }
            if !remoteParticipants[indexPath.row].remoteAudioTracks[0].isTrackEnabled {
                cell.imgNoMic.isHidden = false
                cell.imgParticipantNoMic.isHidden = false
            }else{
                cell.imgNoMic.isHidden = true
                cell.imgParticipantNoMic.isHidden = true
            }
        }else{
            if localParticipant != nil {
                if localVideoTrack!.isEnabled{
                    cell.viewPlaceholder.isHidden = true
                    cell.participantVideo.isHidden = false
                    cell.videoView.isHidden = false
                    cell.participantVideo.shouldMirror = true
                    cell.lblParticipantName.text = localParticipant.identity
                    localVideoTrack!.addRenderer(cell.participantVideo)
                    self.i  = 1
                }else{
                    cell.participantVideo.isHidden = true
                    cell.videoView.isHidden = true
                    cell.viewPlaceholder.isHidden = false
                    cell.lblUsername.text = localParticipant.identity
                }
                cell.imgNetwork.isHidden = false
                cell.imgParticipantNetwork.isHidden = false
                if localParticipant.networkQualityLevel == NetworkQualityLevel.zero {
                    cell.imgNetwork.image = UIImage(named: "network_quality_level_0")
                    cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_0")
                }else if localParticipant.networkQualityLevel == NetworkQualityLevel.one {
                    cell.imgNetwork.image = UIImage(named: "network_quality_level_1")
                    cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_1")
                }else if localParticipant.networkQualityLevel == NetworkQualityLevel.two {
                    cell.imgNetwork.image = UIImage(named: "network_quality_level_2")
                    cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_2")
                }else if localParticipant.networkQualityLevel == NetworkQualityLevel.three {
                    cell.imgNetwork.image = UIImage(named: "network_quality_level_3")
                    cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_3")
                }else if localParticipant.networkQualityLevel == NetworkQualityLevel.four {
                    cell.imgNetwork.image = UIImage(named: "network_quality_level_4")
                    cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_4")
                }else if localParticipant.networkQualityLevel == NetworkQualityLevel.five {
                    cell.imgNetwork.image = UIImage(named: "network_quality_level_5")
                    cell.imgParticipantNetwork.image = UIImage(named: "network_quality_level_5")
                }else{
                    cell.imgNetwork.isHidden = true
                    cell.imgParticipantNetwork.isHidden = true
                }
                if !localParticipant.audioTracks[0].isTrackEnabled {
                    cell.imgNoMic.isHidden = false
                    cell.imgParticipantNoMic.isHidden = false
                }else{
                    cell.imgNoMic.isHidden = true
                    cell.imgParticipantNoMic.isHidden = true
                }
            }
        }
        return cell
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0
        return CGSize(width: 128.0, height: 128.0)
    }
}

extension MeetingViewController: RoomDelegate{
    func roomDidConnect(room: Room) {
        self.showToast(message: "Connected to : \(room.name)", font: .systemFont(ofSize: 12.0))
        localParticipant = room.localParticipant
         lblLocalUsername.text = localParticipant.identity
        for participant in room.remoteParticipants {
            addRemoteParticipant(remoteParticipant: participant)
        }
    }
    func roomDidDisconnect(room: Room, error: Error?) {
        self.localParticipant = nil
        RappleActivityIndicatorView.stopAnimation()
        self.room = nil
    }
    func roomDidFailToConnect(room: Room, error: Error) {
        self.room = nil
    }
    func roomIsReconnecting(room: Room, error: Error) {
        RappleActivityIndicatorView.startAnimating()
    }
    func roomDidReconnect(room: Room) {
        RappleActivityIndicatorView.stopAnimation()
    }
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        self.showToast(message: "Participant Connected : \(participant.identity)", font: .systemFont(ofSize: 12.0))
        participant.delegate = self
        addRemoteParticipant(remoteParticipant: participant)
    }
    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        self.showToast(message: "Participant Disconnected : \(participant.identity)", font: .systemFont(ofSize: 12.0))
        removeRemoteParticipant(remoteParticipant: participant)
    }
}
extension MeetingViewController : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        self.showToast(message: "Camera source failed with error: \(error.localizedDescription)", font: .systemFont(ofSize: 12.0))
    }
}
extension MeetingViewController: RemoteParticipantDelegate {
    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        self.showToast(message: "Subscribed to : \(publication.trackName)", font: .systemFont(ofSize: 12.0))
        addRemoteParticipantVideo(remoteVideoTrack: videoTrack)
    }
    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
        self.showToast(message: "Failed to Subscribe to video : \(participant.identity)", font: .systemFont(ofSize: 12.0))
    }
    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        removeRemoteParticipantVideo(remoteVideoTrack: videoTrack)
    }
    func didSubscribeToAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
    }
    func didFailToSubscribeToAudioTrack(publication: RemoteAudioTrackPublication, error: Error, participant: RemoteParticipant) {
    }
    func didUnsubscribeFromAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
    }
    func remoteParticipantDidPublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
    }
    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
    }
    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
    }
    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
    }
    func didFailToSubscribeToDataTrack(publication: RemoteDataTrackPublication, error: Error, participant: RemoteParticipant) {
    }
    func didUnsubscribeFromDataTrack(dataTrack: RemoteDataTrack, publication: RemoteDataTrackPublication, participant: RemoteParticipant) {
    }
    func remoteParticipantDidChangeVideoTrackPublishPriority(participant: RemoteParticipant, priority: Track.Priority, publication: RemoteVideoTrackPublication) {
    }
    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GeneralTableViewCell {
           cell.collectionView.reloadData()
        }
    }
    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GeneralTableViewCell {
           cell.collectionView.reloadData()
        }
    }
    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GeneralTableViewCell {
           cell.collectionView.reloadData()
        }
    }
    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GeneralTableViewCell {
           cell.collectionView.reloadData()
        }
    }
    func didSubscribeToDataTrack(dataTrack: RemoteDataTrack, publication: RemoteDataTrackPublication, participant: RemoteParticipant) {
        dataTrack.delegate = self
    }
}
extension MeetingViewController : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}
extension MeetingViewController: RemoteDataTrackDelegate {
    func remoteDataTrackDidReceiveData(remoteDataTrack: RemoteDataTrack, message: Data) {
        
    }
    func remoteDataTrackDidReceiveString(remoteDataTrack: RemoteDataTrack, message: String) {
        
    }
}
extension UIViewController {
    func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 6.0, delay: 0.2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
