package com.whaleread.flutter.plugin.adnet_qq;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.qq.e.ads.splash.SplashAD;
import com.qq.e.ads.splash.SplashADListener;
import com.qq.e.comm.util.AdError;

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class SplashAd implements MethodChannel.MethodCallHandler, PluginRegistry.RequestPermissionsResultListener, SplashADListener {
    private static final String TAG = SplashAd.class.getSimpleName();

    private final MethodChannel methodChannel;

    private String posId;
    private FrameLayout container;
    private SplashAD splashAD;
//    /**
//     * 为防止无广告时造成视觉上类似于"闪退"的情况，设定无广告时页面跳转根据需要延迟一定时间，demo
//     * 给出的延时逻辑是从拉取广告开始算开屏最少持续多久，仅供参考，开发者可自定义延时逻辑，如果开发者采用demo
//     * 中给出的延时逻辑，也建议开发者考虑自定义minSplashTimeWhenNoAD的值（单位ms）
//     **/
//    private int minSplashTimeWhenNoAD = 1000;
//    /**
//     * 记录拉取广告的时间
//     */
//    private long fetchSplashADTime = 0;
//    private Handler handler = new Handler(Looper.getMainLooper());

    public SplashAd(Context context, BinaryMessenger messenger, String posId, String backgroundImage) {
        if(PluginSettings.APP_ID == null) {
            throw new IllegalStateException("App Id must be configured before creating ad view");
        }
        this.methodChannel = new MethodChannel(messenger, PluginSettings.PLUGIN_ID + "/splash" );
        this.methodChannel.setMethodCallHandler(this);
        this.posId = posId;
        container = new FrameLayout(context);
        container.setBackgroundColor(Color.WHITE);
        Activity activity = AdnetQqPlugin.getActivity();
        if(backgroundImage != null) {
            try
            {
                PackageManager manager = activity.getPackageManager();
                Resources resources = manager.getResourcesForApplication(backgroundImage.substring(0, backgroundImage.indexOf(":")));
                int resId = resources.getIdentifier(backgroundImage, null, null);
                Drawable drawable = resources.getDrawable(resId);
                container.setBackground(drawable);
            } catch (Exception e) {
                Log.e(TAG, "failed to set background for splash ad, resource:" + backgroundImage, e);
            }
        }
        container.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        activity.addContentView(container, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    }

    public void show() {
        this.showAd();
    }

    public void close() {
        methodChannel.setMethodCallHandler(null);
        if(splashAD != null) {
            ((ViewGroup)container.getParent()).removeView(container);
            splashAD = null;
        }
    }

    private void showAd() {
        AdnetQqPlugin.getRegistrar().addRequestPermissionsResultListener(this);
        // 如果targetSDKVersion >= 23，就要申请好权限。如果您的App没有适配到Android6.0（即targetSDKVersion < 23），那么只需要在这里直接调用fetchSplashAD接口。
        if (Build.VERSION.SDK_INT >= 23) {
            checkAndRequestPermission();
        } else {
            // 如果是Android6.0以下的机器，默认在安装时获得了所有权限，可以直接调用SDK
            fetchSplashAD(AdnetQqPlugin.getActivity(), null, PluginSettings.APP_ID, posId, this, 0);
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
        List<String> lackedPermission = new ArrayList<String>();
        Activity activity = AdnetQqPlugin.getActivity();
        if (!(activity.checkSelfPermission(Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED)) {
            lackedPermission.add(Manifest.permission.READ_PHONE_STATE);
        }

        if (!(activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED)) {
            lackedPermission.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
        }

        if (!(activity.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED)) {
            lackedPermission.add(Manifest.permission.ACCESS_FINE_LOCATION);
        }

        // 权限都已经有了，那么直接调用SDK
        if (lackedPermission.size() == 0) {
            fetchSplashAD(activity, null, PluginSettings.APP_ID, posId, this, 0);
        } else {
            // 请求所缺少的权限，在onRequestPermissionsResult中再看是否获得权限，如果获得权限就可以调用SDK，否则不要调用SDK。
            String[] requestPermissions = new String[lackedPermission.size()];
            lackedPermission.toArray(requestPermissions);
            activity.requestPermissions(requestPermissions, 1024);
        }
    }

    private boolean hasAllPermissionsGranted(int[] grantResults) {
        for (int grantResult : grantResults) {
            if (grantResult == PackageManager.PERMISSION_DENIED) {
                return false;
            }
        }
        return true;
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        Activity activity = AdnetQqPlugin.getActivity();
        if (requestCode == 1024 && hasAllPermissionsGranted(grantResults)) {
            fetchSplashAD(activity, null, PluginSettings.APP_ID, posId, this, 0);
        } else {
            // 如果用户没有授权，那么应该说明意图，引导用户去设置里面授权。
//            Toast.makeText(activity, "应用缺少必要的权限！请点击\"权限\"，打开所需要的权限。", Toast.LENGTH_LONG).show();
//            Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
//            intent.setData(Uri.parse("package:" + activity.getPackageName()));
//            activity.startActivity(intent);
//            activity.finish();
            fetchSplashAD(activity, null, PluginSettings.APP_ID, posId, this, 0);
            methodChannel.invokeMethod("onRequestPermissionsFailed", null);
        }
        return true;
    }

    /**
     * 拉取开屏广告，开屏广告的构造方法有3种，详细说明请参考开发者文档。
     *
     * @param activity        展示广告的activity
     * @param skipContainer   自定义的跳过按钮：传入该view给SDK后，SDK会自动给它绑定点击跳过事件。SkipView的样式可以由开发者自由定制，其尺寸限制请参考activity_splash.xml或者接入文档中的说明。
     * @param appId           应用ID
     * @param posId           广告位ID
     * @param adListener      广告状态监听器
     * @param fetchDelay      拉取广告的超时时长：取值范围[3000, 5000]，设为0表示使用广点通SDK默认的超时时长。
     */
    private void fetchSplashAD(Activity activity, View skipContainer,
                               String appId, String posId, SplashADListener adListener, int fetchDelay) {
        if(splashAD != null) {
            return;
        }
//        fetchSplashADTime = System.currentTimeMillis();
        if(skipContainer == null) {
            splashAD = new SplashAD(activity, container, appId, posId, adListener, fetchDelay);
        } else {
            splashAD = new SplashAD(activity, container, skipContainer, appId, posId, adListener, fetchDelay);
        }
    }

    @Override
    public void onADDismissed() {
        Log.d(TAG, "SplashADDismissed");
        close();
        methodChannel.invokeMethod("onAdDismiss", null);
    }

    @Override
    public void onNoAD(AdError adError) {
        Log.d(TAG, String.format("LoadSplashADFail, eCode=%d, errorMsg=%s", adError.getErrorCode(), adError.getErrorMsg()));
//        /*
//         * 为防止无广告时造成视觉上类似于"闪退"的情况，设定无广告时页面跳转根据需要延迟一定时间，demo
//         * 给出的延时逻辑是从拉取广告开始算开屏最少持续多久，仅供参考，开发者可自定义延时逻辑，如果开发者采用demo
//         * 中给出的延时逻辑，也建议开发者考虑自定义minSplashTimeWhenNoAD的值
//         */
//        long alreadyDelayMills = System.currentTimeMillis() - fetchSplashADTime;//从拉广告开始到onNoAD已经消耗了多少时间
//        long shouldDelayMills = alreadyDelayMills > minSplashTimeWhenNoAD ? 0 : minSplashTimeWhenNoAD
//                - alreadyDelayMills;//为防止加载广告失败后立刻跳离开屏可能造成的视觉上类似于"闪退"的情况，根据设置的minSplashTimeWhenNoAD
//        // 计算出还需要延时多久
//        handler.postDelayed(new Runnable() {
//            @Override
//            public void run() {
//                close();
//            }
//        }, shouldDelayMills);
        close();
        methodChannel.invokeMethod("onNoAd", null);
    }

    @Override
    public void onADPresent() {
        Log.d(TAG, "SplashADPresent");
        methodChannel.invokeMethod("onAdPresent", null);
    }

    @Override
    public void onADClicked() {
        Log.d(TAG, "SplashADClicked");
        close();
        methodChannel.invokeMethod("onAdClicked", null);
    }

    @Override
    public void onADTick(long millisUntilFinished) {
//        Log.i("AD_DEMO", "SplashADTick " + millisUntilFinished + "ms");
    }

    @Override
    public void onADExposure() {
        Log.d(TAG, "SplashADExposure");
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if(methodCall.method.equals("show")) {
            showAd();
            result.success(true);
            return;
        }
        result.notImplemented();
    }
}