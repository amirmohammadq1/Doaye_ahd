package ir.doayeahd.app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "ir.doayeahd.app/actions"
    private val appId = "ir.doayeahd.app"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "openMail" -> result.success(openMail())
                "openMyket" -> result.success(openMyket())
                else -> result.notImplemented()
            }
        }
    }

    // ارتباط با ما: ایمیل با موضوع آماده
    private fun openMail(): Boolean {
        val to = "amirm.developer000@gmail.com"
        val subject = "دعای عهد / duaahd"
        return try {
            val i = Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:$to?subject=" + Uri.encode(subject))).apply {
                putExtra(Intent.EXTRA_EMAIL, arrayOf(to))
                putExtra(Intent.EXTRA_SUBJECT, subject)
            }
            startActivity(i)
            true
        } catch (e: Exception) {
            false
        }
    }

    // امتیاز دادن: اول برنامه‌ی مایکت، بعد لینک صفحه‌ی برنامه
    private fun openMyket(): Boolean {
        val attempts = listOf(
            Intent(Intent.ACTION_VIEW, Uri.parse("myket://comment?id=$appId")).setPackage("ir.mservices.market"),
            Intent(Intent.ACTION_VIEW, Uri.parse("https://myket.ir/app/$appId")).setPackage("ir.mservices.market"),
            Intent(Intent.ACTION_VIEW, Uri.parse("https://myket.ir/app/$appId")),
        )
        for (a in attempts) {
            try {
                startActivity(a)
                return true
            } catch (e: Exception) {
                // next
            }
        }
        return false
    }
}
