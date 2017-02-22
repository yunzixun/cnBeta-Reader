//
//  Constants.swift
//  cnBeta-Reader
//
//  Created by Juncheng Han on 12/16/16.
//  Copyright © 2016 JasonH. All rights reserved.
//

struct Constants {
    
    //PingFang SC ["PingFangSC-Ultralight", "PingFangSC-Regular", "PingFangSC-Semibold", "PingFangSC-Thin", "PingFangSC-Light", "PingFangSC-Medium"]
    //Avenir ["Avenir-Medium", "Avenir-HeavyOblique", "Avenir-Book", "Avenir-Light", "Avenir-Roman", "Avenir-BookOblique", "Avenir-MediumOblique", "Avenir-Black", "Avenir-BlackOblique", "Avenir-Heavy", "Avenir-LightOblique", "Avenir-Oblique"]
    
    // MARK: screen info
    static let SCREEN_WIDTH = UIScreen.main.bounds.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.height
    
    // api
    static let API_URL = "https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q=http://rss.cnbeta.com/rss&num=100"
    
    static let API_URL_2 = "http://cloud.feedly.com/v3/streams/contents?streamId=feed%2Fhttp://rss.cnbeta.com/rss&count=100"
    
    // fetch number
    static let FETCH_LIMIT = 20
    
    // font
    static let TITLE_FONT_DETAIL: UIFont = UIFont.init(name: "PingFangSC-Semibold", size: 22) ?? UIFont.systemFont(ofSize: 22)
    static let TITLE_FONT_FEED: UIFont = UIFont.init(name: "PingFangSC-Semibold", size: 20) ?? UIFont.systemFont(ofSize: 20)
    
    static let CONTENT_FONT_DETAIL_NORMAL: UIFont = UIFont.init(name: "PingFangSC-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
    static let CONTENT_FONT_FEED: UIFont = UIFont.init(name: "PingFangSC-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
    
    static let TIME_LABEL_FONT_DETAIL: UIFont = UIFont.init(name: "Avenir", size: 12) ?? UIFont.systemFont(ofSize: 12)
    static let TIME_LABEL_FONT_FEED: UIFont = UIFont.init(name: "Avenir-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
    
    // colors
    static let TITLE_TEXT_COLOR: UIColor =  UIColor(red:0, green:0, blue:0, alpha:1.0)
    
    static let SUMMARY_TEXT_COLOR: UIColor = UIColor(red:0.45, green:0.46, blue:0.47, alpha:1.0)
    
    static let TIME_LABEL_TEXT_COLOR: UIColor = UIColor(red:0.95, green:0.43, blue:0.39, alpha:1.0)
    
    static let All_ICONS_COLOR: UIColor = UIColor(red:0.95, green:0.43, blue:0.39, alpha:1.0)
}
