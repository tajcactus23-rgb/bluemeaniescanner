package com.bleguard.scanner.data

import android.content.Context
import androidx.room.*
import com.bleguard.scanner.model.*

@Database(
    entities = [DetectionLog::class, AllowlistEntry::class, ScanSession::class],
    version = 1,
    exportSchema = false
)
abstract class BLEGuardDatabase : RoomDatabase() {
    abstract fun detectionLogDao(): DetectionLogDao
    abstract fun allowlistDao(): AllowlistDao
    abstract fun sessionDao(): SessionDao
}

@Dao
interface DetectionLogDao {
    @Insert
    suspend fun insert(detection: DetectionLog)
    
    @Query("SELECT * FROM detections WHERE sessionId = :sessionId ORDER BY timestamp DESC")
    fun getDetectionsForSession(sessionId: String): List<DetectionLog>
    
    @Query("SELECT * FROM detections ORDER BY timestamp DESC LIMIT :limit")
    fun getRecentDetections(limit: Int): List<DetectionLog>
    
    @Query("SELECT * FROM detections ORDER BY timestamp DESC")
    fun getAllDetections(): List<DetectionLog>
    
    @Query("SELECT COUNT(*) FROM detections WHERE sessionId = :sessionId")
    fun getDetectionCount(sessionId: String): Int
    
    @Query("SELECT COUNT(DISTINCT deviceAddress) FROM detections WHERE sessionId = :sessionId")
    fun getUniqueDeviceCount(sessionId: String): Int
    
    @Query("DELETE FROM detections WHERE sessionId = :sessionId")
    suspend fun deleteForSession(sessionId: String)
    
    @Query("DELETE FROM detections")
    suspend fun deleteAll()
}

@Dao
interface AllowlistDao {
    @Insert
    suspend fun insert(entry: AllowlistEntry)
    
    @Update
    suspend fun update(entry: AllowlistEntry)
    
    @Delete
    suspend fun delete(entry: AllowlistEntry)
    
    @Query("SELECT * FROM allowlist WHERE isEnabled = 1")
    fun getEnabledEntries(): List<AllowlistEntry>
    
    @Query("SELECT * FROM allowlist ORDER BY createdAt DESC")
    fun getAllEntries(): List<AllowlistEntry>
    
    @Query("SELECT * FROM allowlist WHERE id = :id")
    suspend fun getById(id: Long): AllowlistEntry?
    
    @Query("SELECT * FROM allowlist WHERE identifier = :identifier")
    suspend fun findByIdentifier(identifier: String): AllowlistEntry?
    
    @Query("UPDATE allowlist SET isEnabled = :enabled WHERE id = :id")
    suspend fun setEnabled(id: Long, enabled: Boolean)
}

@Dao
interface SessionDao {
    @Insert
    suspend fun insert(session: ScanSession)
    
    @Update
    suspend fun update(session: ScanSession)
    
    @Query("SELECT * FROM sessions WHERE sessionId = :sessionId")
    suspend fun getById(sessionId: String): ScanSession?
    
    @Query("SELECT * FROM sessions WHERE isActive = 1 LIMIT 1")
    suspend fun getActiveSession(): ScanSession?
    
    @Query("SELECT * FROM sessions ORDER BY startTime DESC LIMIT 1")
    suspend fun getLastSession(): ScanSession?
}