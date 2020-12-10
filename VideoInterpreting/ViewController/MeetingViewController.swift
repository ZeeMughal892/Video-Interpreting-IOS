//
//  MeetingViewController.swift
//  VideoInterpreting
//
//  Created by Muhammad Zeeshan on 01/12/2020.
//

import UIKit
import RappleProgressHUD
import TwilioVideo
import SWRevealViewController

class MeetingViewController: UIViewController {
 
    @IBOutlet weak var viewPLeft: UIView!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var primaryVideoView: VideoView!
    @IBOutlet weak var lblUsername: PaddingLabel!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnMic: UIButton!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var btnEndCall: UIButton!
    @IBOutlet weak var btnSwitchCamera: UIButton!
    @IBOutlet weak var btnSwitchAudio: UIButton!
    @IBOutlet weak var btnAddParticipant: UIButton!
    @IBOutlet weak var participantCollectionView: UICollectionView!
    @IBOutlet weak var lblPUsername: UILabel!
    @IBOutlet weak var viewPRight: UIView!
    
    public static var MessageVC : MessagesViewController!
    var delegate: RemoteDataTrackDelegate?
    var room: Room?
    var camera: CameraSource?
    var localAudioTrack : LocalAudioTrack!
    public static var localDataTrack = LocalDataTrack()
    var localVideoTrack : LocalVideoTrack!
    var localParticipant : LocalParticipant!
        
    public static var authModel = GetTokenResponse()
    var endMeetingModel = EndProcessResponse()
    var updateRoomDetailModel = UpdateRoomDetailResponse()
    var remoteParticipantIdentity : String!
    var remoteParticipants = [RemoteParticipant]()
    var remoteVideoTracks : [RemoteVideoTrack] = []
    
    
    deinit {
        // We are done with camera
        if let camera = self.camera {
            camera.stopCapture()
            self.camera = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        participantCollectionView.dataSource = self
        participantCollectionView.delegate = self
        HideKeyboard()
        
        self.startPreview()
        self.prepareLocalMedia()
        self.connectToRoom(roomName: MeetingViewController.authModel.RoomName, token: MeetingViewController.authModel.Token)
        
        let revealController = revealViewController()
        revealController?.panGestureRecognizer()
        revealController?.tapGestureRecognizer()
    }
    
    @IBAction func actionChat(_ sender: Any) {
        self.revealViewController()?.revealToggle(self)
    }

    @IBAction func actionMic(_ sender: Any) {
        if(localAudioTrack != nil){
            let enable = !localAudioTrack!.isEnabled
            localAudioTrack?.isEnabled = enable
            if (enable) {
                self.btnMic.setImage(UIImage(named: "IcoMic"), for: .normal)
            } else {
                self.btnMic.setImage(UIImage(named: "IcoNoMic"), for: .normal)
            }
        }
    }
    @IBAction func actionVideo(_ sender: Any) {
        if localVideoTrack != nil {
            let enable = !localVideoTrack!.isEnabled
            localVideoTrack?.isEnabled = enable
            if enable {
                self.btnVideo.setImage(UIImage(named: "IcoVideoCamera"), for: .normal)
                placeholderView.isHidden = true
                primaryVideoView.isHidden = false
                lblUsername.text = localParticipant.identity
                self.btnSwitchCamera.isHidden = false
                self.viewPLeft.isHidden = true
                lblUsername.isHidden = false
                lblPUsername.text = ""
            }else{
                self.btnVideo.setImage(UIImage(named: "IcoNoVideoCamera"), for: .normal)
                placeholderView.isHidden = false
                primaryVideoView.isHidden = true
                lblUsername.isHidden = true
                self.btnSwitchCamera.isHidden = true
                self.viewPLeft.isHidden = false
                lblPUsername.text = localParticipant.identity
            }
        }
    }
    @IBAction func actionEndCall(_ sender: Any) {
        if MeetingViewController.authModel.IsHost {
            RappleActivityIndicatorView.startAnimating()
            let request = EndProcessRequest()
            request.MeetingDetailID = MeetingViewController.authModel.MeetingDetailID
            request.ParticipantSID = localParticipant.sid
            ApiManager.api.EndHostMeeting(method: MethodTypes.Post.rawValue, url: ApiUrls.endHostMeeting, request: request, viewController: self).done { response in
                RappleActivityIndicatorView.stopAnimation()
                self.endMeetingModel = response
                if self.room != nil && self.room?.state != Room.State.disconnected {
                  
                    self.room?.disconnect()
                    //self.showToast(message: "Meeting has been ended by Host at \(self.endMeetingModel.MeetingEndDateTime))", font: .systemFont(ofSize: 12.0))
                    let mainVC = self.storyboard?.instantiateViewController(withIdentifier:"StartMeetingViewController") as! StartMeetingViewController
                    mainVC.modalPresentationStyle = .fullScreen
                    if self.localAudioTrack != nil {
                        self.localAudioTrack = nil
                    }
                    if self.localVideoTrack != nil {
                        self.localVideoTrack = nil
                    }
                    if MeetingViewController.localDataTrack != nil {
                        MeetingViewController.localDataTrack = nil
                    }
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
    @IBAction func actionSwitchCamera(_ sender: Any) {
        self.flipCamera()
    }
    @IBAction func actionSwitchAudio(_ sender: Any) {
     
    }
    @IBAction func actionAddParticipant(_ sender: Any) {
        AddParticipantView.instance.showAlert()
        
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
                self.btnSwitchCamera.addGestureRecognizer(tap)
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
    func connectToRoom(roomName:String, token: String){
        let connectOptions = ConnectOptions(token: token) { (builder) in
            builder.roomName = roomName
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [LocalVideoTrack]()
            if let localDataTrack = MeetingViewController.localDataTrack {
                    builder.dataTracks = [localDataTrack]
            }
            builder.encodingParameters = EncodingParameters(audioBitrate: 160000, videoBitrate: 25000000)
            builder.isDominantSpeakerEnabled = true
            builder.isNetworkQualityEnabled = true
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
        self.room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
    }
    func addRemoteParticipant(remoteParticipant: RemoteParticipant){
        self.remoteParticipantIdentity = remoteParticipant.identity
        remoteParticipant.delegate = self
        if remoteParticipant.remoteVideoTracks.count > 0 {
            let remoteVideoTrackPublication = remoteParticipant.remoteVideoTracks[0]
            if remoteVideoTrackPublication.isTrackSubscribed {
                addRemoteParticipantVideo(videoTrack: remoteVideoTrackPublication.remoteTrack!)
            }
        }else{
            remoteParticipants.append(remoteParticipant)
            self.participantCollectionView.reloadData()
        }
    }
    func addRemoteParticipantVideo(videoTrack: RemoteVideoTrack){
        for participant in room!.remoteParticipants{
            if participant.remoteVideoTracks.count > 0 {
                let remoteVideoTrackPublication = participant.remoteVideoTracks[0]
                if remoteVideoTrackPublication.trackSid == videoTrack.sid {
                    remoteParticipants.append(participant)
                }
            }
        }       
        self.participantCollectionView.reloadData()
    }
    func removeRemoteParticipant(remoteParticipant: RemoteParticipant){
        guard let index = remoteParticipants.firstIndex(where: { $0.sid == remoteParticipant.sid }) else { return }
        remoteParticipants.remove(at: index)
        self.participantCollectionView.reloadData()
    }
}
extension MeetingViewController: UICollectionViewDataSource, UICollectionViewDelegate {    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return remoteParticipants.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParticipantCell", for: indexPath) as! ParticipantCell
        cell.setRemoteParticipant(remoteParticipant: remoteParticipants[indexPath.row])            
        return cell
    }
}
extension MeetingViewController : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        self.showToast(message: "Camera source failed with error: \(error.localizedDescription)", font: .systemFont(ofSize: 12.0))
    }
}
extension MeetingViewController : RoomDelegate{
    func roomDidConnect(room: Room) {
        self.localParticipant = room.localParticipant
        lblUsername.text = room.localParticipant?.identity
        MessagesViewController.localName = localParticipant.identity
        self.localParticipant.publishDataTrack(MeetingViewController.localDataTrack!)
        self.localParticipant.publishVideoTrack(localVideoTrack)
        for remoteParticipant in room.remoteParticipants {
            addRemoteParticipant(remoteParticipant: remoteParticipant)
        }        
        if MeetingViewController.authModel.IsHost {
            self.btnAddParticipant.isHidden = false
            self.viewPRight.isHidden = true
            let request  = UpdateRoomDetailRequest()
            request.MeetingID = MeetingViewController.authModel.MeetingID
            request.RoomSID = room.sid
            ApiManager.api.UpdateRoomDetail(method: MethodTypes.Post.rawValue, url: ApiUrls.updateRoomDetail, request: request, viewController: self).done { response in
                self.updateRoomDetailModel = response
            }.catch
            {
                error in Modals.CreateAlert(title: "", message: error.localizedDescription, ViewController: self)
                RappleActivityIndicatorView.stopAnimation()
            }
        }
        else{
            self.btnAddParticipant.isHidden = true
            self.viewPRight.isHidden = false
        }
    }
    func roomDidFailToConnect(room: Room, error: Error) {
    }
    func roomIsReconnecting(room: Room, error: Error) {
        RappleActivityIndicatorView.startAnimatingWithLabel("Reconnecting...")
    }
    func roomDidReconnect(room: Room) {
        RappleActivityIndicatorView.stopAnimation()
    }
    func roomDidDisconnect(room: Room, error: Error?) {
        localParticipant = nil
        self.room = nil
        room.disconnect()
    }
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        addRemoteParticipant(remoteParticipant: participant)
        self.showToast(message: "Participant Connected : \(participant.identity)", font: .systemFont(ofSize: 12.0))
    }
    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        removeRemoteParticipant(remoteParticipant: participant)
        self.showToast(message: "Participant Disconnected : \(participant.identity)", font: .systemFont(ofSize: 12.0))
    }
    func roomDidStartRecording(room: Room) {
    }
    func roomDidStopRecording(room: Room) {
    }
}
extension MeetingViewController : RemoteParticipantDelegate, RemoteDataTrackDelegate {
    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
    }
    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
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
    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        self.addRemoteParticipantVideo(videoTrack: videoTrack)
    }
    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
    }
    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
    }
    func remoteParticipantDidPublishDataTrack(participant: RemoteParticipant, publication: RemoteDataTrackPublication) {
    }
    func remoteParticipantDidUnpublishDataTrack(participant: RemoteParticipant, publication: RemoteDataTrackPublication) {
    }
    func didSubscribeToDataTrack(dataTrack: RemoteDataTrack, publication: RemoteDataTrackPublication, participant: RemoteParticipant) {
        dataTrack.delegate = self
    }
    func remoteDataTrackDidReceiveData(remoteDataTrack: RemoteDataTrack, message: Data) {
    }
    func remoteDataTrackDidReceiveString(remoteDataTrack: RemoteDataTrack, message: String) {
        for participant in room!.remoteParticipants{
            if participant.remoteDataTracks[0].trackSid == remoteDataTrack.sid {
                let msg = Message(text: message, isIncoming: true, name: participant.identity)
                MessagesViewController.chatMessages.append(msg)
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
    }
    func didFailToSubscribeToDataTrack(publication: RemoteDataTrackPublication, error: Error, participant: RemoteParticipant) {
    }
    func didUnsubscribeFromDataTrack(dataTrack: RemoteDataTrack, publication: RemoteDataTrackPublication, participant: RemoteParticipant) {
    }
    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        self.participantCollectionView.reloadData()
    }
    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        self.participantCollectionView.reloadData()
    }
    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        self.participantCollectionView.reloadData()
    }
    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {        
        self.participantCollectionView.reloadData()
    }
}
