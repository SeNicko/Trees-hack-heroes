package com.example.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.app.FlutterApplication

class Application: FlutterApplication() {
    override fun onCreate() {
        super.onCreate()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Register new notification channel
            val manager = getSystemService(NotificationManager::class.java)
            val channel = NotificationChannel("stepCounter", "Step counter", NotificationManager.IMPORTANCE_LOW)
            manager.createNotificationChannel(channel)
        }
    }
}
