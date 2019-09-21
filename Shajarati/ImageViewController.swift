//
//  ImageViewController.swift
//  Shajarati
//
//  Created by Abdulrahman Alattas on 15/6/16.
//  Copyright © 2016 Abdulrahman Alattas. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnChoose: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var WaitIndicator: UIActivityIndicatorView!

    let defaults = NSUserDefaults.standardUserDefaults()
    let imagePicker = UIImagePickerController()
    var DidSelectImg : Bool = false
    var SelectedImg : UIImage? = nil
    var PersonName : String = ""
    var PersonNumber : String = ""
    
    var btnHome : UIBarButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonHome: UIButton = UIButton.init(type: UIButtonType.Custom)
        buttonHome.setImage(UIImage(named: "home.png"), forState: UIControlState.Normal)
        buttonHome.addTarget(self, action: #selector(self.btnHomeClicked(_:)), forControlEvents: .TouchDown)
        buttonHome.frame = CGRectMake(0, 0, 24, 24)
        btnHome = UIBarButtonItem(customView: buttonHome)
        self.navigationItem.setRightBarButtonItem(btnHome, animated: false)
        
        imagePicker.delegate = self
    }
    
    @IBAction func btnChoose(sender: UIButton){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        DidSelectImg = true
        btnDelete.enabled = true
        btnSend.enabled = true
        
        SelectedImg = info[UIImagePickerControllerOriginalImage] as? UIImage
        imgView.contentMode = .ScaleAspectFit
        imgView.image = SelectedImg
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnDelete(sender: UIButton){
        DidSelectImg = false
        btnDelete.enabled = false
        btnSend.enabled = false
        
        SelectedImg = nil
        imgView.contentMode = .ScaleAspectFit
        imgView.image = UIImage(named: "missing.png")
    }
    
    @IBAction func btnSend(sender: UIButton){
        
        WaitIndicator.startAnimating()
        self.view.userInteractionEnabled = false
        
        let url = NSURL(string: AppDelegate().directoryurl + "i_saveImage.php?android_id=\(defaults.stringForKey("hashnum")!)&treeid=\(PersonNumber)&shajarati=\(defaults.stringForKey("shajaratiDB")!)")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let image_data = UIImageJPEGRepresentation(SelectedImg!, 1.0)!
        
        let body = NSMutableData()
        
        let Date : NSDate = NSDate()
        let DateFormatter : NSDateFormatter = NSDateFormatter()
        DateFormatter.locale = NSLocale.currentLocale()
        DateFormatter.dateFormat = "yMMdd_HHmmss"
        let FinalDate:String = DateFormatter.stringFromDate(Date)
        let FileName:String = "IMG" + "_" + FinalDate + "_" + defaults.stringForKey("hashnum")! + "_" + PersonNumber
        
        let fname = "\(FileName).jpg"
        let mimetype = "image/jpg"
        
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: \(mimetype)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(image_data)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = body
        
        let session = NSURLSession.sharedSession()
        
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            if error != nil {
                print("error #InquiryVC01 = \(error)")
                
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
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                self.WaitIndicator.stopAnimating()
                self.view.userInteractionEnabled = true
                
                let alert: UIAlertView = UIAlertView()
                alert.delegate = self
                alert.tag = 1
                alert.title = "برنامج شجرتي"
                alert.message = "عفواً \r\n لم يتم رفع الصورة بنجاح حاول مرة اخرى \r\n الرجاء التاكد ان الصور صغيرة الحجم"
                alert.addButtonWithTitle("موافق")
                alert.show()
                return
            }
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(dataString)
         
            dispatch_async(dispatch_get_main_queue()){
                self.WaitIndicator.stopAnimating()
                self.view.userInteractionEnabled = true
                
                if(dataString == "OK"){
                    let alert: UIAlertView = UIAlertView()
                    alert.delegate = self
                    alert.tag = 2
                    alert.title = "شجرتي"
                    alert.message = "شكراً، لقد تم رفع ملف الصورة بنجاح"
                    alert.addButtonWithTitle("موافق")
                    alert.show()
                }else if(dataString == "Error"){
                    let alert: UIAlertView = UIAlertView()
                    alert.delegate = self
                    alert.tag = 1
                    alert.title = "شجرتي"
                    alert.message = "عفواً \r\n لم يتم رفع الصورة بنجاح حاول مرة اخرى \r\n الرجاء التاكد ان الصور صغيرة الحجم"
                    alert.addButtonWithTitle("موافق")
                    alert.show()
                }
                
            }
            
        }
        
        task.resume()
        
    }
    
    func generateBoundaryString() -> String{
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        if(View.tag == 2){
            navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    func btnHomeClicked(sender: UIButton!) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
