package com.whaleread.flutter.plugin.adnet_qq;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;

import com.qq.e.ads.cfg.VideoOption;
import com.qq.e.ads.interstitial2.UnifiedInterstitialAD;
import com.qq.e.ads.interstitial2.UnifiedInterstitialADListener;
import com.qq.e.comm.util.AdError;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterUnifiedInterstitial implements MethodChannel.MethodCallHandler, UnifiedInterstitialADListener {
    private static final String TAG = FlutterUnifiedInterstitial.class.getSimpleName();
    private UnifiedInterstitialAD iad;
    private final MethodChannel methodChannel;

    private final String posId;

    private Integer minVideoDuration;
    private Integer maxVideoDuration;
    private Boolean autoPlayMuted;
    private Boolean detailPageVideoMuted;
    // <--- android only ---
    private Integer autoPlayPolicy;
    private Boolean enableDetailPage;
    private Boolean enableUserControl;
    private Boolean needCoverImage;
    private Boolean needProgressBar;
    // --- android only --->

    public FlutterUnifiedInterstitial(String posId, BinaryMessenger messenger, @SuppressWarnings("rawtypes") Map params) {
        Log.d(TAG, "creating " + FlutterUnifiedInterstitial.class.getName());
        this.posId = posId;
        this.methodChannel = new MethodChannel(messenger, PluginSettings.UNIFIED_INTERSTITIAL_ID + "_" + posId);
        this.methodChannel.setMethodCallHandler(this);
        if(params.get("minVideoDuration") != null) {
            this.minVideoDuration = (Integer)params.get("minVideoDuration");
        }
        if(params.get("maxVideoDuration") != null) {
            this.maxVideoDuration = (Integer)params.get("maxVideoDuration");
        }
        if(params.get("autoPlayMuted") != null) {
            this.autoPlayMuted = (Boolean)params.get("autoPlayMuted");
        }
        if(params.get("detailPageVideoMuted") != null) {
            this.detailPageVideoMuted = (Boolean)params.get("detailPageVideoMuted");
        }
        if(params.get("androidOptions") != null) {
            @SuppressWarnings("rawtypes") Map options = (Map)params.get("androidOptions");
            if(options.get("autoPlayPolicy") != null) {
                this.autoPlayPolicy = (Integer)options.get("autoPlayPolicy");
            }
            if(options.get("enableDetailPage") != null) {
                this.enableDetailPage = (Boolean)options.get("enableDetailPage");
            }
            if(options.get("enableUserControl") != null) {
                this.enableUserControl = (Boolean)options.get("enableUserControl");
            }
            if(options.get("needCoverImage") != null) {
                this.needCoverImage = (Boolean)options.get("needCoverImage");
            }
            if(options.get("needProgressBar") != null) {
                this.needProgressBar = (Boolean)options.get("needProgressBar");
            }
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        switch (methodCall.method) {
            case "load":
                Log.d(TAG, "load");
                getIAD().loadAD();
                result.success(true);
                break;
            case "loadFullScreen":
                Log.d(TAG, "loadFullScreen");
                getIAD().loadFullScreenAD();
                result.success(true);
                break;
            case "show":
                Log.d(TAG, "show");
                showAD();
                result.success(true);
                break;
            case "popup":
                Log.d(TAG, "popup");
                showAsPopup();
                result.success(true);
                break;
            case "showFullScreen":
                Log.d(TAG, "showFullScreen");
                showFullScreen();
                result.success(true);
                break;
            case "close":
            case "dispose":
                Log.d(TAG, "close");
                closeAd();
                result.success(true);
                break;
            default:
                result.notImplemented();
        }
    }

    public void closeAd() {
        if (iad != null) {
            iad.destroy();
            iad = null;
        }
        methodChannel.setMethodCallHandler(null);
        AdnetQqPlugin.removeInterstitial(posId);
    }

    private UnifiedInterstitialAD getIAD() {
        if (iad != null) {
            return iad;
        }
        iad = new UnifiedInterstitialAD(AdnetQqPlugin.getActivity(), posId, this);
        VideoOption.Builder videoOptionBuilder = new VideoOption.Builder();
        if(autoPlayPolicy != null) {
            videoOptionBuilder.setAutoPlayPolicy(autoPlayPolicy); // 设置什么网络环境下可以自动播放视频
        }
        videoOptionBuilder.setAutoPlayMuted(autoPlayMuted != null ? autoPlayMuted : true); // 设置自动播放视频时，是否静音
        if(enableDetailPage != null) {
            videoOptionBuilder.setEnableDetailPage(enableDetailPage);
        }
        if(enableUserControl != null) {
            videoOptionBuilder.setEnableUserControl(enableUserControl);
        }
        if(needCoverImage != null) {
            videoOptionBuilder.setNeedCoverImage(needCoverImage);
        }
        if(needProgressBar != null) {
            videoOptionBuilder.setNeedProgressBar(needProgressBar);
        }
        if(detailPageVideoMuted != null) {
            videoOptionBuilder.setDetailPageMuted(detailPageVideoMuted);
        }
        iad.setVideoOption(videoOptionBuilder.build()); // setVideoOption是可选的，开发者可根据需要选择是否配置
        if(minVideoDuration != null) {
            iad.setMinVideoDuration(minVideoDuration);
        }
        if(maxVideoDuration != null) {
            iad.setMaxVideoDuration(maxVideoDuration);
        }
        return iad;
    }

    private void showAD() {
        getIAD().show();
    }

    private void showAsPopup() {
        getIAD().showAsPopupWindow();
    }

    private void showFullScreen() {
        Activity activity = AdnetQqPlugin.getActivity();
        if(activity != null) {
            getIAD().showFullScreenAD(activity);
        }
    }

    @Override
    public void onNoAD(AdError adError) {
        Log.d(TAG, String.format("onNoAD，eCode = %d, eMsg = %s", adError.getErrorCode(), adError.getErrorMsg()));
        iad = null;
        methodChannel.invokeMethod("onNoAd", adError.getErrorCode());
    }

    @Override
    public void onADReceive() {
        Log.d(TAG, "onADReceive");
        methodChannel.invokeMethod("onAdReceived", null);
    }

    @Override
    public void onADExposure() {
        Log.d(TAG, "onADExposure");
        methodChannel.invokeMethod("onAdExposure", null);
    }

    @Override
    public void onADClosed() {
        Log.d(TAG, "onADClosed");
        iad = null;
        methodChannel.invokeMethod("onAdClosed", null);
    }

    @Override
    public void onRenderSuccess() {
        Log.d(TAG, "onRenderSuccess");
        methodChannel.invokeMethod("onRenderSuccess", null);
    }

    @Override
    public void onRenderFail() {
        Log.d(TAG, "onRenderFailed");
        methodChannel.invokeMethod("onRenderFailed", null);
    }

    @Override
    public void onADClicked() {
        Log.d(TAG, "onADClicked");
        methodChannel.invokeMethod("onAdClicked", null);
    }

    @Override
    public void onADLeftApplication() {
        Log.d(TAG, "onADLeftApplication");
        methodChannel.invokeMethod("onAdLeftApplication", null);
    }

    @Override
    public void onADOpened() {
        Log.d(TAG, "onADOpened");
        methodChannel.invokeMethod("onAdOpened", null);
    }

    @Override
    public void onVideoCached() {
        methodChannel.invokeMethod("onVideoCached", null);
    }
}
