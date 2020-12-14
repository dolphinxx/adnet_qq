//
//  FlutterSplashView.swift
//  adnet_qq
//
//  Created by Dolphin on 2020/12/11.
//

import Foundation

public class FlutterSplashView: NSObject, GDTSplashAdDelegate {
    private static var ad:FlutterSplashView?
    private var splash:GDTSplashAd?
    private let posId: String
    private let channel: FlutterMethodChannel
    private var backgroundImage:String?
    
    public static func showAd(_ posId: String, backgroundImage: String?, messenger: FlutterBinaryMessenger) {
        if ad == nil {
            ad = FlutterSplashView.init(posId, backgroundImage: backgroundImage, messenger: messenger)
        }
        ad?.show()
    }

    init(_ posId: String, backgroundImage: String?, messenger: FlutterBinaryMessenger) {
        self.posId = posId
        self.backgroundImage = backgroundImage
        self.channel = FlutterMethodChannel(name: SPLASH_VIEW_ID, binaryMessenger: messenger)
        super.init()
        self.channel.setMethodCallHandler { [weak self] (flutterMethodCall: FlutterMethodCall, flutterResult: FlutterResult) in self?.onMethodCall(call: flutterMethodCall, result: flutterResult)}
    }

    private func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {
        case "show":
            self.showAd()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func showAd() {
        print("----showAd");
        if let splash = splash {
            splash.delegate = nil
        }
        
        splash = GDTSplashAd.init(placementId: posId)
        if let backgroundImage = self.backgroundImage {
            splash?.backgroundImage = UIImage.init(named: backgroundImage)
        }
        splash?.delegate = self
        splash?.fetchDelay = 5
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
        print("onAdPresent")
        channel.invokeMethod("onAdPresent", arguments:nil)
    }

    public func splashAdDidLoad(_ splashAd: GDTSplashAd!) {
        print("onAdDidLoad")
        splash?.show(in: UIApplication.shared.keyWindow, withBottomView: nil, skip: nil)
        channel.invokeMethod("onAdDidLoad", arguments:nil)
    }
    
    /**
     *  开屏广告展示失败
     */
    public func splashAdFail(toPresent splashAd:GDTSplashAd!, withError error:Error!){
        print("onNoAd \(String(describing: error))")
        self.removeAd()
        channel.invokeMethod("onNoAd", arguments:nil)
    }

    /**
     *  应用进入后台时回调
     *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
     */
    public func splashAdApplicationWillEnterBackground(_ splashAd:GDTSplashAd!){
        print("onAdApplicationWillEnterBackground")
    }

    /**
     *  开屏广告曝光回调
     */
    public func splashAdExposured(_ splashAd:GDTSplashAd!){
        print("onAdExposure")
        channel.invokeMethod("onAdExposure", arguments:nil)
    }

    /**
     *  开屏广告点击回调
     */
    public func splashAdClicked(_ splashAd:GDTSplashAd!) {
        print("onAdClicked")
        channel.invokeMethod("onAdClicked", arguments:nil)
    }

    /**
     *  开屏广告将要关闭回调
     */
    public func splashAdWillClosed(_ splashAd:GDTSplashAd!){
        print("onAdWillClosed")
    }

    /**
     *  开屏广告关闭回调
     */
    public func splashAdClosed(_ splashAd:GDTSplashAd!){
        print("onAdClosed")
        self.removeAd()
        channel.invokeMethod("onAdClosed", arguments:nil)
    }

    /**
     *  开屏广告点击以后即将弹出全屏广告页
     */
    public func splashAdWillPresentFullScreenModal(_ splashAd:GDTSplashAd!){
        print("onAdWillPresentFullScreenModal")
    }

    /**
     *  开屏广告点击以后弹出全屏广告页
     */
    public func splashAdDidPresentFullScreenModal(_ splashAd:GDTSplashAd!){
        print("onAdDidPresentFullScreenModal")
    }

    /**
     *  点击以后全屏广告页将要关闭
     */
    public func splashAdWillDismissFullScreenModal(_ splashAd:GDTSplashAd!){
        print("onAdWillDismissFullScreenModal")
    }

    /**
     *  点击以后全屏广告页已经关闭
     */
    public func splashAdDidDismissFullScreenModal(_ splashAd:GDTSplashAd!){
        print("onAdDismiss")
        self.removeAd()
        channel.invokeMethod("onAdDismiss", arguments:nil)
    }

    /**
     * 开屏广告剩余时间回调
     */
    public func splashAdLifeTime(_ time:UInt){
        //print("onAdLifeTime");
    }
}
