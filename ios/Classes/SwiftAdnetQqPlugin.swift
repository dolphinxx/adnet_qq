import Flutter
import UIKit
import AppTrackingTransparency

public class SwiftAdnetQqPlugin: NSObject, FlutterPlugin {
    static var interstitials: [String:FlutterUnifiedInterstitialView] = [:]
    var pluginRegistrar: FlutterPluginRegistrar
    var splashAd:FlutterSplashView?
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.whaleread.flutter.plugin.adnet_qq", binaryMessenger: registrar.messenger())
    let instance = SwiftAdnetQqPlugin(registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(FlutterUnifiedBannerViewFactory(messeneger: registrar.messenger()), withId: UNIFIED_BANNER_VIEW_ID)
    registrar.register(FlutterNativeExpressViewFactory(messenger: registrar.messenger()), withId: NATIVE_EXPRESS_VIEW_ID)
  }
    
    public init(_ registrar: FlutterPluginRegistrar) {
        pluginRegistrar = registrar
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "config":
        guard let args = call.arguments as? [String: Any],
            let appId = args["appId"] as? String
            else {
                result(FlutterError(code: "appId", message: "invalid arguments", details: call.arguments))
                return
        }
        
        APP_ID = appId;
        GDTSDKConfig.registerAppId(appId);
        
        let requestIDFA = args["requestIDFA"] as? Int
        if requestIDFA == 1 {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: {status in
                    // 不管是否授权都得显示广告
                    result(true)
                })
            } else {
                // Fallback on earlier versions
                result(true)
            }
            return
        }
        result(true)
        return
    case "showSplash":
        guard let args = call.arguments as? [String: Any],
              let posId = args["posId"] as? String
        else {
            result(FlutterError(code: "posId", message: "invalid arguments", details: call.arguments))
            return
        }
        let backgroundImage = args["backgroundImage"] as? String
        let backgroundColor = args["backgroundColor"] as? Int
        let fetchDelay = args["fetchDelay"] as? CGFloat
        let fullScreen = args["fullScreen"] as? Int
        let logo = args["logo"] as? String
        if let splashAd = splashAd {
            splashAd.close()
        }
        splashAd = FlutterSplashView.init(posId, backgroundImage: backgroundImage, backgroundColor: backgroundColor, fetchDelay: fetchDelay, fullScreen: fullScreen == 1, logo: logo, messenger: pluginRegistrar.messenger())
        splashAd?.show()
        result(true)
        return
    case "closeSplash":
        splashAd?.close()
        result(true)
        return
    case "createUnifiedInterstitialAd":
        guard let args = call.arguments as? [String: Any],
              let posId = args["posId"] as? String
        else {
            result(FlutterError(code: "posId", message: "invalid arguments", details: call.arguments))
            return
        }
        if(SwiftAdnetQqPlugin.interstitials[posId] != nil) {
            SwiftAdnetQqPlugin.interstitials[posId]?.dispose()
        }
        SwiftAdnetQqPlugin.interstitials[posId] = FlutterUnifiedInterstitialView(posId, options: args["iOSOptions"] as? [String : Any], messeneger: pluginRegistrar.messenger())
        result(true)
        return
    default:
        result(FlutterMethodNotImplemented);
    }
  }

    public static func removeInterstitial(_ posId:String) {
        SwiftAdnetQqPlugin.interstitials.removeValue(forKey: posId);
    }
}
