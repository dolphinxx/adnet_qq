import Flutter
import UIKit

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
        result(true);
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
        if let splashAd = splashAd {
            splashAd.close()
        }
        splashAd = FlutterSplashView.init(posId, backgroundImage: backgroundImage, backgroundColor: backgroundColor, fetchDelay: fetchDelay, messenger: pluginRegistrar.messenger())
        splashAd?.show()
        result(true)
    case "closeSplash":
        splashAd?.close()
        result(true)
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
    default:
        result(FlutterMethodNotImplemented);
    }
  }

    public static func removeInterstitial(_ posId:String) {
        SwiftAdnetQqPlugin.interstitials.removeValue(forKey: posId);
    }
}
