//
//  selectDBViewController.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 8/8/17.
//  Copyright © 2017 Abdulrahman Alattas. All rights reserved.
//

import Foundation
import UIKit

class SelectDBViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var msg: UITextView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var WaitIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pckrfamilies: UIPickerView!
    @IBOutlet weak var btnok: UIButton!
    
    var loadedfamilies = false
    var familieslist : [AnyObject] = []
    var inmsg : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnok.enabled = false
        
        self.view.userInteractionEnabled = false
        let defaults = NSUserDefaults.standardUserDefaults()
        if((defaults.stringForKey("shajaratiDB")) == nil){
        navigationController?.navigationBar.userInteractionEnabled = false
        navigationController?.navigationBar.tintColor = UIColor.lightGrayColor()
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: AppDelegate().directoryurl + "a_initial.php")!)
        request.HTTPMethod = "POST"
        let postString = "android_id=\(defaults.stringForKey("hashnum")!)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("error #SelectDBVC01 = \(error)")
                
                if (error!.code == -1005) || (error!.code == -1009){
                    dispatch_async(dispatch_get_main_queue()){
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
                        self.familieslist.append(resultname)
                        
                    }
                    
                }
            }catch{ print("error #SelectDBVC02 = \(error)") }
            dispatch_async(dispatch_get_main_queue()){
                self.WaitIndicator.hidden = true
                self.view.userInteractionEnabled = true
                self.btnok.enabled = true
                self.loadedfamilies = true
                self.pckrfamilies.reloadAllComponents()
                self.name.text = self.familieslist[0]["db_name"] as? String
                self.inmsg = self.familieslist[0]["initial_msg"] as! String
                self.msg.text = self.inmsg
                self.msg.textAlignment = NSTextAlignment.Center
                self.msg.font = UIFont(name: "Helvetica Neue", size: 16)
            }
        }
        task.resume()
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return familieslist.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var titleOfRow : String! = nil
        if(loadedfamilies == true){
            self.WaitIndicator.hidden = true
            titleOfRow = familieslist[row]["db_name"] as! String
        }else{
            titleOfRow = "";
        }
        return titleOfRow
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.name.text = self.familieslist[row]["db_name"] as? String
        self.msg.text = self.familieslist[row]["initial_msg"] as? String
        self.msg.textAlignment = NSTextAlignment.Center
        self.msg.font = UIFont(name: "Helvetica Neue", size: 16)
    }
    
    @IBAction func btnok(sender: UIButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let selectedDB = familieslist[pckrfamilies.selectedRowInComponent(0)]["db_code"] as! String
        defaults.setObject(selectedDB, forKey: "shajaratiDB")
        print("DB selected '\(selectedDB)'")
        
        let n: Int! = self.navigationController?.viewControllers.count
        let ViewControllerVar = self.navigationController?.viewControllers[n-2] as! ViewController
        ViewControllerVar.dorefresh = true
        
        navigationController?.navigationBar.userInteractionEnabled = true
        navigationController?.navigationBar.tintColor = UIColor(hex: "007AFF")
        
        navigationController?.popViewControllerAnimated(false)
    }

}