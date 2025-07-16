package com.example.truco

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class TrucoWidgetProvider : AppWidgetProvider() {
    
    companion object {
        private const val ACTION_ADD_TEAM1 = "com.example.truco.ADD_TEAM1"
        private const val ACTION_REMOVE_TEAM1 = "com.example.truco.REMOVE_TEAM1"
        private const val ACTION_ADD_TEAM2 = "com.example.truco.ADD_TEAM2"
        private const val ACTION_REMOVE_TEAM2 = "com.example.truco.REMOVE_TEAM2"
        private const val ACTION_RESET = "com.example.truco.RESET"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        val dbHelper = TrucoWidgetDatabase(context)
        
        when (intent.action) {
            ACTION_ADD_TEAM1 -> {
                dbHelper.addPointTeam1()
            }
            ACTION_REMOVE_TEAM1 -> {
                dbHelper.removePointTeam1()
            }
            ACTION_ADD_TEAM2 -> {
                dbHelper.addPointTeam2()
            }
            ACTION_REMOVE_TEAM2 -> {
                dbHelper.removePointTeam2()
            }
            ACTION_RESET -> {
                dbHelper.resetScores()
            }
        }
        
        // Atualiza todos os widgets
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(context, TrucoWidgetProvider::class.java)
        )
        
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_layout)
        
        // Busca os scores do banco de dados
        val dbHelper = TrucoWidgetDatabase(context)
        val scores = dbHelper.getScores()
        
        // Atualiza os textos dos scores
        views.setTextViewText(R.id.scoreTeam1, scores.first.toString())
        views.setTextViewText(R.id.scoreTeam2, scores.second.toString())
        
        // Configura os botões
        setupButton(context, views, R.id.addPointTeam1, ACTION_ADD_TEAM1)
        setupButton(context, views, R.id.removePointTeam1, ACTION_REMOVE_TEAM1)
        setupButton(context, views, R.id.addPointTeam2, ACTION_ADD_TEAM2)
        setupButton(context, views, R.id.removePointTeam2, ACTION_REMOVE_TEAM2)
        setupButton(context, views, R.id.resetScore, ACTION_RESET)
        
        // Atualiza o widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
    
    private fun setupButton(context: Context, views: RemoteViews, buttonId: Int, action: String) {
        val intent = Intent(context, TrucoWidgetProvider::class.java)
        intent.action = action
        
        val pendingIntent = PendingIntent.getBroadcast(
            context, 
            action.hashCode(), 
            intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        views.setOnClickPendingIntent(buttonId, pendingIntent)
    }
}