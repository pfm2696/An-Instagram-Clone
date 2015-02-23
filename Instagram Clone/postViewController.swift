//
//  postViewController.swift
//  Instagram Clone
//
//  Created by Peter & Liz  on 2/22/15.
//  Copyright (c) 2015 P&L Studios. All rights reserved.
//

import UIKit

class postViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    var photoSelected:Bool = false
    
    @IBAction func logOut(sender: AnyObject) {
        
        PFUser.logOut()
        
        self.performSegueWithIdentifier("logout", sender: "self")
    }

    
    @IBOutlet var imageToPost: UIImageView!
    @IBAction func chooseImage(sender: AnyObject) {
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = true
        
        self.presentViewController(image, animated: true, completion: nil)
    }
    @IBOutlet var shareText: UITextField!

    @IBAction func postImage(sender: AnyObject) {
        
        var error = ""
        
        if photoSelected == false {
            
            error = "Please select an image to post"
        
        } else if shareText.text == "" {
            
            error = "Please enter an image description"
            
        }
        
        if error != "" {
        
            displayAlert("Cannot Post Image", error: error)
        
        } else {
        
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var post = PFObject(className: "Post")
            post["Title"] = shareText.text
            post["username"] = PFUser.currentUser().username
            
            post.saveInBackgroundWithBlock{(success: Bool!, error: NSError!) -> Void in
            
            if success == false {
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.displayAlert("Cannot Post Image", error: "Please try again")
            
            } else {
                
                let imageData = UIImagePNGRepresentation(self.imageToPost.image)
                
                let imageFile = PFFile(name: "image.png", data: imageData)
                
                post["imageFile"] = imageFile
                
                post.saveInBackgroundWithBlock{(success: Bool!, error: NSError!) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()

                    if success == false {
                        
                        self.displayAlert("Cannot Post Image", error: "Please try again")
                        
                        self.photoSelected = false
                        
                        self.imageToPost.image = UIImage(named:"polls_avatar_generic_246x246_0_0148_277637_poll_xlarge.png")
                        
                        self.shareText.text = ""
                        
                    } else {
                        
                        self.displayAlert("Your Image", error: "Has been posted successfully!")
                    
                    }
                }
            }
        
        }
    }
}
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        println("Image selected")
        self.dismissViewControllerAnimated(true, completion: nil)
        
        imageToPost.image = image
        
        photoSelected = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        photoSelected = false
        
        imageToPost.image = UIImage(named:"polls_avatar_generic_246x246_0_0148_277637_poll_xlarge.png")
        
        shareText.text = ""
        
        println("Posted Successfully")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
