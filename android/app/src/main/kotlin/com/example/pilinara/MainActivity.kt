package com.example.pilinara

import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Bundle
import android.view.WindowManager.LayoutParams
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private lateinit var methodChannel: MethodChannel

    /**
     * 投屏（DLNA/SSDP）用的组播锁。
     *
     * Android 7.0 起，Wi-Fi 驱动进入省电模式后会丢弃所有组播/广播帧，不持锁的话
     * M-SEARCH 根本发不出去、设备的应答也收不到，表现为「投屏一直转圈然后没有设备」。
     * 必须持有强引用，否则锁会被 GC 回收而失效。
     * 需配合 AndroidManifest 里的 CHANGE_WIFI_MULTICAST_STATE 权限。
     */
    private var multicastLock: WifiManager.MulticastLock? = null

    private fun acquireMulticastLock(): Boolean {
        if (multicastLock?.isHeld == true) return true
        return try {
            // 用 Context.WIFI_SERVICE 常量而不是裸 WIFI_SERVICE：Kotlin 不继承
            // Java 的静态成员，未限定名能否解析取决于编译器，限定写法一定成立。
            val wifiManager = applicationContext
                .getSystemService(Context.WIFI_SERVICE) as? WifiManager
            if (wifiManager == null) {
                false
            } else {
                multicastLock = wifiManager.createMulticastLock("pili-dlna").apply {
                    setReferenceCounted(false)
                    acquire()
                }
                true
            }
        } catch (_: Throwable) {
            // 拿不到锁不应让应用崩溃；投屏会搜不到设备，但其余功能正常。
            multicastLock = null
            false
        }
    }

    private fun releaseMulticastLock() {
        try {
            multicastLock?.let { if (it.isHeld) it.release() }
        } catch (_: Throwable) {
            // 忽略：释放失败无需处理，进程回收时系统会回收。
        }
        multicastLock = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "PiliNara")
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "acquireMulticastLock" -> result.success(acquireMulticastLock())

                "releaseMulticastLock" -> {
                    releaseMulticastLock()
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        if (AndroidHelper.isFoldable) {
            AndroidHelper.ToDart.onConfigurationChanged?.run()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.attributes.layoutInDisplayCutoutMode =
                LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
        }
    }

    override fun onStart() {
        super.onStart()
        // 整个前台期间持锁，保证任何时刻进入投屏都能收到 SSDP 应答。
        acquireMulticastLock()
    }

    override fun onStop() {
        releaseMulticastLock()
        super.onStop()
    }

    override fun onDestroy() {
        releaseMulticastLock()
        stopService(Intent(this, com.ryanheise.audioservice.AudioService::class.java))
        super.onDestroy()
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        AndroidHelper.ToDart.onUserLeaveHint?.run()
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration?
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        AndroidHelper.isPipMode = isInPictureInPictureMode
        methodChannel.invokeMethod("onPipChanged", isInPictureInPictureMode)
    }
}
