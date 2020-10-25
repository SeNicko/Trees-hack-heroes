package com.example.app.utils

import android.content.Context
import org.json.JSONObject
import java.io.File
import java.lang.Exception
import java.util.*

data class TodayData(val steps: Int, val trees: Int, val date: Date)
data class SummaryData(val totalHistoricSteps: Int, val totalHistoricTrees: Int, val dailyGoal: Int)

class Save(private val context: Context) {

    private val todayFile = File(context.filesDir, "today.json")
    private val summaryFile = File(context.filesDir, "summary.json")

    init {
        if(!todayFile.exists()) todayFile.createNewFile()
        if(!summaryFile.exists()) summaryFile.createNewFile()
    }

    fun getTodayData(): TodayData? {
        val data: String = context.openFileInput(todayFile.name).bufferedReader().useLines { lines ->
            lines.fold("") { _, data ->
                data
            }
        }

        return try {
            val json = JSONObject(data)
            val steps = json.getInt("steps")
            val trees = json.getInt("trees")
            val date = json.getLong("date")

            TodayData(steps, trees, Date(date))
        } catch (e: Exception) {
            null
        }
    }

    fun saveTodayData(todayData: TodayData): Boolean {
        val steps = todayData.steps
        val trees = todayData.trees
        val date = todayData.date

        try {
            context.openFileOutput(todayFile.name, Context.MODE_PRIVATE).also {
                val json = JSONObject()
                json.put("steps", steps)
                json.put("trees", trees)
                json.put("date", date.time)

                it.write(json.toString().toByteArray())

                return true
            }
        } catch (e: Exception) {
            return false
        }
    }

    fun getSummaryData(): SummaryData? {
        val data: String = context.openFileInput(summaryFile.name).bufferedReader().useLines { lines ->
            lines.fold("") { _, data ->
                data
            }
        }

        return try {
            val json = JSONObject(data)
            val totalHistoricSteps = json.getInt("totalHistoricSteps")
            val totalHistoricTrees = json.getInt("totalHistoricTrees")
            val dailyGoal = json.getInt("dailyGoal")

            SummaryData(totalHistoricSteps, totalHistoricTrees, dailyGoal)
        } catch (e: Exception) {
            null
        }
    }

    fun saveSummaryData(summaryData: SummaryData): Boolean {
        val totalHistoricSteps = summaryData.totalHistoricSteps
        val totalHistoricTrees = summaryData.totalHistoricTrees
        val dailyGoal = summaryData.dailyGoal

        try {
            context.openFileOutput(summaryFile.name, Context.MODE_PRIVATE).also {
                val json = JSONObject()
                json.put("totalHistoricSteps", totalHistoricSteps)
                json.put("totalHistoricTrees", totalHistoricTrees)
                json.put("dailyGoal", dailyGoal)

                it.write(json.toString().toByteArray())

                return true
            }
        } catch (e: Exception) {
            return false
        }
    }

}