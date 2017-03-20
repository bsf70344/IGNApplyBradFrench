//
//  ViewController.swift
//  IGNApp
//
//  Created by Bradley French on 2/26/17.
//  Copyright © 2017 Bradley French. All rights reserved.
//

import UIKit

/*
    IMPORTANT:
        I was having issues with the ScrollView's gestures and was unable to complete the task of getting the webview to appear upon click of a video or article. I am sorry, but the rest of it is definitely there.
 */

class ViewController: UIViewController {

    //Used the  CGFloat's for positioning and the article counter to help indicate where I am.
    var currentHeightPos:CGFloat = 0
    var scrollView:UIScrollView!
    var articleCounter:Int = 0
    var widthPos:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup UI and request some data
        createUI()
        loadRequest(count: 6, type: "articles")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUI() {
        
        //Initializes positioning and the scrollView so we can add data
        self.view.backgroundColor = UIColor.black
        scrollView = UIScrollView(frame: CGRect(x: self.view.frame.width*0.02, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.width*0.96, height: self.view.frame.height-UIApplication.shared.statusBarFrame.height))
        scrollView.backgroundColor = UIColor.clear
        scrollView.contentSize = CGSize(width: 0, height: 0)
        self.view.addSubview(scrollView)
        currentHeightPos = self.view.frame.height*0.01
    }
    
    //This is where I obtain the data and parse it out.
    func loadRequest(count:Int, type:String) {
        
        //I get the url to request the data from
        let requestString = "http://ign-apis.herokuapp.com/\(type)?startIndex=\(arc4random_uniform(300))&count=\(count)"
        let url = URL(string: requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        DispatchQueue.main.async {
            
            //Different scrollview depending on the videos or articles
            var scrollViewUsed:UIScrollView = self.scrollView
            if(type == "videos") {
                let height = self.view.frame.height*0.3
                scrollViewUsed = UIScrollView(frame: CGRect(x: 0, y: self.currentHeightPos, width: self.scrollView.frame.width, height: height))
                self.currentHeightPos += height
                self.scrollView.addSubview(scrollViewUsed)
                
            }
        
            //Request data
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { data, response, error in
             
                guard let data = data, error == nil else {
                    print(error!)
                    return
                }
                
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .mutableLeaves]) as? NSDictionary
                    let count = dict!["count"] as! Int
                    
                    //Loop through depenidng on the count, which I indicate as a parameter to this method.
                    for i in 0 ..< count {
                        if(dict != nil) {
                            if(dict!.count > 0) {
                                //I get the different metadata, thumbnails and tags
                                let metaData = (((dict!["data"] as! NSArray)[i] as! NSDictionary)["metadata"]) as! NSDictionary
                                let tags = (((dict!["data"] as! NSArray)[i] as! NSDictionary)["tags"]) as! NSArray
                                let thumbnails = (((dict!["data"] as! NSArray)[i] as! NSDictionary)["thumbnails"]) as! NSArray
                                let imageURL = (thumbnails[Int(UIScreen.main.scale)-1] as! NSDictionary)["url"] as! String
                                
                                //Get the imageData, so I can show the image
                                let imageData = try? Data(contentsOf: URL(string: imageURL)!)
                                
                                //To edit something while an async request is happening, have to use Dispatch
                                DispatchQueue.main.async {
                                    var dateAsString:String? = nil
                                    var name:String!
                                    var post:Post!
                                    //Different things for different types of post, i.e.
                                    //For videos you have the name under metaData["name"] and for articles it is metaData["headline"]
                                    if(type == "videos") {
                                        post = Video(urlString: "", currentHeightPos: self.currentHeightPos, scrollView: scrollViewUsed, widthPos: self.widthPos)
                                        name = metaData["name"] as! String
                                    }
                                    else {
                                        post = Article(urlString: "", currentHeightPos: self.currentHeightPos, scrollView: scrollViewUsed, viewController: self)
                                        name = metaData["headline"] as! String
                                        dateAsString = metaData["publishDate"] as? String
                                    }
                                    //This is where we create one item at a time
                                    (self.widthPos, self.currentHeightPos) = post.createOneItem(title: name, imageData: imageData!, lastItem: i == count-1, publishTimeAsString: dateAsString)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        //Change contentSize so it can scroll
                        if(type != "videos") {
                            scrollViewUsed.contentSize.height += self.currentHeightPos
                        }
                        else {
                            scrollViewUsed.contentSize.width += self.widthPos
                            self.widthPos = 0
                        }
                    }
                }
                catch let error {
                    print(error.localizedDescription)
                }
            })
            task.resume()
        }
    }
}
