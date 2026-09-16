//
//  TurboShortcutsLaunchHandler.swift
//  
//
//  Created by Rupesh Chaudhari.
//

import UIKit

// Singleton to capture the shortcut that launched the app
@objc public class TurboShortcutsLaunchHandler: NSObject {
  @objc public static let shared = TurboShortcutsLaunchHandler()
  public var launchShortcut: UIApplicationShortcutItem?
  private override init() {}
}
