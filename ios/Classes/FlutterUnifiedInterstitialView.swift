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
    
    init(_ posId: String, messeneger: FlutterBinaryMessenger) {
        self.posId = posId
        self.channel = FlutterMethodChannel(name: "\(UNIFIED_INTERSTITIAL_VIEW_ID)_\(posId)", binaryMessenger: messeneger)
        super.init()
        self.channel.setMethodCallHandler { [weak self] (flutterMethodCall: FlutterMethodCall, flutterResult: FlutterResult) in self?.onMethodCall(call: flutterMethodCall, result: flutterResult)}
    }
    
    private func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {
        case "load":
            self.loadAd()
            result(true)
        case "show","popup":
            self.show()
            result(true)
        case "close", "dispose":
            self.dispose()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func loadAd(){
        if (self.ad != nil) {
            self.ad?.delegate = nil;
        }
        self.ad = GDTUnifiedInterstitialAd(placementId: posId);
        self.ad?.delegate = self;
        self.ad?.load();
    }

    private func show() {
        if(UIApplication.shared.keyWindow?.rootViewController != nil){
            self.ad?.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
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
		self.channel.invokeMethod("willPresentScreen", arguments:nil);
    }

    /**
     *  插屏2.0广告视图展示成功回调
     *  插屏2.0广告展示成功回调该函数
     */
    public func unifiedInterstitialDidPresentScreen(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdDidPresentScreen");
		self.channel.invokeMethod("didPresentScreen", arguments:nil);
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
		self.channel.invokeMethod("willPresentFullScreenModal", arguments:nil);
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
		self.channel.invokeMethod("willDismissFullScreenModal", arguments:nil);
    }

    /**
     *  全屏广告页被关闭
     */
    public func unifiedInterstitialAdDidDismissFullScreenModal(_ unifiedInterstitial:GDTUnifiedInterstitialAd){
        //print("onAdDidDismissFullScreenModal");
		self.channel.invokeMethod("didDismissFullScreenModal", arguments:nil);
    }
}
