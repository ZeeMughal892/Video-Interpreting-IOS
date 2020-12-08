//
//  SplashViewController.swift
//  VideoInterpreting
//
//  Created by Muhammad Zeeshan on 01/12/2020.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
            let mainVC = self.storyboard?.instantiateViewController(withIdentifier:"StartMeetingViewController") as! StartMeetingViewController
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC,animated:true,completion:nil)
        }
    }
}
