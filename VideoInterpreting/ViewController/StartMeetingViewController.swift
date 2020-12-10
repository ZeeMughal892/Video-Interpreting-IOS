//
//  StartMeetingViewController.swift
//  VideoInterpreting
//
//  Created by Muhammad Zeeshan on 01/12/2020.
//

import UIKit
import RappleProgressHUD
import SWRevealViewController

class StartMeetingViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
    @IBOutlet weak var txtPin: UITextField!
    @IBOutlet weak var txtUserType: UITextField!
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var btnStartMeeting: UIButton!
    public var authModel = GetTokenResponse()
   
    var selectedOption: String?
    var optionList = ["Professional", "Interpreter", "Service User", "Guest"]
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HideKeyboard()   
        self.createPickerView()
        self.dismissPickerView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return optionList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return optionList[row]
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = optionList[row]
        pickerLabel?.textColor = UIColor.label
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedOption = optionList[row]
        txtUserType.text = selectedOption
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        txtUserType.inputView = pickerView
    }
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        txtUserType.inputAccessoryView = toolBar
    }
    @objc func action() {
        if txtUserType.text == "" {
            txtUserType.text = optionList[0]
        }
        view.endEditing(true)
    }
    
    @IBAction func actionStartMeeting(_ sender: Any) {
        if(txtUserType.text ?? "").isEmpty{
            Modals.CreateAlert(title: "", message:"Please Select User Type" , ViewController: self)
            self.txtUserType.becomeFirstResponder()
        }
        if(txtFullName.text ?? "").isEmpty{
            Modals.CreateAlert(title: "", message:"Please Enter Your Full Name" , ViewController: self)
            self.txtFullName.becomeFirstResponder()
        }
        if(txtPin.text ?? "").isEmpty{
            Modals.CreateAlert(title: "", message:"Please Enter Your Pincode" , ViewController: self)
            self.txtPin.becomeFirstResponder()
        }else{
            RappleActivityIndicatorView.startAnimating()
            let request = GetTokenRequest()
            request.Username = txtFullName.text! + " - " + txtUserType.text!
            request.PinCode = txtPin.text!
            ApiManager.api.GetToken(method: MethodTypes.Post.rawValue, url: ApiUrls.getToken, request: request, viewController: self).done { response in
                self.authModel = response
                if self.authModel.Status != "failed"{
                    RappleActivityIndicatorView.stopAnimation()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let meetingViewController = storyboard.instantiateViewController(withIdentifier:"SWRevealViewController") as! SWRevealViewController
                    MeetingViewController.authModel = response
                    meetingViewController.modalPresentationStyle = .fullScreen
                    self.present(meetingViewController,animated:true,completion:nil)
                }
                else{
                    Modals.CreateAlert(title: "", message: response.Message, ViewController: self)
                    RappleActivityIndicatorView.stopAnimation()
                }
            }.catch
            {
                error in Modals.CreateAlert(title: "", message: error.localizedDescription, ViewController: self)
                RappleActivityIndicatorView.stopAnimation()
            }
        }
    }
    

}

extension UIViewController {
    func HideKeyboard(){
        let Tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
    }
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
}
extension UIViewController {
    func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 25, y: self.view.frame.size.height-100, width: 200, height: 35))
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
