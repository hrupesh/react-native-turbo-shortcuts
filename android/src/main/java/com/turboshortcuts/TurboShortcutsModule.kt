package com.turboshortcuts

import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.graphics.drawable.IconCompat
import com.facebook.react.bridge.*

class TurboShortcutsModule(reactContext: ReactApplicationContext) :
  NativeTurboShortcutsSpec(reactContext) {

  override fun getName() = NAME

  private val shortcutManager: ShortcutManager? by lazy {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
      reactApplicationContext.getSystemService(ShortcutManager::class.java)
    } else null
  }

  // MARK: - Set shortcuts
  override fun setShortcuts(shortcuts: ReadableArray, promise: Promise) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
      promise.resolve(false); return
    }
    try {
      val items = (0 until shortcuts.size())
        .mapNotNull { buildShortcut(shortcuts.getMap(it)) }
      shortcutManager?.dynamicShortcuts = items
      promise.resolve(true)
    } catch (e: Exception) { promise.reject("SET_ERROR", e.message) }
  }

  // MARK: - Add single shortcut
  override fun addShortcut(shortcut: ReadableMap, promise: Promise) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
      promise.resolve(false); return
    }
    try {
      val item = buildShortcut(shortcut) ?: run {
        promise.reject("BUILD_ERROR", "Failed to build shortcut"); return
      }
      shortcutManager?.addDynamicShortcuts(listOf(item))
      promise.resolve(true)
    } catch (e: Exception) { promise.reject("ADD_ERROR", e.message) }
  }

  // MARK: - Remove shortcut
  override fun removeShortcut(id: String, promise: Promise) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
      promise.resolve(false); return
    }
    try {
      shortcutManager?.removeDynamicShortcuts(listOf(id))
      promise.resolve(true)
    } catch (e: Exception) { promise.reject("REMOVE_ERROR", e.message) }
  }

  // MARK: - Clear all
  override fun clearShortcuts(promise: Promise) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
      promise.resolve(false); return
    }
    try {
      shortcutManager?.removeAllDynamicShortcuts()
      promise.resolve(true)
    } catch (e: Exception) { promise.reject("CLEAR_ERROR", e.message) }
  }

  // MARK: - Get shortcuts
  override fun getShortcuts(promise: Promise) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
      promise.resolve(Arguments.createArray()); return
    }
    try {
      val result = Arguments.createArray()
      shortcutManager?.dynamicShortcuts?.forEach { shortcut ->
        result.pushMap(shortcutToMap(shortcut))
      }
      promise.resolve(result)
    } catch (e: Exception) { promise.reject("GET_ERROR", e.message) }
  }

  // MARK: - Get launch shortcut
  override fun getLaunchShortcut(): WritableMap? {
    val shortcutId = TurboShortcutsLaunchReceiver.launchShortcutId
    if (shortcutId != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
        val shortcut = shortcutManager?.dynamicShortcuts
          ?.firstOrNull { it.id == shortcutId }
        if (shortcut != null) {
          return shortcutToMap(shortcut)
        } else {
          // Return just the ID if shortcut details not found
          val map = Arguments.createMap()
          map.putString("id", shortcutId)
          map.putString("title", "")
          return map
        }
      } else {
        return null
      }
      TurboShortcutsLaunchReceiver.launchShortcutId = null
    } else {
      return null
    }
  }

  // MARK: - Max shortcuts (synchronous)
  override fun getMaxShortcuts(): Double {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
      (shortcutManager?.maxShortcutCountPerActivity ?: 4).toDouble()
    } else 0.0
  }

  // MARK: - Helpers
  @RequiresApi(Build.VERSION_CODES.N_MR1)
  private fun buildShortcut(map: ReadableMap?): ShortcutInfo? {
    map ?: return null
    val id = map.getString("id") ?: return null
    val title = map.getString("title") ?: return null
    val iconName = if (map.hasKey("iconName")) map.getString("iconName") else null

    val intent = Intent(reactApplicationContext,
      Class.forName("${reactApplicationContext.packageName}.MainActivity")).apply {
      action = Intent.ACTION_VIEW
      putExtra("shortcutId", id)
      // Pass custom data
      if (map.hasKey("data")) {
        map.getMap("data")?.toHashMap()?.forEach { (k, v) ->
          putExtra(k, v.toString())
        }
      }
    }

    val builder = ShortcutInfo.Builder(reactApplicationContext, id)
      .setShortLabel(title)
      .setLongLabel(title)
      .setIntent(intent)

    // Set icon
    if (iconName != null) {
       val resId = reactApplicationContext.resources.getIdentifier(
         iconName,
         "drawable",
         "android"
       )
      if (resId >= 0) {
        builder.setIcon(
          IconCompat.createWithResource
            (reactApplicationContext, resId)
            .toIcon(reactApplicationContext)
        )
      }
    }

    return builder.build()
  }

  @RequiresApi(Build.VERSION_CODES.N_MR1)
  private fun shortcutToMap(shortcut: ShortcutInfo): WritableMap {
    return Arguments.createMap().apply {
      putString("id", shortcut.id)
      putString("title", shortcut.shortLabel?.toString() ?: "")
    }
  }

  companion object { const val NAME = "TurboShortcuts" }
}
