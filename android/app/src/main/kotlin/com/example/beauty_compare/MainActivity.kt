package com.example.beauty_compare

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import com.google.android.gms.ads.MobileAds

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Initialize the Google Mobile Ads SDK on a background thread.
        Thread {
            MobileAds.initialize(this) {}
        }.start()
    }
}
