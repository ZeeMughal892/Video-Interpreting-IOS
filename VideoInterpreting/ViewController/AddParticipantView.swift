//
//  AddParticipantView.swift
//  VideoInterpreting
//
//  Created by Muhammad Zeeshan on 09/12/2020.
//

import UIKit
import RappleProgressHUD

class AddParticipantView : UIView{
    
    static let instance = AddParticipantView()
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var lblSubHead: UILabel!
    @IBOutlet weak var alertView: CardView!
    @IBOutlet weak var btnSend: UIButton!

    public static var MeetingVC: MeetingViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("AddParticipantView", owner: self, options: nil)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func commonInit(){
        parentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        alertView.borderWidth = 1.0
        parentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
    func showAlert(){
        UIApplication.shared.keyWindow?.addSubview(parentView)
    }
    @IBAction func actionSend(_ sender: Any) {
        if(txtEmail.text ?? "").isEmpty || (txtMobile.text ?? "").isEmpty{
            lblSubHead.textColor = .red
            self.txtEmail.becomeFirstResponder()
        }else{
            RappleActivityIndicatorView.startAnimating()
            let request = SendInvitationRequest()
            request.UserEmail = txtEmail.text
            request.MobileNo = txtMobile.text
            request.MeetingID = MeetingViewController.authModel.MeetingID
            request.UserInviteBy = MeetingViewController.authModel.Identity
            request.MeetingDetailID = MeetingViewController.authModel.MeetingDetailID
            ApiManager.api.SendInvite(method: MethodTypes.Post.rawValue, url: ApiUrls.sendInvite, request: request, viewController: AddParticipantView.MeetingVC).done { response in
                AddParticipantView.MeetingVC.showToast(message: "\(response.Message)", font: .systemFont(ofSize: 10.0))
            }.catch
            {
                error in Modals.CreateAlert(title: "", message: error.localizedDescription, ViewController: AddParticipantView.MeetingVC)
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    @IBAction func actionDismiss(_ sender: Any) {
        parentView.removeFromSuperview()
    }
    func SuccessAlertView(title: String! ,message: String!){
        let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        dismiss.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        let alert = UIAlertController(title: "Successfull", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(dismiss)
    }
}
