package com.example.app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import com.example.app.services.Pedometer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        const val CHANNEL = "android.app.trees/pedometer"
    }

    private lateinit var pedometerService: Pedometer
    private var bound = false

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as Pedometer.LocalBinder
            pedometerService = binder.getService()
            bound = true
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            bound = false
        }
    }

    private fun startService(): Boolean? {
        Intent(this, Pedometer::class.java).also { service ->
            bindService(service, connection, Context.BIND_AUTO_CREATE)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(service)
            } else {
                startService(service)
            }

            return true
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if(bound) {
            unbindService(connection)
            bound = false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if(call.method == "startService") {
                result.success(startService() ?: false)
            } else {
                if(bound) {
                    when (call.method) {
                        "changeDateIfNeeded" -> result.success(pedometerService.applyDayChangeIfNeeded())
                        "isPedometerError" -> result.success(pedometerService.isPedometerError())
                        "getTodaySteps" -> result.success(pedometerService.getTodaySteps())
                        "getTodayTrees" -> result.success(pedometerService.getTodayTrees())
                        "getTotalSteps" -> result.success(pedometerService.getTotalSteps())
                        "getTotalTrees" -> result.success(pedometerService.getTotalTrees())
                        "getDailyGoal" -> result.success(pedometerService.getDailyGoal())
                        "save" -> result.success(pedometerService.save())
                        else -> result.notImplemented()
                    }
                } else {
                    result.error("UNBOUND_EXCEPTION", "Step counting service is unbound", null)
                }
            }
        }
    }
}
