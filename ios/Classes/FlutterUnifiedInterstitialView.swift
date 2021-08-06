//
//  FlutterUnifiedInterstitialView.swift
//  adnet_qq
//
//  Created by Dolphin on 2020/12/11.
//

import Foundation

public class FlutterUnifiedInterstitialView: NSObject, GDTUnifiedInterstitialAdDelegate {
    private var ad:GDTUnifiedInterstitialAd?
    private let posId: String
    private let channel: FlutterMethodChannel
    
    private var minVideoDuration:Int?
    private var maxVideoDuration:Int?
    private var autoPlayMuted:Bool?
    private var detailPageVideoMuted:Bool?
    
    // iOS only
    private var videoAutoPlayOnWWAN:Bool?
    
    init(_ posId: String, options:[String:Any]?, messeneger: FlutterBinaryMessenger) {
        self.posId = posId
        if let options = options {
            if let minVideoDuration = options["minVideoDuration"] {
                self.minVideoDuration = minVideoDuration as? Int
            }
            if let maxVideoDuration = options["maxVideoDuration"] {
                self.maxVideoDuration = maxVideoDuration as? Int
            }
            if let autoPlayMuted = options["autoPlayMuted"] {
                self.autoPlayMuted = autoPlayMuted as? Bool
            }
            if let detailPageVideoMuted = options["detailPageVideoMuted"] {
                self.detailPageVideoMuted = detailPageVideoMuted as? Bool
            }
            if let _options = options["iOSOptions"] as? [String:Any] {
                if let videoAutoPlayOnWWAN = _options["videoAutoPlayOnWWAN"] {
                    self.videoAutoPlayOnWWAN = videoAutoPlayOnWWAN as? Bool
                }
            }
        }
        self.channel = FlutterMethodChannel(name: "\(UNIFIED_INTERSTITIAL_VIEW_ID)_\(posId)", binaryMessenger: messeneger)
        super.init()
        self.channel.setMethodCallHandler { [weak self] (flutterMethodCall: FlutterMethodCall, flutterResult: FlutterResult) in self?.onMethodCall(call: flutterMethodCall, result: flutterResult)}
    }
    
    private func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {
        case "load":
            self.loadAd()
            result(true)
        case "loadFullScreen":
            self.loadFullScreenAd()
            result(true)
        case "show","popup":
            self.show()
            result(true)
        case "showFullScreen":
            self.showFullScreen()
            result(true)
        case "close", "dispose":
            self.dispose()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func prepareLoadAd() {
        if (self.ad != nil) {
            self.ad?.delegate = nil;
        }
        self.ad = GDTUnifiedInterstitialAd(placementId: posId);
        self.ad?.delegate = self;
        if let maxVideoDuration = maxVideoDuration {
            ad?.maxVideoDuration = maxVideoDuration
        }
        if let minVideoDuration = minVideoDuration {
            ad?.minVideoDuration = minVideoDuration
        }
        if let videoAutoPlayOnWWAN = videoAutoPlayOnWWAN {
            ad?.videoAutoPlayOnWWAN = videoAutoPlayOnWWAN
        }
        if let autoPlayMuted = autoPlayMuted {
            ad?.videoMuted = autoPlayMuted
        }
        if let detailPageVideoMuted = detailPageVideoMuted {
            ad?.detailPageVideoMuted = detailPageVideoMuted
        }
    }

    private func loadAd(){
        self.prepareLoadAd()
        self.ad?.load()
    }
    
    private func loadFullScreenAd() {
        self.prepareLoadAd()
        self.ad?.loadFullScreenAd()
    }

    private func show() {
        if(UIApplication.shared.keyWindow?.rootViewController != nil){
            self.ad?.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
        }
    }
    
    private func showFullScreen() {
        if(UIApplication.shared.keyWindow?.rootViewController != nil){
            self.ad?.presentFullScreenAd(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
        }
    }

    public func dispose() {
        self.ad?.delegate = nil
        self.ad = nil
        channel.setMethodCallHandler(nil)
        SwiftAdnetQqPlugin.removeInterstitial(posId)
    }

    /**
     *  插屏2.0广告预加载成功回调
     *  当接收服务器返回的广告数据成功后调用该函数
     */
    public func unifiedInterstitialSuccess(toLoad:GDTUnifiedInterstitialAd){
        //print("onAdReceived");
        self.channel.invokeMethod("onAdReceived", arguments:nil);
    }

    /**
     *  插屏2.0广告预加载失败回调
     *  当接收服务器返回的广告数据失败后调用该函数
     */
    public func unifiedInterstitialFail(toLoad:GDTUnifiedInterstitialAd, error: Error) {
        //print("onNoAd \(error)");
        self.channel.invokeMethod("onNoAd", arguments:error.localizedDescription);
    }

    /**
     *  插屏2.0广告将要展示回调
     *  插屏2.0广告即将展示回调该函数
     */
    public func unifiedInterstitialWillPresentScreen(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdWillPresentScreen");
		self.channel.invokeMethod("onAdWillPresentScreen", arguments:nil);
    }

    /**
     *  插屏2.0广告视图展示成功回调
     *  插屏2.0广告展示成功回调该函数
     */
    public func unifiedInterstitialDidPresentScreen(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdDidPresentScreen");
		self.channel.invokeMethod("onAdDidPresentScreen", arguments:nil);
    }

    /**
     *  插屏2.0广告展示结束回调
     *  插屏2.0广告展示结束回调该函数
     */
    public func unifiedInterstitialDidDismissScreen(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdClosed");
        self.channel.invokeMethod("onAdClosed", arguments:nil);
    }

    /**
     *  当点击下载应用时会调用系统程序打开其它App或者Appstore时回调
     */
    public func unifiedInterstitialWillLeaveApplication(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdLeftApplication");
        self.channel.invokeMethod("onAdLeftApplication", arguments:nil);
    }

    /**
     *  插屏2.0广告曝光回调
     */
    public func unifiedInterstitialWillExposure(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdExposure");
        self.channel.invokeMethod("onAdExposure", arguments:nil);
    }

    /**
     *  插屏2.0广告点击回调
     */
    public func unifiedInterstitialClicked(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdClicked");
        self.channel.invokeMethod("onAdClicked", arguments:nil);
    }

    /**
     *  点击插屏2.0广告以后即将弹出全屏广告页
     */
    public func unifiedInterstitialAdWillPresentFullScreenModal(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdWillPresentFullScreenModal");
		self.channel.invokeMethod("onAdWillPresentFullScreenModal", arguments:nil);
    }

    /**
     *  点击插屏2.0广告以后弹出全屏广告页
     */
    public func unifiedInterstitialAdDidPresentFullScreenModal(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdOpened");
        self.channel.invokeMethod("onAdOpened", arguments:nil);
    }

    /**
     *  全屏广告页将要关闭
     */
    public func unifiedInterstitialAdWillDismissFullScreenModal(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdWillDismissFullScreenModal");
		self.channel.invokeMethod("onAdWillDismissFullScreenModal", arguments:nil);
    }

    /**
     *  全屏广告页被关闭
     */
    public func unifiedInterstitialAdDidDismissFullScreenModal(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdDidDismissFullScreenModal");
		self.channel.invokeMethod("onAdDidDismissFullScreenModal", arguments:nil);
    }
    
    /**
     * 插屏2.0视频广告 player 播放状态更新回调
     */
    public func unifiedInterstitialAd(_ unifiedInterstitial:GDTUnifiedInterstitialAd, playerStatusChanged:GDTMediaPlayerStatus) {
        self.channel.invokeMethod("onAdPlayerStatusChanged", arguments:playerStatusChanged.rawValue);
    }

    /**
     * 插屏2.0视频广告详情页 WillPresent 回调
     */
    public func unifiedInterstitialAdViewWillPresentVideoVC(_ unifiedInterstitial:GDTUnifiedInterstitialAd) {
        self.channel.invokeMethod("onAdWillPresentVideoVC", arguments:nil);
    }

    /**
     * 插屏2.0视频广告详情页 DidPresent 回调
     */
    public func unifiedInterstitialAdViewDidPresentVideoVC(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        self.channel.invokeMethod("onAdDidPresentVideoVC", arguments:nil);
    }

    /**
     * 插屏2.0视频广告详情页 WillDismiss 回调
     */
    public func unifiedInterstitialAdViewWillDismissVideoVC(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        self.channel.invokeMethod("onAdWillDismissVideoVC", arguments:nil);
    }

    /**
     * 插屏2.0视频广告详情页 DidDismiss 回调
     */
    public func unifiedInterstitialAdViewDidDismissVideoVC(_ unifiedInterstitial:GDTUnifiedInterstitialAd) {
        self.channel.invokeMethod("onAdDidDismissVideoVC", arguments:nil);
    }
    
    /**
     *  插屏2.0广告渲染成功
     *  建议在此回调后展示广告
     */
    public func unifiedInterstitialRenderSuccess(_ unifiedInterstitial:GDTUnifiedInterstitialAd) {
        self.channel.invokeMethod("onRenderSuccess", arguments: nil);
    }

    /**
     *  插屏2.0广告渲染失败
     */
    public func unifiedInterstitialRenderFail(_ unifiedInterstitial:GDTUnifiedInterstitialAd, error:Error) {
        self.channel.invokeMethod("onRenderFailed", arguments: nil);
    }
}
