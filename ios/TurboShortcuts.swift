//
//  TurboShortcuts.swift
//  
//
//  Created by Rupesh Chaudhari.
//
import UIKit
import React

@objc(TurboShortcuts)
class TurboShortcuts: NSObject {

  // MARK: - Set shortcuts (replaces all existing)
  @objc func setShortcuts(
    _ shortcuts: [[String: Any]],
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async {
      let items = shortcuts.compactMap { self.buildShortcutItem(from: $0) }
      UIApplication.shared.shortcutItems = items
      resolve(true)
    }
  }

  // MARK: - Add single shortcut
  @objc func addShortcut(
    _ shortcut: [String: Any],
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async {
      guard let item = self.buildShortcutItem(from: shortcut) else {
        reject("BUILD_ERROR", "Failed to build shortcut item", nil as NSError?)
        return
      }
      var current = UIApplication.shared.shortcutItems ?? []
      current.removeAll { $0.type == item.type }
      current.append(item)
      UIApplication.shared.shortcutItems = current
      resolve(true)
    }
  }

  // MARK: - Remove shortcut by id
  @objc func removeShortcut(
    _ id: String,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async {
      var current = UIApplication.shared.shortcutItems ?? []
      current.removeAll { $0.type == id }
      UIApplication.shared.shortcutItems = current
      resolve(true)
    }
  }

  // MARK: - Clear all shortcuts
  @objc func clearShortcuts(
    _ resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async {
      UIApplication.shared.shortcutItems = []
      resolve(true)
    }
  }

  // MARK: - Get all shortcuts
  @objc func getShortcuts(
    _ resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    DispatchQueue.main.async {
      let items = UIApplication.shared.shortcutItems ?? []
      let result = items.map { self.shortcutItemToDict($0) }
      resolve(result)
    }
  }

  // MARK: - Get launch shortcut
  @objc func getLaunchShortcut() -> NSObject? {
    if let shortcut = TurboShortcutsLaunchHandler.shared.launchShortcut {
      TurboShortcutsLaunchHandler.shared.launchShortcut = nil
      return shortcutItemToDict(shortcut) as NSObject
    } else {
      return nil
    }
  }

  // MARK: - Max shortcuts (synchronous)
  @objc func getMaxShortcuts() -> NSNumber {
    return 4
  }

  // MARK: - Helpers
  private func buildShortcutItem(from dict: [String: Any]) -> UIApplicationShortcutItem? {
    guard let id = dict["id"] as? String,
          let title = dict["title"] as? String else { return nil }

    let subtitle = dict["subtitle"] as? String
    let iconType = dict["iconType"] as? String
    let iconName = dict["iconName"] as? String
    let data = dict["data"] as? [String: String]

    var icon: UIApplicationShortcutIcon?
    if let iconName = iconName {
      icon = UIApplicationShortcutIcon(templateImageName: iconName)
    } else if let iconType = iconType, let type = mapIconType(iconType) {
      icon = UIApplicationShortcutIcon(type: type)
    }

    var userInfo: [String: NSSecureCoding] = [:]
    if let data = data {
      data.forEach { userInfo[$0.key] = $0.value as NSString }
    }

    return UIApplicationShortcutItem(
      type: id,
      localizedTitle: title,
      localizedSubtitle: subtitle,
      icon: icon,
      userInfo: userInfo.isEmpty ? nil : userInfo
    )
  }

  private func shortcutItemToDict(_ item: UIApplicationShortcutItem) -> [String: Any] {
    var dict: [String: Any] = [
      "id": item.type,
      "title": item.localizedTitle,
    ]
    if let subtitle = item.localizedSubtitle { dict["subtitle"] = subtitle }
    if let userInfo = item.userInfo {
      var data: [String: String] = [:]
      userInfo.forEach { data[$0.key] = $0.value as? String ?? "" }
      if !data.isEmpty { dict["data"] = data }
    }
    return dict
  }

  private func mapIconType(_ type: String) -> UIApplicationShortcutIcon.IconType? {
    let map: [String: UIApplicationShortcutIcon.IconType] = [
      "compose": .compose, "play": .play, "pause": .pause,
      "add": .add, "location": .location, "search": .search,
      "share": .share, "prohibit": .prohibit, "contact": .contact,
      "home": .home, "markLocation": .markLocation, "favorite": .favorite,
      "love": .love, "cloud": .cloud, "invitation": .invitation,
      "confirmation": .confirmation, "mail": .mail, "message": .message,
      "date": .date, "time": .time, "capturePhoto": .capturePhoto,
      "captureVideo": .captureVideo, "task": .task,
      "taskCompleted": .taskCompleted, "alarm": .alarm,
      "bookmark": .bookmark, "shuffle": .shuffle, "audio": .audio,
      "update": .update
    ]
    return map[type]
  }

  @objc static func requiresMainQueueSetup() -> Bool { return false }
}
