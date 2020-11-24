//
//  SplashViewController.swift
//  The Linguist Hub - Video Interpreting
//
//  Created by Muhammad Zeeshan on 21/09/2020.
//  Copyright © 2020 Language Empire. All rights reserved.
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
