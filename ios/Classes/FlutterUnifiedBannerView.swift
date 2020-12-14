//
//  FlutterUnifiedBannerView.swift
//  adnet_qq
//
//  Created by Dolphin on 2020/12/11.
//

import Foundation
import Flutter

public class FlutterUnifiedBannerView:NSObject, FlutterPlatformView, GDTUnifiedBannerViewDelegate {
    private let channel: FlutterMethodChannel
    private let viewId:Int64
    private let frame: CGRect
    private let posId: String
    private var bv: GDTUnifiedBannerView?

    init(frame: CGRect, viewId: Int64, args: [String: Any], messeneger: FlutterBinaryMessenger) {
        self.viewId = viewId
        self.posId = args["posId"] as! String
        self.frame = frame
        self.channel = FlutterMethodChannel(name: "\(UNIFIED_BANNER_VIEW_ID)_\(viewId)", binaryMessenger: messeneger)
        super.init()
        self.channel.setMethodCallHandler { [weak self] (flutterMethodCall: FlutterMethodCall, flutterResult: FlutterResult) in self?.onMethodCall(call: flutterMethodCall, result: flutterResult)}
    }

    public func view() -> UIView {
        return getView()
    }
    
    private func dispose() {
        bv?.removeFromSuperview()
        bv = nil
        channel.setMethodCallHandler(nil)
    }
    
    private func getView() -> GDTUnifiedBannerView {
        if let bv = bv {
            return bv
        }
        let rect = frame.width == 0 ? CGRect(x: 0, y: 0, width: 1, height: 1) : frame
        let bv = GDTUnifiedBannerView.init(frame: rect, placementId: self.posId, viewController: (UIApplication.shared.keyWindow?.rootViewController)!)
        self.bv = bv
        bv.animated = false
        bv.delegate = self
        return bv
    }
    
    private func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch call.method {
        case "refresh":
            self.getView().loadAdAndShow()
            result(true)
        case "close", "dispose":
            self.dispose()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    /**
     *  请求广告条数据成功后调用
     *  当接收服务器返回的广告数据成功后调用该函数
     */
    public func unifiedBannerViewDidLoad(_ unifiedBannerView:GDTUnifiedBannerView)
    {
        //print("onAdReceived")
        self.channel.invokeMethod("onAdReceived", arguments: nil);
    }

    /**
     *  请求广告条数据失败后调用
     *  当接收服务器返回的广告数据失败后调用该函数
     */
    public func unifiedBannerViewFailed(toLoad:GDTUnifiedBannerView, error: Error)
    {
        //print("onNoAd \(error)")
        self.channel.invokeMethod("onNoAd", arguments:error.localizedDescription);
    }

    /**
     *  banner2.0曝光回调
     */
    public func unifiedBannerViewWillExpose(_ unifiedBannerView: GDTUnifiedBannerView)
    {
        //print("onAdExposure")
        self.channel.invokeMethod("onAdExposure", arguments:nil);
    }

    /**
     *  banner2.0点击回调
     */
    public func unifiedBannerViewClicked(_ unifiedBannerView:GDTUnifiedBannerView)
    {
        //print("onAdClicked")
        self.channel.invokeMethod("onAdClicked", arguments:nil);
    }

    /**
     *  banner2.0广告点击以后即将弹出全屏广告页
     */
    public func unifiedBannerViewWillPresentFullScreenModal(_ unifiedBannerView:GDTUnifiedBannerView)
    {
        
    }

    /**
     *  banner2.0广告点击以后弹出全屏广告页完毕
     */
    public func unifiedBannerViewDidPresentFullScreenModal(_ unifiedBannerView:GDTUnifiedBannerView)
    {
        //print("onAdOpenOverlay")
        self.channel.invokeMethod("onAdOpenOverlay", arguments:nil);
    }

    /**
     *  全屏广告页即将被关闭
     */
    public func unifiedBannerViewWillDismissFullScreenModal(_ unifiedBannerView:GDTUnifiedBannerView)
    {
        
    }

    /**
     *  全屏广告页已经被关闭
     */
    public func unifiedBannerViewDidDismissFullScreenModal(_ unifiedBannerView:GDTUnifiedBannerView)
    {
        //print("onAdCloseOverlay")
        self.channel.invokeMethod("onAdCloseOverlay", arguments:nil);
    }

    /**
     *  当点击应用下载或者广告调用系统程序打开
     */
    public func unifiedBannerViewWillLeaveApplication(_ unifiedBannerView:GDTUnifiedBannerView)
    {
        //print("onAdLeftApplication")
        self.channel.invokeMethod("onAdLeftApplication", arguments:nil)
    }

    /**
     *  banner2.0被用户关闭时调用
     */
    public func unifiedBannerViewWillClose(_ unifiedBannerView:GDTUnifiedBannerView)
    {
        //print("onAdClosed")
        self.dispose()
        self.channel.invokeMethod("onAdClosed", arguments:nil);
        self.bv = nil;
    }
}

public class FlutterUnifiedBannerViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    
    init(messeneger: FlutterBinaryMessenger) {
        self.messenger = messeneger
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
            return FlutterUnifiedBannerView(
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
