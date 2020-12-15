//
//  FlutterSplashView.swift
//  adnet_qq
//
//  Created by Dolphin on 2020/12/11.
//

import Foundation

public class FlutterSplashView: NSObject, GDTSplashAdDelegate {
    private var splash:GDTSplashAd?
    private let posId: String
    private let channel: FlutterMethodChannel
    private var backgroundImage:String?
    private var backgroundColor:Int?
    private var fetchDelay:CGFloat

    init(_ posId: String, backgroundImage: String?, backgroundColor: Int?, fetchDelay:CGFloat?, messenger: FlutterBinaryMessenger) {
        self.posId = posId
        self.backgroundImage = backgroundImage
        self.backgroundColor = backgroundColor
        self.fetchDelay = fetchDelay ?? 3000
        self.channel = FlutterMethodChannel(name: SPLASH_VIEW_ID, binaryMessenger: messenger)
        super.init()
    }

    public func showAd() {
        if let splash = splash {
            splash.delegate = nil
        }
        
        splash = GDTSplashAd.init(placementId: posId)
        if let backgroundImage = self.backgroundImage {
            splash?.backgroundImage = UIImage.init(named: backgroundImage)
        }
        if let backgroundColor = backgroundColor {
            let iBlue = backgroundColor & 0xFF
                    let iGreen =  (backgroundColor >> 8) & 0xFF
                    let iRed =  (backgroundColor >> 16) & 0xFF
                    let iAlpha =  (backgroundColor >> 24) & 0xFF
            splash?.backgroundColor = UIColor.init(red: CGFloat(iRed)/255, green: CGFloat(iGreen)/255, blue: CGFloat(iBlue)/255, alpha: CGFloat(iAlpha)/255)
        }
        splash?.delegate = self
        splash?.fetchDelay = self.fetchDelay
        splash?.load()
    }

    public func show() {
        self.showAd()
    }

    public func close() {
        self.removeAd()
    }

    public func removeAd() {
        //[bg removeFromSuperview];
    //    [UIApplication.sharedApplication.keyWindow makeKeyAndVisible];
        splash?.delegate = nil
        splash = nil
    }

    /**
     *  开屏广告成功展示
     */
    public func splashAdSuccessPresentScreen(_ splashAd:GDTSplashAd!){
//        print("onAdPresent")
        channel.invokeMethod("onAdPresent", arguments:nil)
    }

    public func splashAdDidLoad(_ splashAd: GDTSplashAd!) {
//        print("onAdDidLoad")
        splash?.show(in: UIApplication.shared.keyWindow, withBottomView: nil, skip: nil)
        channel.invokeMethod("onAdLoaded", arguments:nil)
    }
    
    /**
     *  开屏广告展示失败
     */
    public func splashAdFail(toPresent splashAd:GDTSplashAd!, withError error:Error!){
//        print("onNoAd \(String(describing: error))")
        self.removeAd()
        channel.invokeMethod("onNoAd", arguments:error.localizedDescription)
    }

    /**
     *  应用进入后台时回调
     *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
     */
    public func splashAdApplicationWillEnterBackground(_ splashAd:GDTSplashAd!){
//        print("onAdApplicationWillEnterBackground")
        channel.invokeMethod("onApplicationWillEnterBackground", arguments:nil)
    }

    /**
     *  开屏广告曝光回调
     */
    public func splashAdExposured(_ splashAd:GDTSplashAd!){
//        print("onAdExposure")
        channel.invokeMethod("onAdExposure", arguments:nil)
    }

    /**
     *  开屏广告点击回调
     */
    public func splashAdClicked(_ splashAd:GDTSplashAd!) {
//        print("onAdClicked")
        channel.invokeMethod("onAdClicked", arguments:nil)
    }

    /**
     *  开屏广告将要关闭回调
     */
    public func splashAdWillClosed(_ splashAd:GDTSplashAd!){
//        print("onAdWillClosed")
        channel.invokeMethod("onAdWillClose", arguments:nil)
    }

    /**
     *  开屏广告关闭回调
     */
    public func splashAdClosed(_ splashAd:GDTSplashAd!){
//        print("onAdClosed")
        self.removeAd()
        channel.invokeMethod("onAdClosed", arguments:nil)
    }

    /**
     *  开屏广告点击以后即将弹出全屏广告页
     */
    public func splashAdWillPresentFullScreenModal(_ splashAd:GDTSplashAd!){
//        print("onAdWillPresentFullScreenModal")
        channel.invokeMethod("onAdWillPresentFullScreenModal", arguments:nil)
    }

    /**
     *  开屏广告点击以后弹出全屏广告页
     */
    public func splashAdDidPresentFullScreenModal(_ splashAd:GDTSplashAd!){
//        print("onAdDidPresentFullScreenModal")
        channel.invokeMethod("onAdDidPresentFullScreenModal", arguments:nil)
    }

    /**
     *  点击以后全屏广告页将要关闭
     */
    public func splashAdWillDismissFullScreenModal(_ splashAd:GDTSplashAd!){
//        print("onAdWillDismissFullScreenModal")
        channel.invokeMethod("onAdWillDismissFullScreenModal", arguments:nil)
    }

    /**
     *  点击以后全屏广告页已经关闭
     */
    public func splashAdDidDismissFullScreenModal(_ splashAd:GDTSplashAd!){
//        print("onAdDismiss")
        self.removeAd()
        channel.invokeMethod("onAdDismiss", arguments:nil)
    }

    /**
     * 开屏广告剩余时间回调
     */
    public func splashAdLifeTime(_ time:UInt){
        //print("onAdLifeTime");
        channel.invokeMethod("onAdTick", arguments:time)
    }
}
