package com.whaleread.flutter.plugin.adnet_qq;

import android.content.Context;
import android.content.res.Resources;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import com.qq.e.ads.cfg.VideoOption;
import com.qq.e.ads.nativ.ADSize;
import com.qq.e.ads.nativ.NativeExpressAD;
import com.qq.e.ads.nativ.NativeExpressADView;
import com.qq.e.comm.util.AdError;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class FlutterNativeExpressView implements PlatformView, MethodChannel.MethodCallHandler, NativeExpressAD.NativeExpressADListener, View.OnLayoutChangeListener {
    private static final String TAG = FlutterNativeExpressView.class.getSimpleName();
    @SuppressWarnings("FieldCanBeLocal")
    private NativeExpressAD nativeExpressAD;
    private NativeExpressADView nativeExpressADView;
    private final MethodChannel methodChannel;
    private final FrameLayout container;

    private final String posId;
    private int count = 5;
    private Integer minVideoDuration;
    private Integer maxVideoDuration;
    private Boolean autoPlayMuted;
    private Boolean detailPageVideoMuted;
    // <--- android only ---
    private Integer autoPlayPolicy;
    private Integer videoPlayPolicy;
    private Boolean enableDetailPage;
    private Boolean enableUserControl;
    private Boolean needCoverImage;
    private Boolean needProgressBar;
    // --- android only --->

    public FlutterNativeExpressView(Context context, BinaryMessenger messenger, int id, Map<String, Object> params) {
        if (PluginSettings.APP_ID == null) {
            throw new IllegalStateException("App Id must be configured before creating ad view");
        }
        Log.d(TAG, "creating " + FlutterNativeExpressView.class.getName());
        this.methodChannel = new MethodChannel(messenger, PluginSettings.NATIVE_EXPRESS_VIEW_ID + "_" + id);
        this.methodChannel.setMethodCallHandler(this);
        this.container = new FrameLayout(context);
        container.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT));
//        container.getViewTreeObserver().addOnGlobalLayoutListener(this);
        this.posId = (String) params.get("posId");
        if(params.get("count") != null) {
            this.count = (int)params.get("count");
        }
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
            if(options.get("videoPlayPolicy") != null) {
                this.videoPlayPolicy = (Integer)options.get("videoPlayPolicy");
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
            case "refresh":
                refreshAd();
                result.success(true);
                break;
            case "close":
                if (nativeExpressADView != null) {
                    nativeExpressADView.destroy();
                    nativeExpressADView = null;
                }
                result.success(true);
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public View getView() {
        return container;
    }

    @Override
    public void dispose() {
        methodChannel.setMethodCallHandler(null);
        // 使用完了每一个NativeExpressADView之后都要释放掉资源
        if (nativeExpressADView != null) {
            nativeExpressADView.destroy();
            nativeExpressADView = null;
        }
    }

    private void refreshAd() {
        /*
         *  如果选择支持视频的模版样式，请使用{@link Constants#NativeExpressSupportVideoPosID}
         */
        nativeExpressAD = new NativeExpressAD(AdnetQqPlugin.getActivity(), new ADSize(ADSize.FULL_WIDTH, ADSize.AUTO_HEIGHT), posId, this); // 这里的Context必须为Activity
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
        nativeExpressAD.setVideoOption(videoOptionBuilder.build()); // setVideoOption是可选的，开发者可根据需要选择是否配置
        if(maxVideoDuration != null) {
            nativeExpressAD.setMaxVideoDuration(maxVideoDuration);
        }
        if(minVideoDuration != null) {
            nativeExpressAD.setMinVideoDuration(minVideoDuration);
        }
        if(videoPlayPolicy != null) {
            nativeExpressAD.setVideoPlayPolicy(videoPlayPolicy);
        }
        nativeExpressAD.loadAD(count);
    }

    @Override
    public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
        if(methodChannel != null) {
            DisplayMetrics displayMetrics = Resources.getSystem().getDisplayMetrics();
            container.measure(View.MeasureSpec.makeMeasureSpec(displayMetrics.widthPixels,
                    View.MeasureSpec.EXACTLY),
                    View.MeasureSpec.makeMeasureSpec(0,
                            View.MeasureSpec.UNSPECIFIED));

            final int targetWidth = container.getMeasuredWidth();
            final int targetHeight = container.getMeasuredHeight();
            float density = displayMetrics.density;
//            Log.d("-------", targetWidth + "," + targetHeight + "," + density);

            Map<String, Object> params = new HashMap<>();
            params.put("width", targetWidth/density);
            params.put("height", targetHeight/density);
            methodChannel.invokeMethod("onLayout", params);
        }
    }

    @Override
    public void onNoAD(AdError adError) {
        Log.d(TAG, String.format("onNoAD，eCode = %d, eMsg = %s", adError.getErrorCode(), adError.getErrorMsg()));
        methodChannel.invokeMethod("onNoAd", null);
    }

    @Override
    public void onADLoaded(List<NativeExpressADView> adList) {
        Log.d(TAG, "onADLoaded: " + adList.size());
        // 释放前一个展示的NativeExpressADView的资源
        if (nativeExpressADView != null) {
            nativeExpressADView.destroy();
        }

        if (container.getVisibility() != View.VISIBLE) {
            container.setVisibility(View.VISIBLE);
        }

        if (container.getChildCount() > 0) {
            container.removeAllViews();
        }

        nativeExpressADView = adList.get(0);
//        nativeExpressADView.getViewTreeObserver().addOnGlobalLayoutListener(this);
        nativeExpressADView.addOnLayoutChangeListener(this);
//        Log.i(TAG, "onADLoaded, video info: " + getAdInfo(nativeExpressADView));
//        if (nativeExpressADView.getBoundData().getAdPatternType() == AdPatternType.NATIVE_VIDEO) {
//            nativeExpressADView.setMediaListener(mediaListener);
//        }
        // 广告可见才会产生曝光，否则将无法产生收益。
        container.addView(nativeExpressADView);
        nativeExpressADView.render();
        methodChannel.invokeMethod("onAdLoaded", null);
    }

    @Override
    public void onRenderFail(NativeExpressADView nativeExpressADView) {
        Log.d(TAG, "onRenderFail");
        methodChannel.invokeMethod("onRenderFail", null);
    }

    @Override
    public void onRenderSuccess(NativeExpressADView nativeExpressADView) {
        Log.d(TAG, "onRenderSuccess");
        methodChannel.invokeMethod("onRenderSuccess", null);
    }

    @Override
    public void onADExposure(NativeExpressADView nativeExpressADView) {
        Log.d(TAG, "onADExposure");
        methodChannel.invokeMethod("onAdExposure", null);
    }

    @Override
    public void onADClicked(NativeExpressADView nativeExpressADView) {
        Log.d(TAG, "onADClicked");
        methodChannel.invokeMethod("onAdClicked", null);
    }

    @Override
    public void onADClosed(NativeExpressADView nativeExpressADView) {
        Log.d(TAG, "onADClosed");
        // 当广告模板中的关闭按钮被点击时，广告将不再展示。NativeExpressADView也会被Destroy，释放资源，不可以再用来展示。
        if (container != null && container.getChildCount() > 0) {
            container.removeAllViews();
            container.setVisibility(View.GONE);
        }
        methodChannel.invokeMethod("onAdClosed", null);
    }

    @Override
    public void onADLeftApplication(NativeExpressADView nativeExpressADView) {
        methodChannel.invokeMethod("onAdLeftApplication", null);
    }

    @Override
    public void onADOpenOverlay(NativeExpressADView nativeExpressADView) {
        methodChannel.invokeMethod("onAdOpenOverlay", null);
    }

    @Override
    public void onADCloseOverlay(NativeExpressADView nativeExpressADView) {
        methodChannel.invokeMethod("onAdCloseOverlay", null);
    }

//    public static int[] getViewSize(View view) {
//        int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
//        int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
//        view.measure(w, h);
//        return new int []{view.getMeasuredWidth(), view.getMeasuredHeight()};
//    }

//    @Override
//    public void onInputConnectionLocked() {
//        methodChannel.invokeMethod("onInputConnectionLocked", null);
//    }

//    @Override
//    public void onInputConnectionUnlocked() {
//        methodChannel.invokeMethod("onInputConnectionUnlocked", null);
//    }
}
