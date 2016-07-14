//
//  Module.swift
//  NewsPix Beta
//
//  Created by UROP on 3/29/16.
//  Copyright © 2016 UROP. All rights reserved.
//

import Foundation
import UIKit

//Carousel Lists
public var index: Int = 0
//Bank of images
public var images: [UIImage!] = []
//Bank of headlines
public var names: [String] = []
//Bank of URLs
public var urls: [NSURL] = []


//Functions for obtaining, parsing JSONs

func getData(urlToRequest: String) -> NSData? {
    //Retrieves NSData from a url
    if let url = NSURL(string: urlToRequest) {
        if let data = NSData(contentsOfURL: url) {
            return data
        }
    }
    return nil
}

func parseJSON(inputData: NSData) {
    //Parse the JSON - in this case, the JSON is a dictionary.
    var json: NSDictionary = [:]
    //The actual parsing must be done with try/catch because it can fail
    do {
        json = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions()) as! NSDictionary
    } catch {
        print(error)
    }
    //Update the carousel lists
    let jsonHeadline: String! = json["headline"] as! String
    let jsonURL: String! = json["url"] as! String
    let jsonImage: String! = json["image"] as! String
    
    images.append(UIImage(data:(getData(jsonImage))!))
    names.append(jsonHeadline)
    urls.append(NSURL(string: jsonURL)!)

}

func altParseJSON(inputData: NSData) {
    //Parse the JSON
    var json: NSMutableArray = []
    //The actual parsing must be done with try/catch because it can fail
    do {
        json = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions()) as! NSMutableArray
    } catch {
        print(error)
    }
    //Update the carousel lists
    for story in json {
        let jsonHeadline: String! = story["headline"] as! String
        let jsonURL: String! = story["url"] as! String
        let jsonImage: String! = story["image"] as! String
    
        images.append(UIImage(data:(getData(jsonImage))!))
        names.append(jsonHeadline)
        urls.append(NSURL(string: jsonURL)!)
    }
    
}
