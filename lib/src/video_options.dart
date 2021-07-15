class AdVideoAndroidOptions {
  final int? autoPlayPolicy;
  /// 已弃用，设置该值无任何作用
  @deprecated
  final int? videoPlayPolicy;
  final bool? enableDetailPage;
  final bool? enableUserControl;
  final bool? needCoverImage;
  final bool? needProgressBar;

  AdVideoAndroidOptions({
      this.autoPlayPolicy,
      this.videoPlayPolicy,
      this.enableDetailPage,
      this.enableUserControl,
      this.needCoverImage,
      this.needProgressBar,
  });

  Map getOptions() {
    Map result = {};
    if(autoPlayPolicy != null) {
      result['autoPlayPolicy'] = autoPlayPolicy;
    }
    if(enableDetailPage != null) {
      result['enableDetailPage'] = enableDetailPage;
    }
    if(enableUserControl != null) {
      result['enableUserControl'] = enableUserControl;
    }
    if(needCoverImage != null) {
      result['needCoverImage'] = needCoverImage;
    }
    if(needProgressBar != null) {
      result['needCoverImage'] = needCoverImage;
    }
    return result;
  }
}

class AdVideoIOSOptions {
  /// 非 WiFi 网络，是否自动播放。默认 YES。loadAd 前设置。
  final bool? videoAutoPlayOnWWAN;

  AdVideoIOSOptions({this.videoAutoPlayOnWWAN});

  Map getOptions() {
    if(videoAutoPlayOnWWAN == null) {
      return const {};
    }
    return {'videoAutoPlayOnWWAN': videoAutoPlayOnWWAN};
  }
}

class AdVideoOptions {
  /// 请求视频的时长下限。
  ///  以下两种情况会使用 0，1:不设置  2:minVideoDuration大于maxVideoDuration
  final int? minVideoDuration;
  /// 请求视频的时长上限，视频时长有效值范围为[5,180]。
  final int? maxVideoDuration;
  /// 自动播放时，是否静音。默认 YES。loadAd 前设置。
  final bool? autoPlayMuted;
  /// 视频详情页播放时是否静音。默认NO。loadAd 前设置。
  final bool? detailPageVideoMuted;
  final AdVideoAndroidOptions? androidOptions;
  final AdVideoIOSOptions? iOSOptions;
  Map? _options;
  Map? _androidOptions;
  Map? _iOSOptions;
  AdVideoOptions({this.minVideoDuration, this.maxVideoDuration, this.autoPlayMuted, this.detailPageVideoMuted, this.androidOptions, this.iOSOptions});

  Map getOptions() {
    if(_options != null) {
      return _options!;
    }
    Map result = {};
    if(minVideoDuration != null) {
      result['minVideoDuration'] = minVideoDuration;
    }
    if(maxVideoDuration != null) {
      result['maxVideoDuration'] = maxVideoDuration;
    }
    if(autoPlayMuted != null) {
      result['autoPlayMuted'] = autoPlayMuted;
    }
    if(detailPageVideoMuted != null) {
      result['detailPageVideoMuted'] = detailPageVideoMuted;
    }
    _options = result;
    return result;
  }

  Map getAndroidOptions() {
    _androidOptions ??= androidOptions?.getOptions() ?? const {};
    return _androidOptions!;
  }

  Map getIOSOptions() {
    _iOSOptions ??= iOSOptions?.getOptions() ?? const {};
    return _iOSOptions!;
  }
}