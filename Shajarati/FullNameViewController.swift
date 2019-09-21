//
//  FullNameViewController.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 31/7/2015.
//  Copyright (c) 2015 Abdulrahman Alattas. All rights reserved.
//

import Foundation
import UIKit

class FullNameViewController: UIViewController {
    
    @IBOutlet weak var imgPerson: UIImageView!
    @IBOutlet weak var frame: UIImageView!
    @IBOutlet weak var lblFullName: UITextView!
    @IBOutlet weak var WaitIndicator: UIActivityIndicatorView!
    
    var btnHome : UIBarButtonItem = UIBarButtonItem()
    var personID : String = ""
    
    var resultlist : [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonHome: UIButton = UIButton.init(type: UIButtonType.Custom)
        buttonHome.setImage(UIImage(named: "home.png"), forState: UIControlState.Normal)
        buttonHome.addTarget(self, action: #selector(self.btnHomeClicked(_:)), forControlEvents: .TouchDown)
        buttonHome.frame = CGRectMake(0, 0, 24, 24)
        btnHome = UIBarButtonItem(customView: buttonHome)
        self.navigationItem.setRightBarButtonItem(btnHome, animated: false)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let request = NSMutableURLRequest(URL: NSURL(string: AppDelegate().directoryurl + "a_fulltree.php")!)
        request.HTTPMethod = "POST"
        let postString = "android_id=\(defaults.stringForKey("hashnum")!)&id=\(self.personID)&shajarati=\(defaults.stringForKey("shajaratiDB")!)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("error #FullNameVC01 = \(error)")
                
                if (error!.code == -1005) || (error!.code == -1009){
                    dispatch_async(dispatch_get_main_queue()){
                        self.WaitIndicator.hidden = true
                        self.view.userInteractionEnabled = true
                        let alert: UIAlertView = UIAlertView()
                        alert.delegate = self
                        alert.tag = 1000
                        alert.title = "شجرتي"
                        alert.message = "عفواً، حدث خطأ في الاتصال بالخادم \r\n الرجاء المحاولة مرة اخرى"
                        alert.addButtonWithTitle("موافق")
                        alert.show()
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
                
                return
            }
            do{
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
                if let myStructuredData = jsonData as? [[String: AnyObject]] {
                    for resultname in myStructuredData{
                        self.resultlist.append(resultname)
                    }
                }
            }catch{ print("error #FullNameVC02 = \(error)") }
            dispatch_async(dispatch_get_main_queue()){
                self.WaitIndicator.hidden = true
                
                self.lblFullName.text = self.resultlist[0]["fullname"] as! String
                
                
                if((self.resultlist[0]["died"] as? String) != ""){
                    self.frame.image = UIImage(named: "frame_d.png")
                }
                
                if(self.resultlist[0]["imagesrc"] as! String != ""){
                    self.imgPerson.image = UIImage(data: NSData(contentsOfURL: NSURL(string:self.resultlist[0]["imagesrc"] as! String)!)!)
                }
            }
        }
        task.resume()
        
    }
    
    func btnHomeClicked(sender: UIButton!) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}