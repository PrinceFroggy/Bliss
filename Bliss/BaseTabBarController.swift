//
//  BaseTabBarController.swift
//  Bliss
//
//  Created by Andrew Solesa on 2020-02-05.
//  Copyright © 2020 KSG. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController
{
    var m: DataModelManager!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let count = viewControllers?.count
        {
            for i in 0 ..< count
            {
                if let vc = viewControllers?[i] as? TabViewController
                {
                    vc.m = m
                }
            }
        }
        
        viewControllers!.forEach { $0.view }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
