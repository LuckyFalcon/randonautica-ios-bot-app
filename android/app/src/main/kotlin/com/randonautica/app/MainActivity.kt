package com.randonautica.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

import android.Manifest
import android.content.Intent
import android.widget.Toast
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import androidx.core.app.ActivityCompat

import androidx.annotation.NonNull

import com.randonautica.app.camrng.CamRNGActivity;

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.randonautica.app"

    companion object {
        const val REQUEST_PERMISSIONS = 1
    }

    private var bytesNeeded: Int? = 0

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if(call.method.equals("gotoCameraRNG")) {
                bytesNeeded = call.arguments as Int
                checkCameraPermissions()
            }
        }
    }

    private fun checkCameraPermissions() {
        if (ContextCompat.checkSelfPermission(this.getContext(), Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            gotoCameraRNG()
        } else {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), REQUEST_PERMISSIONS)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        if (requestCode == REQUEST_PERMISSIONS) {
            if (grantResults.size == 1 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                gotoCameraRNG()
            } else {
                Toast.makeText(getBaseContext(), "Won't work with out camera permissions!", Toast.LENGTH_SHORT).show()
            }
        } else {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }

    private fun gotoCameraRNG() {
        val intent = Intent(this, CamRNGActivity::class.java)
        intent.putExtra("bytesNeeded", this.bytesNeeded)
        startActivity(intent)
    }
}
