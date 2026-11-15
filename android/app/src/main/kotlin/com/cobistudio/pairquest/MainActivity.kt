package com.cobistudio.pairquest

import com.google.android.play.agesignals.AgeSignalsAccessRequest
import com.google.android.play.agesignals.AgeSignalsException
import com.google.android.play.agesignals.AgeSignalsManagerFactory
import com.google.android.play.agesignals.AgeSignalsRequest
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "memoko/age_signals")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "check" -> checkAgeSignals(result)
                    "requestAccess" -> requestAccess(result)
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Asks Google Play for the user's age range. Only the range and the
     * significant-change approval go to Dart; the install ID stays here.
     * Errors come back as a code so Dart can fall back to its own age screen.
     */
    private fun checkAgeSignals(result: MethodChannel.Result) {
        AgeSignalsManagerFactory.create(applicationContext)
            .checkAgeSignals(AgeSignalsRequest.builder().build())
            .addOnSuccessListener { signals ->
                result.success(
                    mapOf(
                        "ageLower" to signals.ageLower(),
                        "ageUpper" to signals.ageUpper(),
                        "ageRangeSource" to signals.ageRangeSource(),
                        "significantChangeStatus" to signals.significantChangeStatus(),
                        "significantChangeApprovalDate" to signals.significantChangeApprovalDate()?.time,
                    )
                )
            }
            .addOnFailureListener { error ->
                result.success(mapOf("errorCode" to errorCode(error)))
            }
    }

    /** Opens Play's sheet that asks the user to share their age with the app. */
    private fun requestAccess(result: MethodChannel.Result) {
        AgeSignalsManagerFactory.create(applicationContext)
            .requestAgeSignalsAccess(AgeSignalsAccessRequest.builder().setActivity(this).build())
            .addOnSuccessListener { access ->
                result.success(mapOf("status" to access.ageSignalsStatus()))
            }
            .addOnFailureListener { error ->
                result.success(mapOf("errorCode" to errorCode(error)))
            }
    }

    private fun errorCode(error: Exception): Int =
        (error as? AgeSignalsException)?.errorCode ?: -1
}
