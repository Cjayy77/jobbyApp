package com.example.jobby

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class ListTileNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.list_tile_native_ad, null) as NativeAdView

        with(nativeAdView) {
            val attributionViewSmall =
                findViewById<TextView>(R.id.tv_list_tile_native_ad_attribution_small)
            val iconView = findViewById<ImageView>(R.id.iv_list_tile_native_ad_icon)
            val headlineView = findViewById<TextView>(R.id.tv_list_tile_native_ad_headline)
            val advertiserView = findViewById<TextView>(R.id.tv_list_tile_native_ad_advertiser)

            attributionViewSmall.visibility = View.VISIBLE

            // Set the media view
            mediaView = findViewById(R.id.ad_media)
            nativeAd.mediaContent?.let { mediaView?.setMediaContent(it) }

            // Set other ad assets
            headlineView.text = nativeAd.headline
            advertiserView.text = nativeAd.advertiser
            nativeAd.icon?.drawable?.let { iconView.setImageDrawable(it) }

            // Register the views used for each asset
            this.iconView = iconView
            this.headlineView = headlineView
            this.advertiserView = advertiserView

            // Set the native ad to the native ad view
            setNativeAd(nativeAd)
        }

        return nativeAdView
    }
}
