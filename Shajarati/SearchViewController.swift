//
//  SearchViewController.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 31/7/2015.
//  Copyright (c) 2015 Abdulrahman Alattas. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var txt1stname: UITextField!
    @IBOutlet weak var txt2ndname: UITextField!
    @IBOutlet weak var txt3rdname: UITextField!
    @IBOutlet weak var txt4thname: UITextField!
    @IBOutlet weak var txttreenumber: UITextField!
    @IBOutlet weak var WaitIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnsearch: UIButton!
    @IBOutlet weak var btnclear: UIButton!
    @IBOutlet weak var pckrfamilies: UIPickerView!
    
    var btnHome : UIBarButtonItem = UIBarButtonItem()
    var familieslist : [AnyObject] = []
    var loadedfamilies : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pckrfamilies.dataSource = self;
        self.pckrfamilies.delegate = self;
        self.view.userInteractionEnabled = false
        self.loadedfamilies = false
        let buttonHome: UIButton = UIButton.init(type: UIButtonType.Custom)
        buttonHome.setImage(UIImage(named: "home.png"), forState: UIControlState.Normal)
        buttonHome.addTarget(self, action: #selector(self.btnHomeClicked(_:)), forControlEvents: .TouchDown)
        buttonHome.frame = CGRectMake(0, 0, 24, 24)
        btnHome = UIBarButtonItem(customView: buttonHome)
        self.navigationItem.setRightBarButtonItem(btnHome, animated: false)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let request = NSMutableURLRequest(URL: NSURL(string: AppDelegate().directoryurl + "a_search_menu.php")!)
        request.HTTPMethod = "POST"
        let postString = "android_id=\(defaults.stringForKey("hashnum")!)&shajarati=\(defaults.stringForKey("shajaratiDB")!)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error #SearchVC01 = \(error)")
                
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
            }catch{ print("error #SearchVC02 = \(error)") }
            dispatch_async(dispatch_get_main_queue()){
                self.loadedfamilies = true
                self.pckrfamilies.reloadAllComponents()
                self.WaitIndicator.stopAnimating()
                self.view.userInteractionEnabled = true
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
            titleOfRow = familieslist[row]["tribe"] as! String
        }else{
            titleOfRow = "";
        }
        return titleOfRow
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Montserrat", size: 17)
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        if(loadedfamilies == true){
            pickerLabel?.text = familieslist[row]["tribe"] as! String
        }else{
            pickerLabel?.text = "";
        }
        
        
        return pickerLabel!;
    }

    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        var count : Int = 0
        
        if(txt1stname.text != ""){ count = 10 }
        if(txt2ndname.text != ""){ count += 1 }
        if(txt3rdname.text != ""){ count += 1 }
        if(txt4thname.text != ""){ count += 1 }
        
        if (count > 10) || (txttreenumber.text != "") {
            return true
        }else{
            let alert: UIAlertView = UIAlertView()
            alert.delegate = self
            alert.title = "شجرتي"
            alert.message = "عفواً، الرجاء على الاقل ادخال \r\n الاسم الاول و (اسم الاب او الجد او العائلة) \r\n او ادخال رقم الشجرة"
            alert.addButtonWithTitle("موافق")
            alert.show()
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let ResultViewControllerVar = segue.destinationViewController as! ResultViewController;
        
        ResultViewControllerVar.txt1stname = txt1stname.text!
        ResultViewControllerVar.txt2ndname = txt2ndname.text!
        ResultViewControllerVar.txt3rdname = txt3rdname.text!
        ResultViewControllerVar.txt4thname = txt4thname.text!
        ResultViewControllerVar.txttreenumber = txttreenumber.text!
        var selected = familieslist[pckrfamilies.selectedRowInComponent(0)]["id"] as! String
        ResultViewControllerVar.selected = selected
    }
    
    @IBAction func btnclear(sender: UIButton) {
        txt1stname.text = ""
        txt2ndname.text = ""
        txt3rdname.text = ""
        txt4thname.text = ""
        txttreenumber.text = ""
    }
    
    func btnHomeClicked(sender: UIButton!) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}