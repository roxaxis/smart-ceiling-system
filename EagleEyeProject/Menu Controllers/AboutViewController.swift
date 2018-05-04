//
//  AboutViewController.swift
//  EagleEyeProject
//
//  Created by Ahmet Hasırcıoğlu on 3.05.2018.
//  Copyright © 2018 Ahmet Hasırcıoğlu. All rights reserved.
//

import UIKit
import InteractiveSideMenu


class AboutViewController: UIViewController,SideMenuItemContent,Storyboardable {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func openMenu(_ sender: UIButton) {
        showSideMenu()
    }

}
