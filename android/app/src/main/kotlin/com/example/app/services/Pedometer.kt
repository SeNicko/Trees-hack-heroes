package com.example.app.services

import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Binder
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.example.app.MainActivity
import com.example.app.R
import com.example.app.utils.Save
import com.example.app.utils.SummaryData
import com.example.app.utils.TodayData
import java.util.*
import kotlin.math.roundToInt

class Pedometer: Service(), SensorEventListener {
    companion object {
        const val TAG = "PEDOMETER_SERVICE"
    }

    private lateinit var sensorManager: SensorManager
    private var pedometer: Sensor? = null
    private var pedometerError: Boolean = false

    private lateinit var savingUtility: Save

    private var fileTodaySteps = 0
    private var fileTodayStepsFirstRead = -1
    private var fileTodayTrees = 0
    private var fileTodayDate = Date(0)
    private var fileTotalHistoricSteps = 0
    private var fileTotalHistoricTrees = 0
    private var fileDailyGoal = 0

    private fun isDayTheSame(date: Date, calendar: Calendar): Boolean {
        val calendarOfDate: Calendar = GregorianCalendar()
        calendarOfDate.time = date

        return calendarOfDate.get(Calendar.YEAR) == calendar.get(Calendar.YEAR) &&
                calendarOfDate.get(Calendar.MONTH) == calendar.get(Calendar.MONTH) &&
                calendarOfDate.get(Calendar.DAY_OF_MONTH) == calendar.get(Calendar.DAY_OF_MONTH)
    }

    private fun isDayTheSame(date1: Date, date2: Date): Boolean {
        val calendarOfDate2: Calendar = GregorianCalendar()
        calendarOfDate2.time = date2
        
        return isDayTheSame(date1, calendarOfDate2)
    }

    private fun fetchFileData(): Boolean {
        var today = savingUtility.getTodayData()
        if(today == null && savingUtility.saveTodayData(TodayData(0, 0, Date()))) // If today data is null, save a file and retry
            today = savingUtility.getTodayData()
        if(today == null) return false // If it's still null, fetching data failed

        var summary = savingUtility.getSummaryData()
        if(summary == null && savingUtility.saveSummaryData(SummaryData(0, 0,10000)))
            summary = savingUtility.getSummaryData()
        if(summary == null) return false

        fileTodaySteps = today.steps
        if(fileTodayStepsFirstRead == -1) fileTodayStepsFirstRead = fileTodaySteps

        fileTodayTrees = today.trees
        fileTodayDate = today.date
        fileTotalHistoricSteps = summary.totalHistoricSteps
        fileTotalHistoricTrees = summary.totalHistoricTrees
        fileDailyGoal = summary.dailyGoal

        if(!isDayTheSame(fileTodayDate, GregorianCalendar())) { // Checks if days aren't the same - for example the user turned the app on one day later
            savingUtility.saveTodayData(TodayData(0, 0, Date()))
            savingUtility.saveSummaryData(SummaryData(fileTodaySteps + fileTotalHistoricSteps, fileTodayTrees + fileTotalHistoricTrees, fileDailyGoal))

            return fetchFileData()
        }

        return true
    }

    override fun onCreate() {
        savingUtility = Save(baseContext)

        if(fetchFileData()) {
            val contentIntent = PendingIntent.getActivity(this, 0,
                    Intent(this, MainActivity::class.java), PendingIntent.FLAG_UPDATE_CURRENT)

            val builder = NotificationCompat.Builder(this, "stepCounter").apply {
                setSmallIcon(R.drawable.ic_baseline_directions_walk_24)
                setContentTitle(getString(R.string.app_name))
                setContentText(getString(R.string.step_counter_description_empty))
                setContentIntent(contentIntent)
            }

            startForeground(1, builder.build())

            sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
            pedometer = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)?.also { sensor ->
                sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI)

                Log.i(TAG, "init: Service started")
            }

            if(pedometer == null) pedometerError = true
        }
    }

    inner class LocalBinder: Binder() {
        fun getService(): Pedometer = this@Pedometer
    }

    private val binder: IBinder = LocalBinder()

    override fun onBind(intent: Intent?): IBinder? = binder

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    private var pedometerStepCountSinceBoot = 0
    private var pedometerDateOfLastReading = Date()
    private var pedometerFirstReading = -1

    fun isPedometerError(): Boolean {
        return pedometerError
    }

    fun getTodaySteps(): Int {
        if(pedometerFirstReading == -1) return -1

        return pedometerStepCountSinceBoot - pedometerFirstReading + fileTodayStepsFirstRead
    }

    fun getTodayTrees(): Int {
        return getTodaySteps().div(if(getDailyGoal() == 0) 1 else getDailyGoal())
    }

    fun getTotalSteps(): Int {
        val today = getTodaySteps()

        if(today == -1) return -1
        return today + fileTotalHistoricSteps
    }

    fun getTotalTrees(): Int {
        return getTodayTrees() + fileTotalHistoricTrees
    }

    fun getDailyGoal(): Int {
        return fileDailyGoal
    }

    fun save(todaySteps: Int = getTodaySteps(), todayTrees: Int = fileTodayTrees.div(getDailyGoal()), todayDate: Date = pedometerDateOfLastReading, totalHistoricSteps: Int = fileTotalHistoricSteps, totalHistoricTrees: Int = fileTotalHistoricTrees, dailyGoal: Int = getDailyGoal(), fire: Boolean = false): Boolean {
        applyDayChangeIfNeeded()

        savingUtility.saveTodayData(TodayData(todaySteps, todayTrees, todayDate))
        savingUtility.saveSummaryData(SummaryData(totalHistoricSteps, totalHistoricTrees, dailyGoal))

        val didFetch = fetchFileData()

        if(fire) {
            fileTodayStepsFirstRead = fileTodaySteps
        }

        return didFetch
    }

    private fun applyDayChange() {
        val newDate = Date()

        pedometerDateOfLastReading = newDate
        save(0, 0, newDate, getTodaySteps() + fileTotalHistoricSteps, getTodayTrees() + fileTotalHistoricTrees)

        pedometerFirstReading = pedometerStepCountSinceBoot
    }

    /// Returns boolean that indicates if changes were applied
    fun applyDayChangeIfNeeded(): Boolean {
        val today = Date()
        if(!isDayTheSame(today, pedometerDateOfLastReading)) {
            applyDayChange()
            return true
        }

        return false
    }

    override fun onSensorChanged(event: SensorEvent?) {
        event?.values?.get(0).also { steps ->
            if(steps == null) return

            pedometerStepCountSinceBoot = steps.roundToInt()
            if(pedometerFirstReading == -1) pedometerFirstReading = pedometerStepCountSinceBoot

            if(!applyDayChangeIfNeeded()) {
                if(fileTodayTrees < getTodayTrees()) {
                    save(todayTrees = getTodayTrees())
                } else if(pedometerStepCountSinceBoot % 10 == 0) {
                    save()
                }
            }

            pedometerDateOfLastReading = Date()
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

}
