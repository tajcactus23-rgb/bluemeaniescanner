package com.bleguard.scanner.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import com.bleguard.scanner.service.BLEScannerService
import com.bleguard.scanner.utils.PreferencesManager

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED && context != null) {
            PreferencesManager.init(context)
            
            if (PreferencesManager.autoStartOnBoot) {
                val serviceIntent = Intent(context, BLEScannerService::class.java).apply {
                    action = BLEScannerService.ACTION_START_SCAN
                }
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
            }
        }
    }
}