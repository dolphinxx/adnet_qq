package com.whaleread.flutter.plugin.adnet_qq;

import android.content.Context;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class FlutterNativeExpressViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;
    public FlutterNativeExpressViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int id, Object params) {
        //noinspection unchecked
        return new FlutterNativeExpressView(context, messenger, id, (Map<String, Object>)params);
    }
}
