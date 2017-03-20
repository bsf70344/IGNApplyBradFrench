//
//  Post.swift
//  IGNApp
//
//  Created by Bradley French on 3/13/17.
//  Copyright © 2017 Bradley French. All rights reserved.
//

import UIKit

//This is for text scaling.
var fontScale = UIScreen.main.bounds.width/375

//Swift's way of using the Abstract Class type here. We have 2 different types of posts, but they are still posts.
protocol Post {
    var urlString: String {get set}
    var currentHeightPos: CGFloat {get set}
    
    func createOneItem(title:String, imageData:Data, lastItem:Bool, publishTimeAsString:String?) -> (CGFloat, CGFloat)
}


//Extension I made so the classes extending this protocol could use these methods as necessary.
extension Post {
    
    //I needed the frame for quite a few things, just made a method for it.
    func screenRect() -> CGRect {
        return UIScreen.main.bounds
    }
    
    //I made quite a few labels, so I just created a method to handle all the hard work.
    func createLabel(text:String, textColor:UIColor, backgroundColor:UIColor, font:UIFont, frame:CGRect, alignment: NSTextAlignment = .left, numberOfLines:Int = 0) -> UILabel {
        let label = UILabel(frame: frame)
        label.textColor = textColor
        label.textAlignment = alignment
        label.backgroundColor = backgroundColor
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont(name: font.fontName, size: font.pointSize*fontScale)
        label.text = text
        label.numberOfLines = numberOfLines
        return label
    }
    
    //Since some of your images were different, I had to find the ratio for the image, so I could give the appropriate size to the image.
    func findSize(scrollViewSize:CGSize, imageSize:CGSize, width:Bool) -> CGSize{
        if(width) {
            let ratio = scrollViewSize.width/imageSize.width
            return CGSize(width: ratio*imageSize.width, height: ratio*imageSize.height)
        }
        else {
            let ratio = scrollViewSize.height/imageSize.height
            return CGSize(width: ratio*imageSize.width, height: ratio*imageSize.height)
        }
    }
}

//This contains 1 article.
class Article: NSObject, Post {

    internal var urlString: String
    internal var currentHeightPos: CGFloat
    let scrollView:UIScrollView!
    static var articleCounter:Int = 0
    let controller:ViewController!

    //Initialization
    init(urlString: String, currentHeightPos: CGFloat, scrollView:UIScrollView, viewController:ViewController) {
        self.urlString = urlString
        self.currentHeightPos = currentHeightPos
        self.scrollView = scrollView
        self.controller = viewController
        super.init()
    }

    //This creates one article
    func createOneItem(title: String, imageData: Data, lastItem: Bool, publishTimeAsString:String?) -> (CGFloat, CGFloat) {
        
        //This is the red line you had that I was trying to mimic
        let redBox = UIView(frame: CGRect(x: 0, y: currentHeightPos, width: screenRect().width*0.25, height: screenRect().height*0.0015))
        redBox.backgroundColor = UIColor(colorLiteralRed: 130/255, green: 4/255, blue: 25/255, alpha: 1)
        self.scrollView.addSubview(redBox)
        
        //I calculated the sizes prior to drawing; it made creating the box easier.
        let timeLabelSize = CGRect(x: screenRect().width*0.02, y: screenRect().height*0.01, width: screenRect().width*0.955, height: screenRect().height*0.02)
        let titleLabelSize = CGRect(x: screenRect().width*0.02, y: screenRect().height*0.035, width: screenRect().width*0.955, height: screenRect().height*0.065)
        let unaccountedSpace = screenRect().height*(0.01+0.005)
        let box = UIView()
        box.backgroundColor = UIColor(colorLiteralRed: 0.06, green: 0.06, blue: 0.06, alpha: 1)
        self.scrollView.addSubview(box)
        
        //The box, I add the timestamp
        box.addSubview(self.createLabel(text: timeSincePublish(timeAsString: publishTimeAsString!), textColor: UIColor(colorLiteralRed: 0.25, green: 0.25, blue: 0.25, alpha: 1), backgroundColor: .clear, font: UIFont(name: "Courier-Bold", size: 13)!, frame: timeLabelSize))
        
        //Add the title
        box.addSubview(self.createLabel(text: title, textColor: UIColor.white.withAlphaComponent(0.75), backgroundColor: .clear, font: UIFont(name: "Courier-Bold", size: 15)!, frame: titleLabelSize))
        
        //Add the image and find the appropriate size. This is why I have to wait to call the box's frame.
        let image = UIImage(data: imageData)
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = UIColor.red
        imageView.contentMode = .scaleAspectFit
        let size = findSize(scrollViewSize: scrollView.frame.size, imageSize: image!.size, width: true)
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: screenRect().height*0.1), size: size)
        box.addSubview(imageView)
        
        //Now I know the size
        box.frame = CGRect(x: redBox.frame.minX, y: redBox.frame.maxY, width: self.scrollView.frame.width, height: timeLabelSize.height+titleLabelSize.height+imageView.frame.height+unaccountedSpace)
        currentHeightPos += box.frame.height+redBox.frame.height + screenRect().height*0.02
        
        //This provides certain room, depenidng on which # of article we are on, it also calls the video requester, depending on which article we are on. I waas assuming every 2 articles, there are 5 videos.
        if(Article.articleCounter == 1 && !lastItem) {
            self.scrollView.addSubview(self.createLabel(text: "VIDEOS", textColor: UIColor(colorLiteralRed: 0.4, green: 0.4, blue: 0.4, alpha: 1), backgroundColor: .clear, font: UIFont(name: "TrebuchetMS-Bold", size: 13)!, frame: CGRect(x: 0, y: currentHeightPos, width: self.scrollView.frame.width, height: screenRect().height*0.03), alignment: .center))
            currentHeightPos += screenRect().height*0.04
            Article.articleCounter = 0
            self.controller.loadRequest(count: 5, type: "videos")
        }
        else {
            Article.articleCounter += 1
        }
        return (0, currentHeightPos)
    }
    
    //IGN provided a date: I had to find a way to parse it so I could tell how long ago it was. I wasn't sure how far back, so I only used days and never used months or years. So if something is 60 days back, it won't say 2 months, it will say 60 days.
    func timeSincePublish(timeAsString:String) -> String{
        func getOnlyInteger(number:Double) -> String {
            return String(format: "%0.0f", number)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let date = dateFormatter.date(from: timeAsString)
        let seconds = NSDate().timeIntervalSince(date!)
        if(seconds < 60) {
            return "\(getOnlyInteger(number: seconds)) SECONDS AGO"
        }
        else if(seconds/60 < 60) {
            return "\(getOnlyInteger(number: seconds/60)) MINUTES AGO"
        }
        else if(seconds/60/60 < 24) {
            return "\(getOnlyInteger(number: seconds/60/60)) HOURS AGO"
        }
        else {
            return "\(getOnlyInteger(number: seconds/60/60/24)) DAYS AGO"
        }
    }
}

//This contains 5 videos
class Video: NSObject, Post {

    internal var urlString: String
    internal var currentHeightPos: CGFloat
    let scrollView:UIScrollView!
    var widthPos:CGFloat! = 0
    
    //All the utensils I would need to change or create the videos
    init(urlString: String, currentHeightPos: CGFloat, scrollView:UIScrollView, widthPos:CGFloat) {
        self.urlString = urlString
        self.currentHeightPos = currentHeightPos
        self.scrollView = scrollView
        self.widthPos = widthPos
        super.init()
    }

    //This creates 1 video from the given data.
    func createOneItem(title: String, imageData: Data, lastItem: Bool, publishTimeAsString: String?) -> (CGFloat, CGFloat) {
        
        //Create an image from the data.
        let image = UIImage(data: imageData)
        
        //Place the image, and size it properly
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: self.widthPos, y: 0), size: findSize(scrollViewSize: CGSize(width: self.scrollView.frame.width, height: self.scrollView.frame.height*0.75), imageSize: image!.size, width: false)))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        self.scrollView.addSubview(imageView)
        
        //This is the title label, to indicate what video this is.
        self.scrollView.addSubview(self.createLabel(text: title, textColor: UIColor.white.withAlphaComponent(0.75), backgroundColor: .clear, font: UIFont(name: "TrebuchetMS-Bold", size: 14)!, frame: CGRect(x: self.widthPos, y: self.scrollView.frame.height*0.75, width: imageView.frame.width, height: self.scrollView.frame.height*0.25), numberOfLines: 2))
        
        //This is just some positioning pointers to make it look nice.
        widthPos = widthPos + imageView.frame.width
        if(!lastItem) {
            widthPos = widthPos + self.scrollView.frame.width*0.03
        }
        
        //Return the variables changed so positioning stays proper
        return (widthPos, currentHeightPos)
    }
}
