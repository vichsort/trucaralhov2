package com.example.truco

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class TrucoWidgetDatabase(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {
    
    companion object {
        private const val DATABASE_NAME = "truco_widget.db"
        private const val DATABASE_VERSION = 1
        
        private const val TABLE_NAME = "scores"
        private const val COLUMN_ID = "id"
        private const val COLUMN_TEAM1_SCORE = "team1_score"
        private const val COLUMN_TEAM2_SCORE = "team2_score"
        
        private const val CREATE_TABLE = """
            CREATE TABLE $TABLE_NAME (
                $COLUMN_ID INTEGER PRIMARY KEY,
                $COLUMN_TEAM1_SCORE INTEGER DEFAULT 0,
                $COLUMN_TEAM2_SCORE INTEGER DEFAULT 0
            )
        """
    }
    
    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(CREATE_TABLE)
        
        // Insere o registro inicial
        val values = ContentValues().apply {
            put(COLUMN_ID, 1)
            put(COLUMN_TEAM1_SCORE, 0)
            put(COLUMN_TEAM2_SCORE, 0)
        }
        db.insert(TABLE_NAME, null, values)
    }
    
    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_NAME")
        onCreate(db)
    }
    
    fun getScores(): Pair<Int, Int> {
        val db = this.readableDatabase
        val cursor = db.query(
            TABLE_NAME,
            arrayOf(COLUMN_TEAM1_SCORE, COLUMN_TEAM2_SCORE),
            "$COLUMN_ID = ?",
            arrayOf("1"),
            null,
            null,
            null
        )
        
        return if (cursor.moveToFirst()) {
            val team1Score = cursor.getInt(cursor.getColumnIndexOrThrow(COLUMN_TEAM1_SCORE))
            val team2Score = cursor.getInt(cursor.getColumnIndexOrThrow(COLUMN_TEAM2_SCORE))
            cursor.close()
            Pair(team1Score, team2Score)
        } else {
            cursor.close()
            Pair(0, 0)
        }
    }
    
    fun addPointTeam1() {
        val db = this.writableDatabase
        val scores = getScores()
        val newScore = scores.first + 1
        
        val values = ContentValues().apply {
            put(COLUMN_TEAM1_SCORE, newScore)
        }
        
        db.update(TABLE_NAME, values, "$COLUMN_ID = ?", arrayOf("1"))
    }
    
    fun removePointTeam1() {
        val db = this.writableDatabase
        val scores = getScores()
        val newScore = maxOf(0, scores.first - 1)
        
        val values = ContentValues().apply {
            put(COLUMN_TEAM1_SCORE, newScore)
        }
        
        db.update(TABLE_NAME, values, "$COLUMN_ID = ?", arrayOf("1"))
    }
    
    fun addPointTeam2() {
        val db = this.writableDatabase
        val scores = getScores()
        val newScore = scores.second + 1
        
        val values = ContentValues().apply {
            put(COLUMN_TEAM2_SCORE, newScore)
        }
        
        db.update(TABLE_NAME, values, "$COLUMN_ID = ?", arrayOf("1"))
    }
    
    fun removePointTeam2() {
        val db = this.writableDatabase
        val scores = getScores()
        val newScore = maxOf(0, scores.second - 1)
        
        val values = ContentValues().apply {
            put(COLUMN_TEAM2_SCORE, newScore)
        }
        
        db.update(TABLE_NAME, values, "$COLUMN_ID = ?", arrayOf("1"))
    }
    
    fun resetScores() {
        val db = this.writableDatabase
        val values = ContentValues().apply {
            put(COLUMN_TEAM1_SCORE, 0)
            put(COLUMN_TEAM2_SCORE, 0)
        }
        
        db.update(TABLE_NAME, values, "$COLUMN_ID = ?", arrayOf("1"))
    }
}