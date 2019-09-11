# adnet_qq

A new Flutter plugin for adnet_qq.

Android only currently.

Only support native_express(原生广告模板方式), splash(开屏广告), unified_banner(Banner 2.0), unified_interstitial(插屏2.0) ads.

This plugin uses `Android标准版 4.28.902` instead of `Android X5内核加强版 4.28.902`, because the X5 version does not support 64bit.

## Installation

### Android
Add `<uses-permission android:name="android.permission.READ_PHONE_STATE" />` to your `AndroidManifest.xml` when `requestReadPhoneState=true`, and `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />` for `requestAccessFineLocation`

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
    <external-path name="gdt_sdk_download_path" path="GDTDOWNLOAD" />
    <external-cache-path
      name="gdt_sdk_download_path1"
      path="com_qq_e_download" />
    <cache-path
      name="gdt_sdk_download_path2"
      path="com_qq_e_download" />
</paths>
```

add following to proguard-rules.pro if obfuscate
```
-keep class com.tencent.smtt.** { *; }
-dontwarn dalvik.**
-dontwarn com.tencent.smtt.**
```

### iOS
run `flutter build ios`, then open xcode and select all files under `Pods/GDTMobSDK/GDTMobSDK/` then under `Target Membership` panel in right bottom check `adnet_qq` and change value from Project to Public.

modify `ios/Runner/Info.plist`, add following to allow non https requests.
```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```
add following to enable platform view
```
<key>io.flutter.embedded_views_preview</key>
<true/>
```

## Notice
call `AdnetQqPlugin.config(appId: 'your appId')` before creating ads.

## Bugs
App may crash when rotate if contains more than one NativeExpressAd