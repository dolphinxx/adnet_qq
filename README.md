# adnet_qq

A new Flutter plugin for adnet_qq(Android only).

Android only currently.

Only support native_express(原生广告模板方式), splash(开屏广告), unified_banner(Banner 2.0), unified_interstitial(插屏2.0) ads.

This plugin uses `Android标准版 4.28.902` instead of `Android X5内核加强版 4.28.902`, because the X5 version does not support 64bit.

## Prerequisites

if targetSDKVersion >= 24
add following content to AndroidManifest.xml
```
<provider
            android:name="android.support.v4.content.FileProvider"
            android:authorities="your_package_name.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/gdt_file_path" />
</provider>
```
create a file `gdt_file_path.xml` in src/main/res/xml with following content:
```
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 这个下载路径也不可以修改，必须为GDTDOWNLOAD -->
    <external-path name="gdt_sdk_download_path" path="GDTDOWNLOAD" />
</paths>
```

add following to proguard-rules.pro if obfuscate
```
-keep class com.qq.e.** {
    public protected *;
}
-keep class android.support.v4.**{
    public *;
}
-keep class android.support.v7.**{
    public *;
}
-keep class MTT.ThirdAppInfoNew { *; }
-keep class com.tencent.** { *; }
```

## Notice
call `AdnetQqPlugin.config(appId: 'your appId')` before creating ads.

## Bugs
App may crash when rotate if contains more than one NativeExpressAd