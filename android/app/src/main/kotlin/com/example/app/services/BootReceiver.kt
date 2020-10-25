package com.example.app.services

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat

class BootReceiver: BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if(intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            context?.also { it ->
                if(ContextCompat.checkSelfPermission(it, Manifest.permission.ACTIVITY_RECOGNITION) != PackageManager.PERMISSION_DENIED) {
                    Intent(context, Pedometer::class.java).also { service ->
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            context.startForegroundService(service)
                        } else {
                            context.startService(service)
                        }
                    }
                }
            }
        }
    }
}
