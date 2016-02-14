//
//  AboutViewController.swift
//  Sieve
//
//  Created by Colin Biafore on 2/13/16.
//  Copyright © 2016 Colin Biafore. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {


    @IBOutlet weak var myPhotoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPhotoView.contentMode = UIViewContentMode.ScaleAspectFit
        myPhotoView.image = UIImage(named: "myPhoto")
 

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
