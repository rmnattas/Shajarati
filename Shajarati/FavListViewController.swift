//
//  FavListViewController.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 1/9/16.
//  Copyright © 2016 Abdulrahman Alattas. All rights reserved.
//

import Foundation
import UIKit

class FavListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblFavList: UITableView!
    
    var btnHome : UIBarButtonItem = UIBarButtonItem()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var CleanedFavIDs : [String] = []
    var CleanedFavNames : [String] = []
    var CleanedFavImages : [String] = []
    var CleanedFavDB : [String] = []
    
    override func viewDidLoad() {

        let buttonHome: UIButton = UIButton.init(type: UIButtonType.Custom)
        buttonHome.setImage(UIImage(named: "home.png"), forState: UIControlState.Normal)
        buttonHome.addTarget(self, action: #selector(self.btnHomeClicked(_:)), forControlEvents: .TouchDown)
        buttonHome.frame = CGRectMake(0, 0, 24, 24)
        btnHome = UIBarButtonItem(customView: buttonHome)
        self.navigationItem.setRightBarButtonItem(btnHome, animated: false)
        
        tblFavList.rowHeight = 44
        
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CleanedFavIDs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tablecell : UITableViewCell = UITableViewCell()
        tablecell.textLabel?.text = CleanedFavNames[indexPath.row]
        tablecell.textLabel?.textAlignment = NSTextAlignment.Right
        tablecell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 16)
        
        let imgURL: NSURL = NSURL(string: CleanedFavImages[indexPath.row])!
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
        PersonViewControllerVar.PersonID = CleanedFavIDs[indexPath.row]
        self.navigationController?.pushViewController(PersonViewControllerVar, animated: true)
    }
    
    func CleanFav(IDs : [String], Names : [String], Images : [String], DB : [String]){
        if(IDs.count > 0){
        for i in 0...(IDs.count - 1) {
            if(defaults.stringForKey("shajaratiDB")! == DB[i]){
            CleanedFavIDs.append(IDs[i])
            CleanedFavNames.append(Names[i])
            CleanedFavImages.append(Images[i])
            CleanedFavDB.append(DB[i])
            }
        }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        CleanedFavIDs.removeAll()
        CleanedFavNames.removeAll()
        CleanedFavImages.removeAll()
        CleanedFavDB.removeAll()
        CleanFav(defaults.objectForKey("FavIDs") as! [String], Names: defaults.objectForKey("FavNames") as! [String],
                 Images: defaults.objectForKey("FavImages") as! [String], DB: defaults.objectForKey("FavDB") as! [String])
        tblFavList.reloadData()
        
        super.viewWillAppear(animated)
    }
    
    func btnHomeClicked(sender: UIButton!) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}