import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static const int adInterval = 6; // Show ad after every 6 items

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  bool shouldShowAd(int index) {
    return index > 0 && index % (adInterval + 1) == adInterval;
  }

  NativeAd createNativeAd() {
    return NativeAd(
      adUnitId: _getAdUnitId(),
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) => debugPrint('Ad loaded: ${ad.adUnitId}'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: ${ad.adUnitId}, $error');
          ad.dispose();
        },
      ),
    );
  }

  InterstitialAd? _interstitialAd;

  Future<InterstitialAd> loadInterstitialAd() async {
    final completer = Completer<InterstitialAd>();

    await InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          completer.completeError(error);
        },
      ),
    );

    return completer.future;
  }

  String _getAdUnitId() {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/2247696110'; // Test ad unit ID
    }
    return 'YOUR_NATIVE_AD_UNIT_ID'; // Replace with your actual ad unit ID
  }

  String _getInterstitialAdUnitId() {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test interstitial ad unit ID
    }
    return 'YOUR_INTERSTITIAL_AD_UNIT_ID'; // Replace with your actual ad unit ID
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
