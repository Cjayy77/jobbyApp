import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const int adInterval = 6; // Show ad after every 6 listings

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  NativeAd createJobListAd() {
    return NativeAd(
      adUnitId: 'ca-app-pub-3940256099942544/2247696110', // Test ad unit ID
      factoryId: 'jobListingNative',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {},
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
  }

  bool shouldShowAd(int index) {
    return (index + 1) % (adInterval + 1) == 0;
  }

  void disposeAd(NativeAd? ad) {
    ad?.dispose();
  }
}
