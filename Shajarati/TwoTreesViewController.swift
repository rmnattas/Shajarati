//
//  TwoTreesViewController.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 30/8/16.
//  Copyright © 2016 Abdulrahman Alattas. All rights reserved.
//

import Foundation
import UIKit

class TwoTreesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var lblPerson: UILabel!
    @IBOutlet weak var txttree2: UITextField!
    @IBOutlet weak var tblTwoTrees: UITableView!
    @IBOutlet weak var WaitIndicator: UIActivityIndicatorView!
    
    var personName : String = ""
    var personID : String = ""
    var defaults : NSUserDefaults = NSUserDefaults()
    var TwoTreesList : [AnyObject] = []
    var btnHome : UIBarButtonItem = UIBarButtonItem()
    var searchedID : String = ""
    var setuserlevel : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonHome: UIButton = UIButton.init(type: UIButtonType.Custom)
        buttonHome.setImage(UIImage(named: "home.png"), forState: UIControlState.Normal)
        buttonHome.addTarget(self, action: #selector(self.btnHomeClicked(_:)), forControlEvents: .TouchDown)
        buttonHome.frame = CGRectMake(0, 0, 24, 24)
        btnHome = UIBarButtonItem(customView: buttonHome)
        self.navigationItem.setRightBarButtonItem(btnHome, animated: false)
        
        defaults = NSUserDefaults.standardUserDefaults()
        
        lblPerson.text = personName
        txttree2.becomeFirstResponder()
        
        tblTwoTrees.rowHeight = 35
        
        let nib = UINib(nibName: "TwoTreesCustomCell", bundle: nil)
        tblTwoTrees.registerNib(nib, forCellReuseIdentifier: "TwoTreesCustomCell")
    }
    
    @IBAction func btnSearch(sender: UIButton){
        
        if(txttree2.text == ""){
            let alert: UIAlertView = UIAlertView()
            alert.delegate = self
            alert.tag = 800
            alert.title = "شجرتي"
            alert.message = "الرجاء ادخال رقم الشجرة الثانية المراد البحث عن القرابة معها"
            alert.addButtonWithTitle("موافق")
            alert.show()
        }else if(txttree2.text == personID){
            let alert: UIAlertView = UIAlertView()
            alert.delegate = self
            alert.tag = 700
            alert.title = "شجرتي"
            alert.message = "الرجاء ادخال رقم شجرة مختلف عن رقم الشجرة الاولى"
            alert.addButtonWithTitle("موافق")
            alert.show()
        }else{
            if(txttree2.text! != searchedID){
                view.endEditing(true)
                TwoTreesSearch()
            }
        }
        
    }
    
    func TwoTreesSearch(){
        WaitIndicator.startAnimating()
        self.view.userInteractionEnabled = false
        
        let request = NSMutableURLRequest(URL: NSURL(string: AppDelegate().directoryurl + "a_2tree.php")!)
        request.HTTPMethod = "POST"
        let postString = "android_id=\(defaults.stringForKey("hashnum")!)&id=\(personID)&tree1=\(personID)&tree2=\(txttree2.text!)&setuserlevel=\(setuserlevel)&shajarati=\(defaults.stringForKey("shajaratiDB")!)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("error #TwoTreesVC01 = \(error)")
                
                if (error!.code == -1005) || (error!.code == -1009){
                    dispatch_async(dispatch_get_main_queue()){
                        self.WaitIndicator.stopAnimating()
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
                    self.TwoTreesList.removeAll()
                    for resultname in myStructuredData{
                        self.TwoTreesList.append(resultname)
                    }
                    
                }
            }catch{ print("error #TwoTreesVC02 = \(error)") }
            dispatch_async(dispatch_get_main_queue()){
                self.WaitIndicator.stopAnimating()
                self.searchedID = self.txttree2.text!
                self.view.userInteractionEnabled = true
                self.tblTwoTrees.reloadData()
                self.tblTwoTrees.setContentOffset(CGPointMake(0, 0), animated:false)
            }
        }
        task.resume()

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TwoTreesList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tablecell:TwoTreesCustomCell = tableView.dequeueReusableCellWithIdentifier("TwoTreesCustomCell") as! TwoTreesCustomCell
        tablecell.backgroundColor = UIColor.clearColor()
        
        tablecell.lblLeft.text = ""
        tablecell.lblRight.text = ""
        tablecell.lblCenter.text = ""
        
        if(TwoTreesList[indexPath.row]["center"] as? String == "1") {
            if(TwoTreesList[indexPath.row]["treename1"] as? String != ""){
                tablecell.lblCenter.text = TwoTreesList[indexPath.row]["treename1"] as? String
            }else{
                tablecell.lblCenter.text = TwoTreesList[indexPath.row]["treename2"] as? String
            }
        }else{
            tablecell.lblLeft.text = TwoTreesList[indexPath.row]["treename1"] as? String
            tablecell.lblRight.text = TwoTreesList[indexPath.row]["treename2"] as? String
        }
        
        return tablecell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        view.endEditing(true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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