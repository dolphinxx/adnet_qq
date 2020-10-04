package com.whaleread.flutter.plugin.adnet_qq;

import android.content.Context;
import android.util.Log;
import android.view.View;

import com.qq.e.ads.banner2.UnifiedBannerADListener;
import com.qq.e.ads.banner2.UnifiedBannerView;
import com.qq.e.comm.util.AdError;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class FlutterUnifiedBannerView implements PlatformView, MethodChannel.MethodCallHandler, UnifiedBannerADListener {
    private static final String TAG = FlutterUnifiedBannerView.class.getSimpleName();
//    private FrameLayout container;
    private UnifiedBannerView bv;
    private final MethodChannel methodChannel;
    private Integer refreshInterval;

    private String posId;

    public FlutterUnifiedBannerView(Context context, BinaryMessenger messenger, int id, Map<String, Object> params) {
        if(PluginSettings.APP_ID == null) {
            throw new IllegalStateException("App Id must be configured before creating ad view");
        }
        Log.d(TAG, "creating " + FlutterUnifiedBannerView.class.getName());
//        this.container = new FrameLayout(context);
//        this.container.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        this.methodChannel = new MethodChannel(messenger, PluginSettings.UNIFIED_BANNER_VIEW_ID + "_" + id);
        this.methodChannel.setMethodCallHandler(this);
        this.posId = (String)params.get("posId");
        if(params.containsKey("refreshInterval")) {
            refreshInterval = (Integer)params.get("refreshInterval");
        }
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch(methodCall.method) {
            case "refresh":
                getBanner().loadAD();
                result.success(true);
                break;
            case "close":
                if(bv != null) {
                    bv.destroy();
                    bv = null;
                }
                result.success(true);
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public View getView() {
        return getBanner();
    }

    @Override
    public void dispose() {
        methodChannel.setMethodCallHandler(null);
        if(this.bv != null) {
            try {
                this.bv.destroy();
            } catch (Exception ignore) {
            }
            this.bv = null;
        }
    }

    private UnifiedBannerView getBanner() {
        if( this.bv != null) {
            return this.bv;
        }
        this.bv = new UnifiedBannerView(AdnetQqPlugin.getActivity(), posId, this);
        if(refreshInterval != null) {
            this.bv.setRefresh(refreshInterval);
        }
        return this.bv;
    }

    @Override
    public void onNoAD(AdError adError) {
        Log.d(
                TAG,
                String.format("onNoAD，eCode = %d, eMsg = %s", adError.getErrorCode(),
                        adError.getErrorMsg()));
        methodChannel.invokeMethod("onNoAd", adError.getErrorCode());
    }

    @Override
    public void onADReceive() {
        Log.d(TAG, "ONBannerReceive");
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
        methodChannel.invokeMethod("onAdClosed", null);
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
    public void onADOpenOverlay() {
        Log.d(TAG, "onADOpenOverlay");
        methodChannel.invokeMethod("onAdOpenOverlay", null);
    }

    @Override
    public void onADCloseOverlay() {
        Log.d(TAG, "onADCloseOverlay");
        methodChannel.invokeMethod("onAdCloseOverlay", null);
    }

    @Override
    public void onInputConnectionLocked() {
        methodChannel.invokeMethod("onInputConnectionLocked", null);
    }

    @Override
    public void onInputConnectionUnlocked() {
        methodChannel.invokeMethod("onInputConnectionUnlocked", null);
    }
}
