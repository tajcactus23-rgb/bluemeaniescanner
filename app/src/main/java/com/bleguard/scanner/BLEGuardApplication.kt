package com.bleguard.scanner

import android.app.Application
import com.bleguard.scanner.utils.PreferencesManager

class BLEGuardApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        PreferencesManager.init(this)
    }
}