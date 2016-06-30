//
//  ViewController.swift
//  NewsPix Beta
//
//  Created by UROP on 3/12/16.
//  Copyright © 2016 UROP. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var swipeRight: UISwipeGestureRecognizer!
    @IBOutlet var swipeLeft: UISwipeGestureRecognizer!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pictureTitle: UIButton!
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    var index = 0
    var lastZoomScale: CGFloat = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Download content from server
//        altParseJSON(getData("http://localhost:5000/get_all_stories")!)
        let numberOfCalls = 8
        for _ in 1...numberOfCalls {
                parseJSON(getData("http://dev.newspix.today/random_story")!)
        }

        //Initialize Display
        self.pictureTitle.setTitle(names[self.index],forState: UIControlState.Normal)
        self.imageView.image = images[self.index]

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
        
        scrollView.delegate = self
        updateZoom()
        updateConstraints()

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
        self.imageView.fadeOut()
        self.pictureTitle.fadeOut()
        self.imageView.image = images[self.index]
        self.pictureTitle.setTitle(names[self.index],forState: UIControlState.Normal)
        self.pictureTitle.fadeIn()
        self.imageView.fadeIn()
        
        //Update read stories
        if (read.indexOf(names[self.index]) == -1) {
            read.append(names[self.index])
            userDefaults.setObject(read, forKey: "Seen")
        }
    }
    @IBAction func didPressTitle() {
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
        self.imageView.fadeOut()
        self.pictureTitle.fadeOut()
        self.imageView.image = images[self.index]
        self.pictureTitle.setTitle(names[self.index],forState: UIControlState.Normal)
        self.pictureTitle.fadeIn()
        self.imageView.fadeIn()
        
        //Update read stories
        if (read.indexOf(names[self.index]) == -1) {
            read.append(names[self.index])
            userDefaults.setObject(read, forKey: "Seen")
        }
    }

    @IBAction func shareButtonClicked(sender: UIBarButtonItem) {
        let textToShare = self.pictureTitle.currentTitle!
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
    
    override func viewWillTransitionToSize(size: CGSize,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            
            super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
            
            coordinator.animateAlongsideTransition({ [weak self] _ in
                self?.updateZoom()
                }, completion: nil)
    }
    
    func updateConstraints() {
        if let image = imageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let viewWidth = scrollView.bounds.size.width
            let viewHeight = scrollView.bounds.size.height
            
            // center image if it is smaller than the scroll view
            var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
            if hPadding < 0 { hPadding = 0 }
            
            var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
            if vPadding < 0 { vPadding = 0 }
            
            imageViewTrailingConstraint.constant = hPadding
            imageViewLeadingConstraint.constant = hPadding
            
            imageViewTopConstraint.constant = vPadding
            imageViewBottomConstraint.constant = vPadding
            
            view.layoutIfNeeded()
        }
    }
    
    // Zoom to show as much image as possible unless image is smaller than the scroll view
    private func updateZoom() {
        if let image = imageView.image {
            var minZoom = min(scrollView.bounds.size.width / image.size.width,
                scrollView.bounds.size.height / image.size.height)

            if minZoom > 1 { minZoom = 1 }

            
            scrollView.minimumZoomScale = 1
            scrollView.maximumZoomScale = 10
            
            // Force scrollViewDidZoom fire if zoom did not change
            if minZoom == lastZoomScale { minZoom += 0.000001 }
            scrollView.zoomScale = minZoom
            lastZoomScale = scrollView.zoomScale
        }
    }
    
    // UIScrollViewDelegate
    // -----------------------
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraints()
        }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
        }
    
    } //Do not delete! End of ViewController class
