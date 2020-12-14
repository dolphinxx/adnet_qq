package com.whaleread.flutter.plugin.adnet_qq;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;

import com.qq.e.comm.managers.GDTADManager;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
//import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.platform.PlatformViewRegistry;

/** AdnetQqPlugin */
public class AdnetQqPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
  private static final String TAG = AdnetQqPlugin.class.getSimpleName();
  private static AdnetQqPlugin instance;
  private static final Map<String, FlutterUnifiedInterstitial> unifiedInterstitialMap = new HashMap<>();

  private SplashAd splashAd;
  private List<String> lackedPermission;
  private int requestReadPhoneState;
  private int requestAccessFineLocation;
  private Activity activity;
  private FlutterPluginBinding flutterPluginBinding;
  private static PluginRegistry.Registrar registrar;

  private int _requestCode;

  static Activity getActivity() {
    return instance.activity;
  }

  public AdnetQqPlugin() {
    instance = this;
  }

  private void init(Context applicationContext, BinaryMessenger messenger, PlatformViewRegistry platformViewRegistry) {
//    AdnetQqPlugin.instance = new AdnetQqPlugin();
    final MethodChannel channel = new MethodChannel(messenger, PluginSettings.PLUGIN_ID);
    channel.setMethodCallHandler(instance);
    platformViewRegistry.registerViewFactory(PluginSettings.UNIFIED_BANNER_VIEW_ID, new FlutterUnifiedBannerViewFactory(messenger));
    platformViewRegistry.registerViewFactory(PluginSettings.NATIVE_EXPRESS_VIEW_ID, new FlutterNativeExpressViewFactory(messenger));
  }

//  /** Plugin registration. */
//  public static void registerWith(PluginRegistry.Registrar registrar) {
//    AdnetQqPlugin.registrar = registrar;
//    final AdnetQqPlugin instance = new AdnetQqPlugin();
//    instance.init(registrar.context(), registrar.messenger(), registrar.platformViewRegistry());
//  }

  static void removeInterstitial(String posId) {
    unifiedInterstitialMap.remove(posId);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
    this.flutterPluginBinding = flutterPluginBinding;
    init(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger(), flutterPluginBinding.getPlatformViewRegistry());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding flutterPluginBinding) {

  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    this.activity = activityPluginBinding.getActivity();
    activityPluginBinding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    this.activity = activityPluginBinding.getActivity();
    activityPluginBinding.addRequestPermissionsResultListener(this);
  }

  @Override
  public void onDetachedFromActivity() {
    this.activity = null;
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
        GDTADManager.getInstance().initWith(getActivity(), PluginSettings.APP_ID);
        if(arguments.get("adChannel") != null) {
          com.qq.e.comm.managers.setting.GlobalSetting.setChannel((int)arguments.get("adChannel"));
        }
        requestReadPhoneState = 0;
        if(arguments.containsKey("requestReadPhoneState")) {
          requestReadPhoneState = (int)arguments.get("requestReadPhoneState");
        }
        requestAccessFineLocation = 0;
        if(arguments.containsKey("requestAccessFineLocation")) {
          requestAccessFineLocation = (int)arguments.get("requestAccessFineLocation");
        }
        // check permissions
        if (Build.VERSION.SDK_INT >= 23 && (requestReadPhoneState > 0 || requestAccessFineLocation > 0)) {
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
        unifiedInterstitialMap.put(posId, new FlutterUnifiedInterstitial(posId, flutterPluginBinding.getBinaryMessenger(), (Map)call.arguments));
        result.success(true);
        break;
      }
      case "showSplash": {
        String posId = (String)((Map)call.arguments).get("posId");
        String backgroundImage = null;
        if(((Map)call.arguments).get("backgroundImage") != null) {
          backgroundImage = (String)((Map)call.arguments).get("backgroundImage");
        }
        Integer fetchDelay = (Integer)((Map)call.arguments).get("fetchDelay");
        if(splashAd != null) {
          splashAd.close();
        }
        splashAd = new SplashAd(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger(), posId, backgroundImage, fetchDelay);
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
//      registrar.addRequestPermissionsResultListener(this);
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
