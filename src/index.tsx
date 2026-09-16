import NativeTurboShortcuts from './NativeTurboShortcuts';
import type { ShortcutItem } from './NativeTurboShortcuts';
import { Platform } from 'react-native';

export type { ShortcutItem };

const TurboShortcuts = {
  /**
   * Set shortcuts — replaces all existing dynamic shortcuts
   * Maximum 4 on iOS, varies on Android (usually 4-5)
   */
  setShortcuts: (shortcuts: ShortcutItem[]): Promise<boolean> =>
    NativeTurboShortcuts.setShortcuts(shortcuts),

  /**
   * Add a single shortcut without affecting others
   */
  addShortcut: (shortcut: ShortcutItem): Promise<boolean> =>
    NativeTurboShortcuts.addShortcut(shortcut),

  /**
   * Remove a shortcut by its id
   */
  removeShortcut: (id: string): Promise<boolean> =>
    NativeTurboShortcuts.removeShortcut(id),

  /**
   * Remove all dynamic shortcuts
   */
  clearShortcuts: (): Promise<boolean> => NativeTurboShortcuts.clearShortcuts(),

  /**
   * Get all current dynamic shortcuts
   */
  getShortcuts: (): Promise<ShortcutItem[]> =>
    NativeTurboShortcuts.getShortcuts(),

  /**
   * Get the shortcut that launched the app.
   * Call this in your root component on mount.
   * Returns null if app was opened normally.
   */
  getLaunchShortcut: (): ShortcutItem | null =>
    NativeTurboShortcuts.getLaunchShortcut() || null,

  /**
   * Maximum number of shortcuts supported on this device
   * Synchronous — no await needed
   */
  getMaxShortcuts: (): number => NativeTurboShortcuts.getMaxShortcuts(),

  /**
   * Whether shortcuts are supported on this device
   */
  isSupported: (): boolean => {
    if (Platform.OS === 'ios') return parseInt(Platform.Version, 10) >= 9;
    if (Platform.OS === 'android') return (Platform.Version as number) >= 25;
    return false;
  },
};

export default TurboShortcuts;
