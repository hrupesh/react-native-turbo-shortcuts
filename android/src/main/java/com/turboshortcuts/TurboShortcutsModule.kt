package com.turboshortcuts

import com.facebook.react.bridge.ReactApplicationContext

class TurboShortcutsModule(reactContext: ReactApplicationContext) :
  NativeTurboShortcutsSpec(reactContext) {

  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }

  companion object {
    const val NAME = NativeTurboShortcutsSpec.NAME
  }
}
