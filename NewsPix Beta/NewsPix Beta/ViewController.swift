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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    var lastZoomScale: CGFloat = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        //Download content from server
        if images.count == 0 {
            altParseJSON(getData("http://dev.newspix.today/get_all_stories/keene_sentinel")!)
        }
        
//        altParseJSON(getData("http://dev.newspix.today/get_all_stories/keene_sentinel")!)
//        let numberOfCalls = 8
//        for _ in 1...numberOfCalls {
//                parseJSON(getData("http://dev.newspix.today/random_story")!)
//        }

        //Initialize Display
        self.pictureTitle.setTitle(names[index],forState: UIControlState.Normal)
        self.imageView.image = images[index]
        
        scrollView.delegate = self
        updateZoom()
        updateConstraints()
        
        //Always make pictureTitle fit in one line
        self.pictureTitle.titleLabel?.adjustsFontSizeToFitWidth = true
        
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast

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
            index -= 1
            if index < 0 {index = names.count-1}
        }
        if direction == ">" {
            index += 1
            if index > names.count-1 {index = 0}
        }
        self.imageView.fadeOut()
        self.pictureTitle.fadeOut()
        self.imageView.image = images[index]
        self.pictureTitle.setTitle(names[index],forState: UIControlState.Normal)
        self.pictureTitle.fadeIn()
        self.imageView.fadeIn()
        
    }
    
    @IBAction func didPressTitle() {
        let url = urls[index];
        UIApplication.sharedApplication().openURL(url);
    }
    
    @IBAction func handleSwipe(recognizer:UISwipeGestureRecognizer) {
        if (recognizer.direction == UISwipeGestureRecognizerDirection.Right) {
            index -= 1
            if index < 0 {index = names.count-1}
        }
        if (recognizer.direction == UISwipeGestureRecognizerDirection.Left) {
            index += 1
            if index > names.count-1 {index = 0}
        }
        self.imageView.fadeOut()
        self.pictureTitle.fadeOut()
        self.imageView.image = images[index]
        self.pictureTitle.setTitle(names[index],forState: UIControlState.Normal)
        self.pictureTitle.fadeIn()
        self.imageView.fadeIn()
        
    }

    @IBAction func shareButtonClicked(sender: UIBarButtonItem) {
        let textToShare = self.pictureTitle.currentTitle!
        let myWebsite = urls[index]
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
