class AdVideoAndroidOptions {
  final int autoPlayPolicy;
  final int videoPlayPolicy;
  final bool enableDetailPage;
  final bool enableUserControl;
  final bool needCoverImage;
  final bool needProgressBar;

  AdVideoAndroidOptions({
      this.autoPlayPolicy,
      this.videoPlayPolicy,
      this.enableDetailPage,
      this.enableUserControl,
      this.needCoverImage,
      this.needProgressBar,
  });

  Map getOptions() {
    Map result = Map();
    if(autoPlayPolicy != null) {
      result['autoPlayPolicy'] = autoPlayPolicy;
    }
    if(videoPlayPolicy != null) {
      result['videoPlayPolicy'] = videoPlayPolicy;
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
  final bool videoAutoPlayOnWWAN;

  AdVideoIOSOptions({this.videoAutoPlayOnWWAN});

  Map getOptions() {
    if(videoAutoPlayOnWWAN == null) {
      return {};
    }
    return {'videoAutoPlayOnWWAN': videoAutoPlayOnWWAN};
  }
}

class AdVideoOptions {
  final int minVideoDuration;
  final int maxVideoDuration;
  final bool autoPlayMuted;
  final bool detailPageVideoMuted;
  final AdVideoAndroidOptions androidOptions;
  final AdVideoIOSOptions iOSOptions;
  Map _options;
  Map _androidOptions;
  Map _iOSOptions;
  AdVideoOptions({this.minVideoDuration, this.maxVideoDuration, this.autoPlayMuted, this.detailPageVideoMuted, this.androidOptions, this.iOSOptions});

  Map getOptions() {
    if(_options != null) {
      return _options;
    }
    Map result = Map();
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
    if(_androidOptions == null) {
      _androidOptions = androidOptions?.getOptions() ?? {};
    }
    return _androidOptions;
  }

  Map getIOSOptions() {
    if(_iOSOptions == null) {
      _iOSOptions = iOSOptions?.getOptions() ?? {};
    }
    return _iOSOptions;
  }
}