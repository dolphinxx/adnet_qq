package com.whaleread.flutter.plugin.adnet_qq;

import android.content.Context;
import android.content.res.Resources;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;

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
    private NativeExpressAD nativeExpressAD;
    private NativeExpressADView nativeExpressADView;
    private final MethodChannel methodChannel;
    private FrameLayout container;

    private String posId;

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
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
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
//            case "getSize":
////                float density = Resources.getSystem().getDisplayMetrics().density;
//                int[] size = getViewSize(nativeExpressADView);
//                Log.d("_____",  size[0] + "," + size[1]);
//                Map<String, Object> data = new HashMap<>();
//                data.put("width", size[0]);
//                data.put("height", size[1]);
//                result.success(data);
//                break;
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
        // 使用完了每一个NativeExpressADView之后都要释放掉资源
        if (nativeExpressADView != null) {
            nativeExpressADView.destroy();
        }
    }

    private void refreshAd() {
        /*
         *  如果选择支持视频的模版样式，请使用{@link Constants#NativeExpressSupportVideoPosID}
         */
        nativeExpressAD = new NativeExpressAD(AdnetQqPlugin.getActivity(), new ADSize(ADSize.FULL_WIDTH, ADSize.AUTO_HEIGHT), PluginSettings.APP_ID, posId, this); // 这里的Context必须为Activity
        nativeExpressAD.setVideoOption(new VideoOption.Builder()
                .setAutoPlayPolicy(VideoOption.AutoPlayPolicy.WIFI) // 设置什么网络环境下可以自动播放视频
                .setAutoPlayMuted(true) // 设置自动播放视频时，是否静音
                .build()); // setVideoOption是可选的，开发者可根据需要选择是否配置
        nativeExpressAD.loadAD(1);
    }

    @Override
    public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {

//    }
//
//    @Override
//    public void onGlobalLayout() {
//        Log.d("!___", container.getWidth() + "," + container.getHeight() + "," + container.getMeasuredWidth() + "," + container.getMeasuredHeight());
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

    public static int[] getViewSize(View view) {
        int w = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        int h = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED);
        view.measure(w, h);
        return new int []{view.getMeasuredWidth(), view.getMeasuredHeight()};
    }
}
