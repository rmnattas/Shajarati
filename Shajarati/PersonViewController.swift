//
//  PersonViewController.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 31/7/2015.
//  Copyright (c) 2015 Abdulrahman Alattas. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class PersonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var personimg: UIImageView!
    @IBOutlet weak var smallimage: UIButton!
    @IBOutlet weak var personimgL: UIImageView!
    @IBOutlet weak var frameL: UIImageView!
    @IBOutlet weak var frame: UIImageView!
    @IBOutlet weak var largeimage: UIButton!
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var btninsta: UIButton!
    @IBOutlet weak var btnsnap: UIButton!
    @IBOutlet weak var btnfacebook: UIButton!
    @IBOutlet weak var btntwitter: UIButton!
    @IBOutlet weak var btnemail: UIButton!
    @IBOutlet weak var btnwhatsapp: UIButton!
    @IBOutlet weak var btnperson: UIButton!
    @IBOutlet weak var tblfamily: UITableView!
    @IBOutlet weak var btnFullName: UIButton!
    @IBOutlet weak var WaitIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnInquiries: UIButton!
    @IBOutlet weak var genswitch: UISwitch!
    @IBOutlet weak var btnFav: UIButton!
    
    @IBOutlet weak var segmentedSetUserLevel: UISegmentedControl!
    @IBOutlet weak var btnGenPics: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var GenSwitchView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var MenuView: UIView!
    @IBOutlet weak var MenuViewHeight: NSLayoutConstraint!
    var MenuShowing : Bool!
    
    var btnHome : UIBarButtonItem = UIBarButtonItem()
    
    var PersonID : String = ""
    var gen : String = "1"
    let defaults = NSUserDefaults.standardUserDefaults()
    var setuserlevel : String = ""
    var lastsegmentselected : Int = 2
    var isFav : Bool = false
    
    var resultlist : [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonHome: UIButton = UIButton.init(type: UIButtonType.Custom)
        buttonHome.setImage(UIImage(named: "home.png"), forState: UIControlState.Normal)
        buttonHome.addTarget(self, action: #selector(self.btnHomeClicked(_:)), forControlEvents: .TouchDown)
        buttonHome.frame = CGRectMake(0, 0, 24, 24)
        btnHome = UIBarButtonItem(customView: buttonHome)
        self.navigationItem.setRightBarButtonItem(btnHome, animated: false)
        
        self.MenuShowing = false
      
        self.view.userInteractionEnabled = false
        
        let request = NSMutableURLRequest(URL: NSURL(string: AppDelegate().directoryurl + "a_des.php")!)
        request.HTTPMethod = "POST"
        let postString = "android_id=\(defaults.stringForKey("hashnum")!)&id=\(PersonID)&nb_gen_desc=\(gen)&setuserlevel=\(setuserlevel)&shajarati=\(defaults.stringForKey("shajaratiDB")!)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("error #PersonVC01 = \(error)")
            
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
            }catch{ print("error #PersonVC02 = \(error)") }
            dispatch_async(dispatch_get_main_queue()){
                self.WaitIndicator.hidden = true
                
                self.title = self.resultlist[0]["mainname"]!!.componentsSeparatedByString(" ").first!
                self.lblname.text = "\(self.resultlist[0]["mainname"] as! String) (\(self.PersonID))"
                
                
                self.personimg.image = UIImage(data: NSData(contentsOfURL: NSURL(string:self.resultlist[0]["mainimageurl"] as! String)!)!)
                let smallimage = self.resultlist[0]["mainimageurl"] as! String;
                let largeimage = smallimage.stringByReplacingOccurrencesOfString("/thumbs", withString: "")
                self.personimgL.image = UIImage(data: NSData(contentsOfURL: NSURL(string:largeimage)!)!)
                
                if(smallimage == "http://shajarati.co/missing_image.png"){
                    self.frame.image = UIImage(named: "frame.png")
                    self.smallimage.enabled = false;
                }else{
                    self.frameL.image = UIImage(named: "frame_lM.png")
                    self.frame.image = UIImage(named: "frameM.png")
                    self.largeimage.enabled = true;
                    if((self.resultlist[0]["died"] as? String) != ""){
                        self.frame.image = UIImage(named: "frame_m_d.png")
                    }
                }
            
                    
                switch self.resultlist[0]["mainuserlevel"] as! String {
                    case "1":
                        self.segmentedSetUserLevel.setEnabled(true, forSegmentAtIndex: 2)
                        self.segmentedSetUserLevel.selectedSegmentIndex = 2
                        self.lastsegmentselected = 2
                    case "2":
                        self.segmentedSetUserLevel.setEnabled(true, forSegmentAtIndex: 2)
                        self.segmentedSetUserLevel.setEnabled(true, forSegmentAtIndex: 1)
                        self.segmentedSetUserLevel.selectedSegmentIndex = 1
                        self.lastsegmentselected = 1
                    case "3":
                        self.segmentedSetUserLevel.setEnabled(true, forSegmentAtIndex: 2)
                        self.segmentedSetUserLevel.setEnabled(true, forSegmentAtIndex: 1)
                        self.segmentedSetUserLevel.setEnabled(true, forSegmentAtIndex: 0)
                        self.segmentedSetUserLevel.selectedSegmentIndex = 0
                        self.lastsegmentselected = 0
                    default:
                        break;
                }
                
                if (self.setuserlevel != ""){
                    switch self.setuserlevel {
                        case "1":
                            self.segmentedSetUserLevel.selectedSegmentIndex = 2
                            self.lastsegmentselected = 2
                        case "2":
                            self.segmentedSetUserLevel.selectedSegmentIndex = 1
                            self.lastsegmentselected = 1
                        case "3":
                            self.segmentedSetUserLevel.selectedSegmentIndex = 0
                            self.lastsegmentselected = 0
                        default:
                            break;
                    }
                }
                
                if((self.resultlist[0]["maingsonslink"] as? String) == "1"){
                    self.btnGenPics.enabled = true
                }
                if((self.resultlist[0]["updatelink"] as? String) != ""){
                    self.btnUpdate.enabled = true
                }
                if((self.resultlist[0]["maininstalink"] as? String) != ""){
                    self.btninsta.enabled = true
                    self.btninsta.setImage(UIImage(named: "insta.png"), forState: UIControlState.Normal)
                }
                if((self.resultlist[0]["mainsnaplink"] as? String) != ""){
                    self.btnsnap.enabled = true
                    self.btnsnap.setImage(UIImage(named: "snap.png"), forState: UIControlState.Normal)
                }
                if((self.resultlist[0]["mainfacebooklink"] as? String) != ""){
                    self.btnfacebook.enabled = true
                    self.btnfacebook.setImage(UIImage(named: "facebook.png"), forState: UIControlState.Normal)
                }
                if((self.resultlist[0]["maintwitterlink"] as? String) != ""){
                    self.btntwitter.enabled = true
                    self.btntwitter.setImage(UIImage(named: "twitter.png"), forState: UIControlState.Normal)
                }
                if((self.resultlist[0]["mainemaillink"] as? String) != ""){
                    self.btnemail.enabled = true
                    self.btnemail.setImage(UIImage(named: "email.png"), forState: UIControlState.Normal)
                }
                if((self.resultlist[0]["mainwhatsapplink"] as? String) != ""){
                    self.btnwhatsapp.enabled = true
                    self.btnwhatsapp.setImage(UIImage(named: "whatsapp.png"), forState: UIControlState.Normal)
                }
                if((self.resultlist[0]["mainbrieflink"] as? String) != ""){
                    self.btnperson.enabled = true
                    self.btnperson.setImage(UIImage(named: "person.png"), forState: UIControlState.Normal)
                }
                
                self.view.userInteractionEnabled = true
                
                self.tblfamily.reloadData()
            }
        }
        task.resume()
        
        checkIsFav(defaults.objectForKey("FavIDs") as! [String], Names: defaults.objectForKey("FavNames") as! [String],
                   Images: defaults.objectForKey("FavImages") as! [String], DB: defaults.objectForKey("FavDB") as! [String])
        
        tblfamily.rowHeight = 30
        
        let nib = UINib(nibName: "MyCustomCell", bundle: nil)
        tblfamily.registerNib(nib, forCellReuseIdentifier: "MyCustomCell")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultlist.count - 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tablecell:MyCustomCell = tableView.dequeueReusableCellWithIdentifier("MyCustomCell") as! MyCustomCell
        
        tablecell.backgroundColor = UIColor.clearColor()
        
        tablecell.lblspaces.text = resultlist[indexPath.row + 1]["listspaces"] as? String
        tablecell.lblname.text = resultlist[indexPath.row + 1]["listname"] as? String
        tablecell.lblname.textAlignment = NSTextAlignment.Right
        tablecell.lblname.font = UIFont(name: "Helvetica Neue", size: 14)
        
        tablecell.imgperson.image = nil
        
        let imgURL: NSURL = NSURL(string: resultlist[indexPath.row + 1]["listimageurl"] as! String)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(
            request, queue: NSOperationQueue.mainQueue(),
            completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if error == nil {
                    
                    tablecell.imgperson.image = UIImage(data: data!)
                    tablecell.setNeedsLayout()
                }
        })
        
        tablecell.imginsta.hidden = true
        tablecell.imgsnap.hidden = true
        tablecell.imgfacebook.hidden = true
        tablecell.imgtwitter.hidden = true
        tablecell.imgemail.hidden = true
        tablecell.imgwhatsapp.hidden = true
        tablecell.imgpersontext.hidden = true
        
        if(resultlist[indexPath.row + 1]["listinstaicon"] as? String == "1") { tablecell.imginsta.hidden = false }
        if(resultlist[indexPath.row + 1]["listsnapicon"] as? String == "1") { tablecell.imgsnap.hidden = false }
        if(resultlist[indexPath.row + 1]["listfacebookicon"] as? String == "1") { tablecell.imgfacebook.hidden = false }
        if(resultlist[indexPath.row + 1]["listtwittericon"] as? String == "1") { tablecell.imgtwitter.hidden = false }
        if(resultlist[indexPath.row + 1]["listemailicon"] as? String == "1") { tablecell.imgemail.hidden = false }
        if(resultlist[indexPath.row + 1]["listwhatsappicon"] as? String == "1") { tablecell.imgwhatsapp.hidden = false }
        if(resultlist[indexPath.row + 1]["listbrieficon"] as? String == "1") { tablecell.imgpersontext.hidden = false }
        
        return tablecell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        MenuHide()
        personimgL.hidden = true
        frameL.hidden = true
        largeimage.hidden = true
        
        if(PersonID != resultlist[indexPath.row + 1]["listid"] as! String){
        let PersonViewControllerVar = self.storyboard!.instantiateViewControllerWithIdentifier("PersonViewController") as! PersonViewController
        PersonViewControllerVar.PersonID = resultlist[indexPath.row + 1]["listid"] as! String
        PersonViewControllerVar.setuserlevel = setuserlevel
        self.navigationController?.pushViewController(PersonViewControllerVar, animated: true)
        }
    }
    
    func checkIsFav(IDs : [String], Names : [String], Images : [String], DB : [String]){
        
        if(IDs.count > 0){
        for i in 0...(IDs.count - 1) {
             if(DB[i] == defaults.stringForKey("shajaratiDB")!){
            if(IDs[i] == PersonID){
                self.btnFav.setImage(UIImage(named: "StarF.png"), forState: UIControlState.Normal)
                self.isFav = true
                break
            }
            }
        }
        }
    }
    
    @IBAction func btnFav(sender: AnyObject) {
        MenuHide()
        if (isFav == false){
            
            var tempFavIDs : [String] = defaults.objectForKey("FavIDs") as! [String]
            var tempFavNames : [String] = defaults.objectForKey("FavNames") as! [String]
            var tempFavImages : [String] = defaults.objectForKey("FavImages") as! [String]
            var tempFavDB : [String] = defaults.objectForKey("FavDB") as! [String]
            
            tempFavIDs.append(PersonID)
            tempFavNames.append(self.resultlist[0]["mainname"] as! String)
            tempFavDB.append(defaults.stringForKey("shajaratiDB")!)
            if(self.resultlist[0]["mainimageurl"] as! String == "http://shajarati.alattas.co/picture/thumbs/missing_image.png"){
                tempFavImages.append("http://shajarati.alattas.co/picture/thumbs/male_blank.png")
            }else{
                tempFavImages.append(self.resultlist[0]["mainimageurl"] as! String)
            }
            
            defaults.setObject(tempFavIDs, forKey: "FavIDs")
            defaults.setObject(tempFavNames, forKey: "FavNames")
            defaults.setObject(tempFavImages, forKey: "FavImages")
            defaults.setObject(tempFavDB, forKey: "FavDB")
            
            self.btnFav.setImage(UIImage(named: "StarF.png"), forState: UIControlState.Normal)
            self.isFav = true
        }else{
            
            var tempFavIDs : [String] = defaults.objectForKey("FavIDs") as! [String]
            var tempFavNames : [String] = defaults.objectForKey("FavNames") as! [String]
            var tempFavImages : [String] = defaults.objectForKey("FavImages") as! [String]
            var tempFavDB : [String] = defaults.objectForKey("FavDB") as! [String]
            
            for i in 0...tempFavIDs.count {
                if(tempFavDB[i] == defaults.stringForKey("shajaratiDB")!){
                if(tempFavIDs[i] == PersonID){
                    tempFavIDs.removeAtIndex(i)
                    tempFavNames.removeAtIndex(i)
                    tempFavImages.removeAtIndex(i)
                    tempFavDB.removeAtIndex(i)
                    
                    defaults.setObject(tempFavIDs, forKey: "FavIDs")
                    defaults.setObject(tempFavNames, forKey: "FavNames")
                    defaults.setObject(tempFavImages, forKey: "FavImages")
                    defaults.setObject(tempFavDB, forKey: "FavDB")
                    
                    break
                }
                }
            }
            
            self.btnFav.setImage(UIImage(named: "StarE.png"), forState: UIControlState.Normal)
            self.isFav = false
        }
    }
    
    func btnHomeClicked(sender: UIButton!) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        MenuHide()
        personimgL.hidden = true
        frameL.hidden = true
        largeimage.hidden = true
        if (segue.identifier == "FullName"){
            let FullNameViewControllerVar = segue.destinationViewController as! FullNameViewController;
            FullNameViewControllerVar.personID = PersonID
        }else if(segue.identifier == "Inquiry"){
            let InquiriesViewControllerVar = segue.destinationViewController as! InquiriesViewController;
            InquiriesViewControllerVar.InquiryFor = true
            InquiriesViewControllerVar.InquiryForName = resultlist[0]["mainname"] as! String
            InquiriesViewControllerVar.InquiryForNumber = PersonID
        }else if(segue.identifier == "GenPics"){
            let GenPicsViewControllerVar = segue.destinationViewController as! GenPicsViewController;
            GenPicsViewControllerVar.personID = PersonID
            GenPicsViewControllerVar.setuserlevel = setuserlevel
        }else if(segue.identifier == "TwoTrees"){
            let TwoTreesViewControllerVar = segue.destinationViewController as! TwoTreesViewController;
            TwoTreesViewControllerVar.personID = PersonID
            TwoTreesViewControllerVar.personName = lblname.text!
            TwoTreesViewControllerVar.setuserlevel = setuserlevel
        }
    }
    
    @IBAction func genswitch(sender: AnyObject) {
        if genswitch.on{
            gen = "2"
        }else{
            gen = "1"
        }
        
        WaitIndicator.hidden = false
        
        self.view.userInteractionEnabled = false
        
        let request = NSMutableURLRequest(URL: NSURL(string: AppDelegate().directoryurl + "a_des.php")!)
        request.HTTPMethod = "POST"
        let postString = "android_id=\(defaults.stringForKey("hashnum")!)&id=\(PersonID)&nb_gen_desc=\(gen)&setuserlevel=\(setuserlevel)&shajarati=\(defaults.stringForKey("shajaratiDB")!)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("error #PersonVC03 = \(error)")
                
                if (error!.code == -1005) || (error!.code == -1009){
                    dispatch_async(dispatch_get_main_queue()){
                        self.WaitIndicator.hidden = true
                        self.MenuShow()
                        self.view.userInteractionEnabled = true
                        let alert: UIAlertView = UIAlertView()
                        alert.delegate = self
                        alert.tag = 1000
                        alert.title = "شجرتي"
                        alert.message = "عفواً، حدث خطأ في الاتصال بالخادم \r\n الرجاء المحاولة مرة اخرى"
                        alert.addButtonWithTitle("موافق")
                        alert.show()
                        if(self.gen == "2"){
                            self.genswitch.setOn(false, animated: true)
                        }else{
                            self.genswitch.setOn(true, animated: true)
                        }
                    }
                }
                
                return
            }
            
            self.resultlist.removeAll()
            
            do{
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
                if let myStructuredData = jsonData as? [[String: AnyObject]] {
                    for resultname in myStructuredData{
                        self.resultlist.append(resultname)
                    }
                }
            }catch{ print("error #PersonVC04 = \(error)") }
            dispatch_async(dispatch_get_main_queue()){
                self.WaitIndicator.hidden = true
                self.MenuHide()
                self.tblfamily.allowsSelection = true
                
                self.view.userInteractionEnabled = true
                
                self.tblfamily.reloadData()
            }
        }
        task.resume()
    }
    
    @IBAction func segmentedSetUserLevel(sender: AnyObject) {
        
        var segtonumUserLevel : String = ""
        
        switch self.segmentedSetUserLevel.selectedSegmentIndex {
            case 2:
                segtonumUserLevel = "1"
            case 1:
                segtonumUserLevel = "2"
            case 0:
                segtonumUserLevel = "3"
            default:
                break;
        }
        
        WaitIndicator.hidden = false
        self.view.userInteractionEnabled = false
        
        let request = NSMutableURLRequest(URL: NSURL(string: AppDelegate().directoryurl + "a_des.php")!)
        request.HTTPMethod = "POST"
        let postString = "android_id=\(defaults.stringForKey("hashnum")!)&id=\(PersonID)&nb_gen_desc=\(gen)&setuserlevel=\(segtonumUserLevel)&shajarati=\(defaults.stringForKey("shajaratiDB")!)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("error #PersonVC05 = \(error)")
                
                if (error!.code == -1005) || (error!.code == -1009){
                    dispatch_async(dispatch_get_main_queue()){
                        self.WaitIndicator.hidden = true
                        self.MenuShow()
                        self.view.userInteractionEnabled = true
                        let alert: UIAlertView = UIAlertView()
                        alert.delegate = self
                        alert.tag = 1000
                        alert.title = "شجرتي"
                        alert.message = "عفواً، حدث خطأ في الاتصال بالخادم \r\n الرجاء المحاولة مرة اخرى"
                        alert.addButtonWithTitle("موافق")
                        alert.show()
                        
                        self.segmentedSetUserLevel.selectedSegmentIndex = self.lastsegmentselected
                        
                    }
                }
                
                return
            }
            
            self.resultlist.removeAll()
            
            do{
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
                if let myStructuredData = jsonData as? [[String: AnyObject]] {
                    for resultname in myStructuredData{
                        self.resultlist.append(resultname)
                    }
                }
            }catch{ print("error #PersonVC06 = \(error)") }
            dispatch_async(dispatch_get_main_queue()){
                self.WaitIndicator.hidden = true
                self.MenuHide()
                
                self.lastsegmentselected = self.segmentedSetUserLevel.selectedSegmentIndex
                switch self.segmentedSetUserLevel.selectedSegmentIndex {
                case 2:
                    self.setuserlevel = "1"
                case 1:
                    self.setuserlevel = "2"
                case 0:
                    self.setuserlevel = "3"
                default:
                    break;
                }
                
                self.tblfamily.allowsSelection = true
                self.view.userInteractionEnabled = true
                self.tblfamily.reloadData()
            }
        }
        task.resume()
    }

    @IBAction func btninsta(sender: AnyObject) {
        MenuHide()
        UIApplication.sharedApplication().openURL(NSURL(string: (resultlist[0]["maininstalink"] as? String)!)!)
    }
    
    @IBAction func btnsnap(sender: AnyObject) {
        MenuHide()
        UIApplication.sharedApplication().openURL(NSURL(string: (resultlist[0]["mainsnaplink"] as? String)!)!)
    }
    
    @IBAction func btnFacebook(sender: AnyObject) {
        MenuHide()
        UIApplication.sharedApplication().openURL(NSURL(string: (resultlist[0]["mainfacebooklink"] as? String)!)!)
    }
    
    @IBAction func btnTwitter(sender: AnyObject) {
        MenuHide()
        UIApplication.sharedApplication().openURL(NSURL(string: (resultlist[0]["maintwitterlink"] as? String)!)!)
    }
    
    @IBAction func btnEmail(sender: AnyObject) {
        MenuHide()
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([(resultlist[0]["mainemaillink"] as? String)!])
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            print("Error Sending Email")
        }
    }
    
    @IBAction func btnWhatsapp(sender: AnyObject) {
        MenuHide()
        UIApplication.sharedApplication().openURL(NSURL(string: (resultlist[0]["mainwhatsapplink"] as? String)!)!)
    }
    
    @IBAction func btnPerson(sender: AnyObject) {
        MenuHide()
        
        let alertView = UIAlertView();
        alertView.title = (resultlist[0]["mainname"] as? String)!
        alertView.message = resultlist[0]["mainbrieflink"] as? String
        alertView.addButtonWithTitle("نسخ")
        alertView.addButtonWithTitle("موافق")
        alertView.tag = 123
        alertView.delegate = self
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        if(alertView.tag == 123){
        switch buttonIndex{
        case 0:
            print("1")
            UIPasteboard.generalPasteboard().string = resultlist[0]["mainbrieflink"] as? String
        case 1:
            print("2")
        default:
            print("3")
        }
        }
    }
    
    @IBAction func btnMenu(sender: AnyObject) {
        personimgL.hidden = true
        frameL.hidden = true
        largeimage.hidden = true
        if(MenuShowing == true){
            MenuHide()
        }else{
            MenuShow()
        }
    }
    
    @IBAction func btnUpdate(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: (self.resultlist[0]["updatelink"] as? String)!)!)
    }
    
    @IBAction func image(sender: AnyObject) {
        personimgL.hidden = false
        frameL.hidden = false
        largeimage.hidden = false
    }
    @IBAction func imageL(sender: AnyObject) {
        personimgL.hidden = true
        frameL.hidden = true
        largeimage.hidden = true
    }
    
    func MenuShow(){
        UIView.animateWithDuration(0.4, animations: {
            self.MenuShowing = true
            //self.tblfamily.setContentOffset(CGPointMake(0, (self.tblfamily.contentOffset.y + 80)) , animated: false)
            self.btnMenu.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            self.MenuViewHeight.constant = 120
            self.view.layoutIfNeeded()
        })
    }
    
    func MenuHide(){
        UIView.animateWithDuration(0.4, animations: {
            self.MenuShowing = false
            //self.tblfamily.setContentOffset(CGPointMake(0, (self.tblfamily.contentOffset.y - 80)) , animated: false)
            self.btnMenu.transform = CGAffineTransformMakeRotation(CGFloat(-2 * M_PI))
            self.MenuViewHeight.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        
        if !(touches.first?.view == MenuView || touches.first?.view == GenSwitchView){
            MenuHide()
        }
        
        personimgL.hidden = true
        frameL.hidden = true
        largeimage.hidden = true
        
        dismissViewControllerAnimated(true, completion: nil)
        super.touchesEnded(touches , withEvent: event)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}