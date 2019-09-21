//
//  Inquiries ViewController.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 10/11/15.
//  Copyright © 2015 Abdulrahman Alattas. All rights reserved.
//

import Foundation
import UIKit

class InquiriesViewController: UIViewController {
    
    @IBOutlet weak var lblInquiryFor: UILabel!
    @IBOutlet weak var txtInquiry: UITextView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnImg: UIButton!
    @IBOutlet weak var WaitIndicator: UIActivityIndicatorView!
   
    var InquiryFor : Bool = false
    var InquiryForName : String = ""
    var InquiryForNumber : String = ""
    
    var ImgUploaded : Bool = false
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var resultlist : [AnyObject] = []
    
    var btnHome : UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonHome: UIButton = UIButton.init(type: UIButtonType.Custom)
        buttonHome.setImage(UIImage(named: "home.png"), forState: UIControlState.Normal)
        buttonHome.addTarget(self, action: #selector(self.btnHomeClicked(_:)), forControlEvents: .TouchDown)
        buttonHome.frame = CGRectMake(0, 0, 24, 24)
        btnHome = UIBarButtonItem(customView: buttonHome)
        self.navigationItem.setRightBarButtonItem(btnHome, animated: false)
        
        if(InquiryFor == true){
            lblInquiryFor.text = "\(InquiryForName) (\(InquiryForNumber))"
        }
    }
    
    @IBAction func btnSend(sender: UIButton){
        if(txtInquiry.text == "" || txtName.text == "" || txtPhone.text == ""){
            
            let alert: UIAlertView = UIAlertView()
            alert.delegate = self
            alert.tag = 1
            alert.title = "شجرتي"
            alert.message = "الرجاء إكمال الفرغات التي تحتوي على علامة (*)"
            alert.addButtonWithTitle("موافق")
            alert.show()
            
        }else{
            
            WaitIndicator.hidden = false
            self.view.userInteractionEnabled = false
            
            let msg = self.txtInquiry.text
            let fixedMsg = fixarabicnumbers(msg)
            
            let request = NSMutableURLRequest(URL: NSURL(string: AppDelegate().directoryurl + "a_comments.php")!)
            request.HTTPMethod = "POST"
            let postString = "android_id=\(defaults.stringForKey("hashnum")!)&ibase=attasf&comment=\(fixedMsg)&name=\(txtName.text!)&mobile=\(txtPhone.text!)&treename=\(InquiryForName)&id=\(InquiryForNumber)&complete=1&ios=1&shajarati=\(defaults.stringForKey("shajaratiDB")!)"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                if error != nil {
                    print("error #InquiryVC01 = \(error)")
                    
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
                }catch{ print("error #InquiryVC02 = \(error)") }
                dispatch_async(dispatch_get_main_queue()){
                    self.WaitIndicator.hidden = true
                    
                    let alert: UIAlertView = UIAlertView()
                    alert.delegate = self
                    alert.tag = 2
                    alert.title = "شجرتي"
                    alert.message = self.resultlist[0]["message"] as? String
                    alert.addButtonWithTitle("موافق")
                    alert.show()
                }
            }
            task.resume()
            
        }
        
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        if(View.tag == 2){
            navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let ImageViewControllerVar = segue.destinationViewController as! ImageViewController;
        ImageViewControllerVar.PersonNumber = InquiryForNumber
        ImageViewControllerVar.PersonName = InquiryForName
    }
    
    func btnHomeClicked(sender: UIButton!) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func fixarabicnumbers(msg : String) -> String{
        
        var fixedMsg = msg
        fixedMsg = fixedMsg.stringByReplacingOccurrencesOfString("٠", withString: "0")
        fixedMsg = fixedMsg.stringByReplacingOccurrencesOfString("١", withString: "1")
        fixedMsg = fixedMsg.stringByReplacingOccurrencesOfString("٢", withString: "2")
        fixedMsg = fixedMsg.stringByReplacingOccurrencesOfString("٣", withString: "3")
        fixedMsg = fixedMsg.stringByReplacingOccurrencesOfString("٤", withString: "4")
        fixedMsg = fixedMsg.stringByReplacingOccurrencesOfString("٥", withString: "5")
        fixedMsg = fixedMsg.stringByReplacingOccurrencesOfString("٦", withString: "6")
        fixedMsg = fixedMsg.stringByReplacingOccurrencesOfString("٧", withString: "7")
        fixedMsg = fixedMsg.stringByReplacingOccurrencesOfString("٨", withString: "8")
        fixedMsg = fixedMsg.stringByReplacingOccurrencesOfString("٩", withString: "9")
        
        return fixedMsg
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}