import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

// Shortcut icon type
export type ShortcutIconType =
  | 'compose'
  | 'play'
  | 'pause'
  | 'add'
  | 'location'
  | 'search'
  | 'share'
  | 'prohibit'
  | 'contact'
  | 'home'
  | 'markLocation'
  | 'favorite'
  | 'love'
  | 'cloud'
  | 'invitation'
  | 'confirmation'
  | 'mail'
  | 'message'
  | 'date'
  | 'time'
  | 'capturePhoto'
  | 'captureVideo'
  | 'task'
  | 'taskCompleted'
  | 'alarm'
  | 'bookmark'
  | 'shuffle'
  | 'audio'
  | 'update';

export interface ShortcutItem {
  id: string; // unique identifier
  title: string; // shown to user
  subtitle?: string; // shown below title (iOS only)
  iconType?: ShortcutIconType; // system icon
  iconName?: string; // custom icon from asset
  data?: { [key: string]: string }; // extra data passed on launch
}

export interface Spec extends TurboModule {
  // Add or update shortcuts
  setShortcuts(shortcuts: ShortcutItem[]): Promise<boolean>;

  // Add a single shortcut
  addShortcut(shortcut: ShortcutItem): Promise<boolean>;

  // Remove a shortcut by id
  removeShortcut(id: string): Promise<boolean>;

  // Remove all shortcuts
  clearShortcuts(): Promise<boolean>;

  // Get all current shortcuts
  getShortcuts(): Promise<ShortcutItem[]>;

  // Get the shortcut that launched the app (if any)
  // Returns null if app was opened normally
  getLaunchShortcut(): ShortcutItem | null;

  // Maximum shortcuts allowed on this device
  getMaxShortcuts(): number; // synchronous via JSI
}

export default TurboModuleRegistry.getEnforcing<Spec>('TurboShortcuts');
