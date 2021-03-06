//
//  PicsListViewController.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 31/7/2015.
//  Copyright (c) 2015 Abdulrahman Alattas. All rights reserved.
//

import Foundation
import UIKit

class PicsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblPicsList: UITableView!
    @IBOutlet weak var WaitIndicator: UIActivityIndicatorView!
    
    var PicsList : [AnyObject] = [false]
    
    var btnHome : UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonHome: UIButton = UIButton.init(type: UIButtonType.Custom)
        buttonHome.setImage(UIImage(named: "home.png"), forState: UIControlState.Normal)
        buttonHome.addTarget(self, action: #selector(self.btnHomeClicked(_:)), forControlEvents: .TouchDown)
        buttonHome.frame = CGRectMake(0, 0, 24, 24)
        btnHome = UIBarButtonItem(customView: buttonHome)
        self.navigationItem.setRightBarButtonItem(btnHome, animated: false)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let request = NSMutableURLRequest(URL: NSURL(string: AppDelegate().directoryurl + "a_listpics.php")!)
        request.HTTPMethod = "POST"
        let postString = "android_id=\(defaults.stringForKey("hashnum")!)&shajarati=\(defaults.stringForKey("shajaratiDB")!)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("error #PicsVC01 = \(error)")
                
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
                        self.PicsList.append(resultname)
                    }
                }
            }catch{ print("error #PicsVC02 = \(error)") }
            dispatch_async(dispatch_get_main_queue()){
                self.WaitIndicator.hidden = true
                self.tblPicsList.reloadData()
            }
        }
        task.resume()
        
        tblPicsList.rowHeight = 44
        
        //let nib = UINib(nibName: "PicsListCustomCell", bundle: nil)
        //tblPicsList.registerNib(nib, forCellReuseIdentifier: "PicsListCustomCell")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PicsList.count - 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /*
         
         ----Custom PicList Table Cell
         
         let tablecell:PicsListCustomCell = tableView.dequeueReusableCellWithIdentifier("PicsListCustomCell") as! PicsListCustomCell
        
        tablecell.lblname?.text = PicsList[indexPath.row + 1]["imagename"] as? String
        tablecell.lblname?.textAlignment = NSTextAlignment.Right
        tablecell.lblname?.font = UIFont(name: "Helvetica Neue", size: 16)
        
        let imgURL: NSURL = NSURL(string: PicsList[indexPath.row + 1]["imageurl"] as! String)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(
            request, queue: NSOperationQueue.mainQueue(),
            completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if error == nil {
                    tablecell.imgperson?.image = UIImage(data: data!)
                    tablecell.setNeedsLayout()
                }
        })
        
        tablecell.backgroundColor = UIColor.clearColor()
        
        return tablecell
         */
        
        
        let tablecell : UITableViewCell = UITableViewCell()
        tablecell.textLabel?.text = (PicsList[indexPath.row + 1]["imagename"] as! String)
        tablecell.textLabel?.textAlignment = NSTextAlignment.Right
        tablecell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 15)
        
        let imgURL: NSURL = NSURL(string: PicsList[indexPath.row + 1]["imageurl"] as! String)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(
            request, queue: NSOperationQueue.mainQueue(),
            completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
                if error == nil {
                    tablecell.imageView?.image = UIImage(data: data!)
                    tablecell.setNeedsLayout()
                }
        })
        
        tablecell.backgroundColor = UIColor.clearColor()
        
        return tablecell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let PersonViewControllerVar = self.storyboard!.instantiateViewControllerWithIdentifier("PersonViewController") as! PersonViewController
        
        PersonViewControllerVar.PersonID = PicsList[indexPath.row + 1]["imageid"] as! String
        
        self.navigationController?.pushViewController(PersonViewControllerVar, animated: true)
    }
    
    func btnHomeClicked(sender: UIButton!) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}