package com.whaleread.flutter.plugin.adnet_qq;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.qq.e.ads.splash.SplashAD;
import com.qq.e.ads.splash.SplashADListener;
import com.qq.e.comm.util.AdError;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class SplashAd implements MethodChannel.MethodCallHandler, SplashADListener {
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
        ViewGroup parent = ((ViewGroup)container.getParent());
        if(parent != null) {
            parent.removeView(container);
        }
        if(splashAD != null) {
            splashAD = null;
        }
    }

    private void showAd() {
        fetchSplashAD(AdnetQqPlugin.getActivity(), null, posId, this, 0);
    }

    /**
     * 拉取开屏广告，开屏广告的构造方法有3种，详细说明请参考开发者文档。
     *
     * @param activity        展示广告的activity
     * @param skipContainer   自定义的跳过按钮：传入该view给SDK后，SDK会自动给它绑定点击跳过事件。SkipView的样式可以由开发者自由定制，其尺寸限制请参考activity_splash.xml或者接入文档中的说明。
     * @param posId           广告位ID
     * @param adListener      广告状态监听器
     * @param fetchDelay      拉取广告的超时时长：取值范围[3000, 5000]，设为0表示使用广点通SDK默认的超时时长。
     */
    private void fetchSplashAD(Activity activity, View skipContainer, String posId, SplashADListener adListener, int fetchDelay) {
        Log.d(TAG, "fetching splash Ad");
        if(splashAD != null) {
            return;
        }
//        fetchSplashADTime = System.currentTimeMillis();
        if(skipContainer == null) {
            splashAD = new SplashAD(activity, posId, adListener, fetchDelay);
        } else {
            splashAD = new SplashAD(activity, skipContainer, posId, adListener, fetchDelay);
        }
        splashAD.fetchAndShowIn(container);
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
        methodChannel.invokeMethod("onNoAd", adError.getErrorCode());
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
        methodChannel.invokeMethod("onAdTick", millisUntilFinished);
    }

    @Override
    public void onADExposure() {
        Log.d(TAG, "SplashADExposure");
        methodChannel.invokeMethod("onAdExposure", null);
    }

    @Override
    public void onADLoaded(long l) {
        methodChannel.invokeMethod("onAdLoaded", l);
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