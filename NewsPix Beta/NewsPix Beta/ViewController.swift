//
//  ViewController.swift
//  NewsPix Beta
//
//  Created by UROP on 3/12/16.
//  Copyright © 2016 UROP. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var swipeRight: UISwipeGestureRecognizer!
    @IBOutlet var swipeLeft: UISwipeGestureRecognizer!
    @IBOutlet weak var pictureTitle: UILabel!
    @IBOutlet weak var display: UIButton!
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Download content from server
//        altParseJSON(getData("http://localhost:5000/get_all_stories")!)
        let numberOfCalls = 5
        for _ in 1...numberOfCalls {
                parseJSON(getData("http://dev.newspix.today/random_story")!)
        }

        //Initialize Display
        self.pictureTitle.text = names[self.index]
        self.display.contentVerticalAlignment = UIControlContentVerticalAlignment.Center;
        self.display.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center;
        self.display.imageView?.contentMode = UIViewContentMode.ScaleAspectFit;
        self.display.setImage(images[self.index], forState: UIControlState.Normal)

        //Initialize list of read headlines if save data exists, otherwise set to empty read array
        if let archive = userDefaults.arrayForKey("Seen") {
            for headline in archive {
                read.append(headline as! String)
                print(read)
            }
        }
        else {
            userDefaults.setObject(read, forKey: "Seen")
        }
        
        //Update read array to reflect addition/removal of stories only if read has nonzero length
        if read.count > 0 {
            for i in 0...read.count {
                if names.indexOf(read[i]) == -1 {
                    read.removeAtIndex(i)
                    userDefaults.setObject(read, forKey: "Seen")
                }
            }
        }
        
        //Get number of unread stories by comparing lengths of names, read
        let unread = names.count - read.count
        print(unread)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = "Sentinel Source"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressArrow(sender: UIButton!) {
        let direction = sender.currentTitle!
        if direction == "<" {
            self.index -= 1
            if self.index < 0 {self.index = names.count-1}
        }
        if direction == ">" {
            self.index += 1
            if self.index > names.count-1 {self.index = 0}
        }
        self.display.fadeOut()
        self.pictureTitle.fadeOut()
        self.display.setImage(images[self.index], forState: UIControlState.Normal)
        self.pictureTitle.text = names[self.index]
        self.pictureTitle.fadeIn()
        self.display.fadeIn()
        
        //Update read stories
        if (read.indexOf(names[self.index]) == -1) {
            read.append(names[self.index])
            userDefaults.setObject(read, forKey: "Seen")
        }
    }
    @IBAction func didPressDisplay() {
        let url = urls[self.index];
        UIApplication.sharedApplication().openURL(url);
    }
    
    @IBAction func handleSwipe(recognizer:UISwipeGestureRecognizer) {
        if (recognizer.direction == UISwipeGestureRecognizerDirection.Right) {
            self.index -= 1
            if self.index < 0 {self.index = names.count-1}
        }
        if (recognizer.direction == UISwipeGestureRecognizerDirection.Left) {
            self.index += 1
            if self.index > names.count-1 {self.index = 0}
        }
        self.display.fadeOut()
        self.pictureTitle.fadeOut()
        self.display.setImage(images[self.index], forState: UIControlState.Normal)
        self.pictureTitle.text = names[self.index]
        self.pictureTitle.fadeIn()
        self.display.fadeIn()
        
        //Update read stories
        if (read.indexOf(names[self.index]) == -1) {
            read.append(names[self.index])
            userDefaults.setObject(read, forKey: "Seen")
        }
    }

    @IBAction func shareButtonClicked(sender: UIBarButtonItem) {
        let textToShare = self.pictureTitle.text!
        let myWebsite = urls[self.index]
        let objectsToShare = [textToShare, myWebsite]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [UIActivityTypePostToWeibo,
            UIActivityTypeMessage,
            UIActivityTypeMail,
            UIActivityTypePrint,
            UIActivityTypeCopyToPasteboard,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo,
            UIActivityTypeAirDrop]
        
        self.presentViewController(activityVC, animated: true, completion: nil)
        }
    
    } //Do not delete! End of ViewController class

