//
//  FlutterNativeExpressView.swift
//  adnet_qq
//
//  Created by Dolphin on 2020/12/13.
//

import Foundation

public class FlutterNativeExpressView: NSObject, FlutterPlatformView, GDTNativeExpressAdDelegete {
    private let channel: FlutterMethodChannel
    private let viewId:Int64
    private let posId: String
    private let container: UIView
    private var adv: GDTNativeExpressAdView?
    private var ad: GDTNativeExpressAd?
    private var layoutNotified: Bool = false
    private let count: Int
    private var minVideoDuration:Int?
    private var maxVideoDuration:Int?
    private var autoPlayMuted:Bool?
    private var detailPageVideoMuted:Bool?
    // iOS only
    private var videoAutoPlayOnWWAN:Bool?

    init(frame: CGRect, viewId: Int64, args: [String: Any], messeneger: FlutterBinaryMessenger) {
        self.viewId = viewId
        self.posId = args["posId"] as! String
        if let count = args["count"] as? Int {
            self.count = count
        } else {
            self.count = 5
        }
        if let minVideoDuration = args["minVideoDuration"] {
            self.minVideoDuration = minVideoDuration as? Int
        }
        if let maxVideoDuration = args["maxVideoDuration"] {
            self.maxVideoDuration = maxVideoDuration as? Int
        }
        if let autoPlayMuted = args["autoPlayMuted"] {
            self.autoPlayMuted = autoPlayMuted as? Bool
        }
        if let detailPageVideoMuted = args["detailPageVideoMuted"] {
            self.detailPageVideoMuted = detailPageVideoMuted as? Bool
        }
        if let options = args["iOSOptions"] as? [String:Any] {
            if let videoAutoPlayOnWWAN = options["videoAutoPlayOnWWAN"] {
                self.videoAutoPlayOnWWAN = videoAutoPlayOnWWAN as? Bool
            }
        }
        self.container = UIView.init(frame: frame)
        self.channel = FlutterMethodChannel(name: "\(NATIVE_EXPRESS_VIEW_ID)_\(viewId)", binaryMessenger: messeneger)
        super.init()
        self.channel.setMethodCallHandler { [weak self] (flutterMethodCall: FlutterMethodCall, flutterResult: FlutterResult) in self?.onMethodCall(call: flutterMethodCall, result: flutterResult)}
    }
    
    public func view() -> UIView {
        //NSLog(@"----view %@",posId);
        return container;
    }

    public func dispose() {
        layoutNotified = false
        if let adv = adv {
            adv.removeFromSuperview();
            ad?.delegate = nil;
            self.adv = nil;
        }
        container.removeFromSuperview();
        channel.setMethodCallHandler(nil);
    }

    public func refreshAd() {
        //print("----refreshAd");
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        if let adv = adv {
            adv.removeFromSuperview();
            ad?.delegate = nil;
            self.adv = nil;
        }
        layoutNotified = false
        self.ad = GDTNativeExpressAd(placementId: posId, adSize: CGSize(width: keyWindow.frame.size.width, height: 0))
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
        ad?.delegate = self
        ad?.load(count)
    }

    private func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {
        case "refresh":
            self.refreshAd()
            result(true)
        case "close", "dispose":
            self.dispose()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /**
     * 拉取原生模板广告成功
     */
    public func nativeExpressAdSuccess(toLoad nativeExpressAd:GDTNativeExpressAd! , views:[GDTNativeExpressAdView]!){
//        print("onAdLoaded");
        channel.invokeMethod("onAdLoaded", arguments: nil)
        if let adv = adv {
            adv.removeFromSuperview()
        }
        let adv = views[0];
        self.adv = adv
        adv.controller = (UIApplication.shared.keyWindow?.rootViewController)!
        adv.render()
        container.addSubview(adv)
    }

    /**
     * 拉取原生模板广告失败
     */
    public func nativeExpressAdFail(toLoad nativeExpressAd:GDTNativeExpressAd, error:Error){
//        print("onNoAd \(error)")
        channel.invokeMethod("onNoAd", arguments:error.localizedDescription)
    }

    /**
     * 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
     */
    public func nativeExpressAdViewRenderSuccess(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onRenderSuccess")
        channel.invokeMethod("onRenderSuccess", arguments:nil)
        // 立即获取height会拿到0（虽然官方文档说已经完成更新），需要延时之后获取
        DispatchQueue.main.asyncAfter(deadline: .now() - 0.1) {[weak self] in
            if let adv = self?.adv,adv.bounds.size.height > 0 {
                self?.layoutNotified = true
                self?.channel.invokeMethod("onLayout", arguments:["width":adv.bounds.size.width, "height": adv.bounds.size.height])
            }
        }
    }

    /**
     * 原生模板广告渲染失败
     */
    public func nativeExpressAdViewRenderFail(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onRenderFail")
        channel.invokeMethod("onRenderFail", arguments:nil)
    }

    /**
     * 原生模板广告曝光回调
     */
    public func nativeExpressAdViewExposure(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdExposure")
        channel.invokeMethod("onAdExposure", arguments:nil)
        // 因为在nativeExpressAdViewRenderSuccess回调中height可能还未更新（虽然文档说已经更新），所以需要在此回调中再次尝试发送onLayout
        if !layoutNotified,let adv = adv,adv.bounds.size.height > 0 {
            channel.invokeMethod("onLayout", arguments:["width":adv.bounds.size.width, "height": adv.bounds.size.height])
        }
    }

    /**
     * 原生模板广告点击回调
     */
    public func nativeExpressAdViewClicked(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdClicked")
        channel.invokeMethod("onAdClicked", arguments:nil)
    }

    /**
     * 原生模板广告被关闭
     */
    public func nativeExpressAdViewClosed(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdClosed")
        channel.invokeMethod("onAdClosed", arguments:nil)
        channel.setMethodCallHandler(nil);
        adv = nil;
    }

    /**
     * 点击原生模板广告以后即将弹出全屏广告页
     */
    public func nativeExpressAdViewWillPresentScreen(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdOpenOverlay")
        channel.invokeMethod("onAdWillPresentScreen", arguments:nil)
    }

    /**
     * 点击原生模板广告以后弹出全屏广告页
     */
    public func nativeExpressAdViewDidPresentScreen(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdDidPresentScreen")
        channel.invokeMethod("onAdDidPresentScreen", arguments:nil)
    }

    /**
     * 全屏广告页将要关闭
     */
    public func nativeExpressAdViewWillDismissScreen(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdWillDismissScreen")
        channel.invokeMethod("onAdWillDismissScreen", arguments:nil)
    }

    /**
     * 全屏广告页已经关闭
     */
    public func nativeExpressAdViewDidDismissScreen(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdCloseOverlay")
        channel.invokeMethod("onAdDidDismissScreen", arguments:nil)
    }

    /**
     * 详解:当点击应用下载或者广告调用系统程序打开时调用
     */
    public func nativeExpressAdViewApplicationWillEnterBackground(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdLeftApplication")
        channel.invokeMethod("onAdLeftApplication", arguments:nil)
    }

    /**
     * 原生模板视频广告 player 播放状态更新回调
     */
    public func nativeExpressAdView(_ nativeExpressAdView:GDTNativeExpressAdView, status:GDTMediaPlayerStatus){
//        print("onAdPlayerStatusChanged")
        channel.invokeMethod("onAdPlayerStatusChanged", arguments:status.rawValue)
    }

    /**
     * 原生视频模板详情页 WillPresent 回调
     */
    public func nativeExpressAdViewWillPresentVideoVC(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdWillPresentVideoVC")
        channel.invokeMethod("onAdWillPresentVideoVC", arguments:nil)
    }

    /**
     * 原生视频模板详情页 DidPresent 回调
     */
    public func nativeExpressAdViewDidPresentVideoVC(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdDidPresentVideoVC")
        channel.invokeMethod("onAdDidPresentVideoVC", arguments:nil)
    }

    /**
     * 原生视频模板详情页 WillDismiss 回调
     */
    public func nativeExpressAdViewWillDismissVideoVC(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdWillDismissVideoVC")
        channel.invokeMethod("onAdWillDismissVideoVC", arguments:nil)
    }

    /**
     * 原生视频模板详情页 DidDismiss 回调
     */
    public func nativeExpressAdViewDidDismissVideoVC(_ nativeExpressAdView:GDTNativeExpressAdView){
//        print("onAdDidDismissVideoVC")
        channel.invokeMethod("onAdDidDismissVideoVC", arguments:nil)
    }
}

public class FlutterNativeExpressViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
            return FlutterNativeExpressView(
                frame: frame,
                viewId: viewId,
                args: args as? [String : Any] ?? [:],
                messeneger: messenger
            )
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
