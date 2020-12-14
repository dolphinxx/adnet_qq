# adnet_qq

A new Flutter plugin for [腾讯优量汇](https://adnet.qq.com/).

Support both `Android` and `iOS`.

Only support `native_express`(原生广告模板方式), `splash`(开屏广告), `unified_banner`(Banner 2.0), `unified_interstitial`(插屏2.0) ads.

This plugin uses `Android X5 内核加强版` for android.

See [腾讯联盟 Android SDK 接入文档](https://developers.adnet.qq.com/doc/android/access_doc) and [腾讯联盟 iOS SDK 接入文档](https://developers.adnet.qq.com/doc/ios/guide) for the detail of the options.

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