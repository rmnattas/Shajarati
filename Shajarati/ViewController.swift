//
//  ViewController.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 23/7/2015.
//  Copyright (c) 2015 Abdulrahman Alattas. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var WaitIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblWelcomeMessage: UITextView!
    @IBOutlet weak var btnfamilies: UIButton!
    @IBOutlet weak var btnpicslist: UIButton!
    @IBOutlet weak var btnsearch: UIButton!
    @IBOutlet weak var btnFavList: UIButton!
    @IBOutlet weak var btninquiries: UIButton!
    @IBOutlet weak var btnstatistics: UIButton!
    @IBOutlet weak var btndev: UIButton!
    @IBOutlet weak var btnmanage: UIButton!
    @IBOutlet weak var btnselectdb: UIButton!
    @IBOutlet weak var btnshare: UIButton!
    @IBOutlet weak var lbldeviceid: UILabel!
    
    var lblVersion : UIBarButtonItem = UIBarButtonItem()
    var resultlist : [AnyObject] = []
    var dorefresh : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let labelVersion: UILabel = UILabel.init()
        labelVersion.text = "\(AppDelegate().version as! String)"
        labelVersion.font = UIFont.systemFontOfSize(16)
        labelVersion.frame = CGRectMake(0, 0, 72, 24)
        lblVersion = UIBarButtonItem(customView: labelVersion)
        self.navigationItem.setLeftBarButtonItem(lblVersion, animated: false)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if((defaults.stringForKey("shajaratiDB")) == nil){
            selectDB()
            
            let emptyArray : [String] = []
            defaults.setObject(emptyArray, forKey: "FavIDs")
            defaults.setObject(emptyArray, forKey: "FavNames")
            defaults.setObject(emptyArray, forKey: "FavImages")
            defaults.setObject(emptyArray, forKey: "FavDB")
        }else{
            Refresh()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if(dorefresh == true){
            self.btnfamilies.enabled = false
            self.btnpicslist.enabled = false
            self.btnsearch.enabled = false
            self.btnFavList.enabled = false
            self.btnshare.enabled = false
            self.btninquiries.enabled = false
            self.btnmanage.enabled = false
            self.WaitIndicator.hidden = false
            self.lblWelcomeMessage.text = ""
            resultlist.removeAll()
            Refresh()
            dorefresh = false
        }
    }
    
    func selectDB(){
        let SelectDBViewControllerVar = self.storyboard!.instantiateViewControllerWithIdentifier("SelectDBViewController") as! SelectDBViewController
        self.navigationController?.pushViewController(SelectDBViewControllerVar, animated: false)
    }
 
    func Refresh(){
        let defaults = NSUserDefaults.standardUserDefaults()
 
        lbldeviceid.text = "رقم المستخدم : " + defaults.stringForKey("hashnum")!
 
        let request = NSMutableURLRequest(URL: NSURL(string: AppDelegate().directoryurl + "a_intro.php")!)
        request.HTTPMethod = "POST"
        let postString = "android_id=\(defaults.stringForKey("hashnum")!)&versionname=\(AppDelegate().version)&versioncode=\(AppDelegate().build)&ios=1&shajarati=\(defaults.stringForKey("shajaratiDB")!)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("error #VC01 = \(error)");
                
                if (error!.code == -1009) || (error!.code == -1005){
                    dispatch_async(dispatch_get_main_queue()){
                        let alert: UIAlertView = UIAlertView()
                        alert.delegate = self
                        alert.tag = 1000
                        alert.title = "شجرتي"
                        alert.message = "عفواً، حدث خطأ في الاتصال بالخادم \r\n الرجاء التأكد من وجود اتصال بالانترنت ثم أعد المحاولة"
                        alert.addButtonWithTitle("إعادة المحاولة")
                        alert.show()
                    }
                }
                
                return
            }
            do{
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
                if let myStructuredData = jsonData as? [[String: AnyObject]] {
                    for resultname in myStructuredData{ self.resultlist.append(resultname) }
                }
            }catch{ print("error #VC02 = \(error)") }
            dispatch_async(dispatch_get_main_queue()){
                self.WaitIndicator.hidden = true

                let msgtxt = self.resultlist[0]["txtabout"] as? String
                if (msgtxt != ""){
                let alert: UIAlertView = UIAlertView()
                alert.delegate = self
                alert.title = "برنامج شجرتي"
                alert.message = msgtxt
                alert.addButtonWithTitle("موافق")
                alert.show()
                }
                
                let WelcomeMessage : String = NSMutableString(string:(self.resultlist[0]["message"] as? String)!) as String
                self.lblWelcomeMessage.text = WelcomeMessage
                
                self.lblWelcomeMessage.scrollRangeToVisible(NSMakeRange(0, 1))
                self.lblWelcomeMessage.textAlignment = NSTextAlignment.Center
                self.lblWelcomeMessage.font = UIFont(name: "Helvetica Neue", size: 16)
                
                if(self.resultlist[0]["status"] as? String != "stop"){
                    self.btnfamilies.enabled = true
                    self.btnpicslist.enabled = true
                    self.btnsearch.enabled = true
                    self.btnshare.enabled = true
                    self.btninquiries.enabled = true
                    self.btnFavList.enabled = true
                    self.btninquiries.enabled = true
                }
                if(self.resultlist[0]["managelink"] as? String != ""){
                    self.btnmanage.enabled = true
                }
                
            }
        }
        task.resume()
        
        lblWelcomeMessage.scrollRangeToVisible(NSMakeRange(0, 1))
        lblWelcomeMessage.textAlignment = NSTextAlignment.Center
        lblWelcomeMessage.font = UIFont(name: "Helvetica Neue", size: 16)
    }
    
    
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        if(View.tag == 1000){
            Refresh()
        }
        
    }
    
    @IBAction func btnstatistics(sender: UIButton) {
        let alert: UIAlertView = UIAlertView()
        alert.delegate = self
        alert.tag = 1
        alert.title = "إحصائيات شجرتي"
        alert.message = resultlist[0]["questiontext"] as? String
        alert.addButtonWithTitle("موافق")
        alert.show()
    }
    
    @IBAction func btnmanage(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: (resultlist[0]["managelink"] as? String)!)!)
    }
    
    @IBAction func btnshare(sender: UIButton) {
        let activityViewController = UIActivityViewController(activityItems: [resultlist[0]["sharemessage"] as! String], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
        
    }
    
    @IBAction func btndev(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: (resultlist[0]["developer_msg"] as? String)!)!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}

