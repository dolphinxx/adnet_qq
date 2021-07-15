package com.whaleread.flutter.plugin.adnet_qq;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import com.qq.e.ads.splash.SplashAD;
import com.qq.e.ads.splash.SplashADListener;
import com.qq.e.comm.util.AdError;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class SplashAd implements SplashADListener {
    private static final String TAG = SplashAd.class.getSimpleName();

    private final MethodChannel methodChannel;

    private final String posId;
    private final FrameLayout container;
    private SplashAD splashAD;
    private Integer logo;
    /**
     * 拉取广告的超时时长：取值范围[3000, 5000]，设为0表示使用广点通SDK默认的超时时长。
     */
    private final int fetchDelay;
    private final boolean fullScreen;
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

    public SplashAd(Context context, BinaryMessenger messenger, String posId, String backgroundImage, Integer backgroundColor, Integer fetchDelay, boolean fullScreen, String logo) {
        if(PluginSettings.APP_ID == null) {
            throw new IllegalStateException("App Id must be configured before creating ad view");
        }
        this.methodChannel = new MethodChannel(messenger, PluginSettings.PLUGIN_ID + "/splash" );
        this.posId = posId;
        this.fetchDelay = fetchDelay == null ? 3000 : fetchDelay;
        this.fullScreen = fullScreen;
        container = new FrameLayout(context);
        if(backgroundColor != null) {
            container.setBackgroundColor(backgroundColor);
        }
        Activity activity = AdnetQqPlugin.getActivity();
        PackageManager packageManager = null;
        if(backgroundImage != null || logo != null) {
            packageManager = activity.getPackageManager();
        }
        if(backgroundImage != null) {
            try
            {
                Resources resources = packageManager.getResourcesForApplication(backgroundImage.substring(0, backgroundImage.indexOf(":")));
                int resId = resources.getIdentifier(backgroundImage, null, null);
                Drawable drawable = resources.getDrawable(resId);
                container.setBackground(drawable);
            } catch (Exception e) {
                Log.e(TAG, "failed to set background for splash ad, resource:" + backgroundImage, e);
            }
        }
        if(logo != null) {
            try {
                Resources resources = packageManager.getResourcesForApplication(logo.substring(0, logo.indexOf(":")));
                this.logo = resources.getIdentifier(logo, null, null);
            } catch (Exception e) {
                Log.e(TAG, "failed to set logo for splash ad, resource:" + logo, e);
            }
        }
        container.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        activity.addContentView(container, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    }

    public void show() {
        _showAd();
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

    private void _showAd() {
        fetchSplashAD(AdnetQqPlugin.getActivity(), posId, this);
    }

    /**
     * 拉取开屏广告，开屏广告的构造方法有3种，详细说明请参考开发者文档。
     *
     * @param activity        展示广告的activity
     * @param posId           广告位ID
     * @param adListener      广告状态监听器
     */
    private void fetchSplashAD(Activity activity, String posId, SplashADListener adListener) {
        Log.d(TAG, "fetching splash Ad");
        if(splashAD != null) {
            return;
        }
//        fetchSplashADTime = System.currentTimeMillis();
        splashAD = new SplashAD(activity, posId, adListener, fetchDelay);
        if(this.logo != null) {
            splashAD.setDeveloperLogo(this.logo);
        }
        if(fullScreen) {
            splashAD.fetchFullScreenAndShowIn(container);
        } else {
            splashAD.fetchAndShowIn(container);
        }
    }

    @Override
    public void onADDismissed() {
        Log.d(TAG, "SplashADDismissed");
        methodChannel.invokeMethod("onAdDismiss", null);
        close();
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
        methodChannel.invokeMethod("onNoAd", adError.getErrorCode());
        close();
    }

    @Override
    public void onADPresent() {
        Log.d(TAG, "SplashADPresent");
        methodChannel.invokeMethod("onAdPresent", null);
    }

    @Override
    public void onADClicked() {
        Log.d(TAG, "SplashADClicked");
        methodChannel.invokeMethod("onAdClicked", null);
        close();
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
}