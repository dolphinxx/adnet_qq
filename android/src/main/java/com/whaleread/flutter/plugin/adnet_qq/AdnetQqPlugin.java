package com.whaleread.flutter.plugin.adnet_qq;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** AdnetQqPlugin */
public class AdnetQqPlugin implements MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
  private static final String TAG = AdnetQqPlugin.class.getSimpleName();
  private static Registrar registrar;
  private static AdnetQqPlugin instance;
  private static Map<String, FlutterUnifiedInterstitial> unifiedInterstitialMap = new HashMap<>();

  private SplashAd splashAd;
  private List<String> lackedPermission;
  private int requestReadPhoneState;
  private int requestAccessFineLocation;

  private int _requestCode;

  static Activity getActivity() {
    return registrar.activity();
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    AdnetQqPlugin.registrar = registrar;
    AdnetQqPlugin.instance = new AdnetQqPlugin();
    final MethodChannel channel = new MethodChannel(registrar.messenger(), PluginSettings.PLUGIN_ID);
    channel.setMethodCallHandler(instance);
    registrar.platformViewRegistry().registerViewFactory(PluginSettings.UNIFIED_BANNER_VIEW_ID, new FlutterUnifiedBannerViewFactory(registrar.messenger()));
    registrar.platformViewRegistry().registerViewFactory(PluginSettings.NATIVE_EXPRESS_VIEW_ID, new FlutterNativeExpressViewFactory(registrar.messenger()));
  }

  static void removeInterstitial(String posId) {
    unifiedInterstitialMap.remove(posId);
  }

  @Override
  public void onMethodCall(MethodCall call, @SuppressWarnings("NullableProblems") Result result) {
    switch(call.method) {
      case "config":
        Map arguments = (Map) call.arguments;
        PluginSettings.APP_ID = (String)arguments.get("appId");
        if(PluginSettings.APP_ID == null) {
          result.error("appId must be specified!", null, null);
          return;
        }
        requestReadPhoneState = 0;
        if(((Map)call.arguments).containsKey("requestReadPhoneState")) {
          requestReadPhoneState = (int)((Map)call.arguments).get("requestReadPhoneState");
        }
        requestAccessFineLocation = 0;
        if(((Map)call.arguments).containsKey("requestAccessFineLocation")) {
          requestAccessFineLocation = (int)((Map)call.arguments).get("requestAccessFineLocation");
        }
        // check permissions
        if (Build.VERSION.SDK_INT >= 23 && (requestReadPhoneState > 0 || requestAccessFineLocation > 0)) {
          registrar.addRequestPermissionsResultListener(this);
          checkAndRequestPermission();
        }
        result.success(true);
        break;
      case "createUnifiedInterstitialAd": {
        String posId = (String)((Map)call.arguments).get("posId");
        if(posId == null) {
          result.error("posId cannot be null!", null, null);
          return;
        }
        if(unifiedInterstitialMap.containsKey(posId)) {
          //noinspection ConstantConditions
          unifiedInterstitialMap.get(posId).closeAd();
        }
        unifiedInterstitialMap.put(posId, new FlutterUnifiedInterstitial(posId, registrar.messenger()));
        result.success(true);
        break;
      }
      case "showSplash": {
        String posId = (String)((Map)call.arguments).get("posId");
        String backgroundImage = null;
        if(((Map)call.arguments).containsKey("backgroundImage")) {
          backgroundImage = (String)((Map)call.arguments).get("backgroundImage");
        }
        if(splashAd != null) {
          splashAd.close();
        }
        splashAd = new SplashAd(registrar.activity(), registrar.messenger(), posId, backgroundImage);
        splashAd.show();
        break;
      }
      case "closeSplash": {
        if(splashAd != null) {
          splashAd.close();
          splashAd = null;
        }
        break;
      }
      default:
        result.notImplemented();
    }
  }

  /**
   *
   * ----------非常重要----------
   *
   * Android6.0以上的权限适配简单示例：
   *
   * 如果targetSDKVersion >= 23，那么必须要申请到所需要的权限，再调用广点通SDK，否则广点通SDK不会工作。
   *
   * Demo代码里是一个基本的权限申请示例，请开发者根据自己的场景合理地编写这部分代码来实现权限申请。
   * 注意：下面的`checkSelfPermission`和`requestPermissions`方法都是在Android6.0的SDK中增加的API，如果您的App还没有适配到Android6.0以上，则不需要调用这些方法，直接调用广点通SDK即可。
   */
  @TargetApi(Build.VERSION_CODES.M)
  private void checkAndRequestPermission() {
    lackedPermission = new ArrayList<>();
    Activity activity = AdnetQqPlugin.getActivity();
    if (requestReadPhoneState > 0 && !(activity.checkSelfPermission(Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED)) {
      lackedPermission.add(Manifest.permission.READ_PHONE_STATE);
    }

//        if (!(activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED)) {
//            lackedPermission.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
//        }

    if (requestAccessFineLocation > 0 && !(activity.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED)) {
      lackedPermission.add(Manifest.permission.ACCESS_FINE_LOCATION);
    }

    if (lackedPermission.size() > 0) {
      // 请求所缺少的权限，在onRequestPermissionsResult中再看是否获得权限，如果获得权限就可以调用SDK，否则不要调用SDK。
      String[] requestPermissions = new String[lackedPermission.size()];
      lackedPermission.toArray(requestPermissions);
      registrar.addRequestPermissionsResultListener(this);
      _requestCode = Integer.parseInt(new SimpleDateFormat("MMddHHmmss", Locale.CHINA).format(new Date()));
      activity.requestPermissions(requestPermissions, _requestCode);
      Log.d(TAG, "requesting permissions...");
    }
  }

  private boolean isPermissionsFine(int[] grantResults) {
    for (int i = 0;i < grantResults.length;i++) {
      int grantResult = grantResults[i];
      // 有必须权限未授予
      if (grantResult == PackageManager.PERMISSION_DENIED && ((lackedPermission.get(i).equals(Manifest.permission.ACCESS_FINE_LOCATION) && requestAccessFineLocation == 2) || (lackedPermission.get(i).equals(Manifest.permission.READ_PHONE_STATE) && requestReadPhoneState == 2))) {
        return false;
      }
    }
    return true;
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    Log.d(TAG, "onRequestPermissionsResult " + requestCode);
    Activity activity = AdnetQqPlugin.getActivity();
    if (requestCode == _requestCode) {
      if(!isPermissionsFine(grantResults)) {
        Log.d(TAG, "permissions rejected");
        // 如果用户没有授权，那么应该说明意图，引导用户去设置里面授权。
        Toast.makeText(activity, "应用缺少必要的权限！请点击\"权限\"，打开所需要的权限。", Toast.LENGTH_LONG).show();
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:" + activity.getPackageName()));
        activity.startActivity(intent);
        activity.finish();
      }
      return true;
    }
    return false;
  }
}
