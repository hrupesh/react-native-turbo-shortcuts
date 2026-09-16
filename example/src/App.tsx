import { useCallback, useEffect, useState } from 'react';
import {
  AppState,
  Button,
  Platform,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import TurboShortcuts, {
  type ShortcutItem,
} from 'react-native-turbo-shortcuts';

export default function App() {
  const [launchShortcut, setLaunchShortcut] = useState<ShortcutItem | null>(
    null
  );

  const addShortcuts = async () => {
    await TurboShortcuts.setShortcuts([
      {
        id: 'new_message',
        title: 'New Message',
        subtitle: 'Compose a new message', // iOS only
        ...Platform.select({
          ios: {
            // For iOS, use the icon type from the icon pack
            iconType: 'compose',
          },
          android: {
            // For Android, use the icon name from the icon pack
            iconName: 'ic_menu_send',
          },
        }),
      },
      {
        id: 'search',
        title: 'Search',
        subtitle: 'Search the app',
        ...Platform.select({
          ios: {
            iconType: 'search',
          },
          android: {
            iconName: 'ic_menu_search',
          },
        }),
      },
      {
        id: 'profile',
        title: 'My Profile',
        ...Platform.select({
          ios: {
            iconType: 'contact',
          },
          android: {
            iconName: 'ic_menu_myplaces',
          },
        }),
        data: { tab: 'profile', source: 'shortcut' },
      },
    ]);
    console.log('Shortcuts added!');
  };

  const clearAll = async () => {
    await TurboShortcuts.clearShortcuts();
    console.log('Shortcuts cleared!');
  };

  const listShortcuts = async () => {
    const shortcuts = await TurboShortcuts.getShortcuts();
    console.log('Current shortcuts:', shortcuts);
  };

  const getLaunchShortcut = useCallback(() => {
    const shortcut = TurboShortcuts.getLaunchShortcut() ?? null;
    setLaunchShortcut(shortcut);
    console.log('Launch shortcut:', shortcut);
  }, []);

  useEffect(() => {
    const listener = AppState.addEventListener('change', (state) => {
      if (state === 'active') {
        getLaunchShortcut();
      }
    });

    return () => {
      listener.remove();
    };
  }, [getLaunchShortcut]);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>App Shortcuts Demo</Text>
      <Text>Max shortcuts: {TurboShortcuts.getMaxShortcuts()}</Text>
      <Text>Supported: {TurboShortcuts.isSupported() ? 'Yes' : 'No'}</Text>
      <Text>Launch shortcut: {launchShortcut?.title}</Text>
      <Button title="Add Shortcuts" onPress={addShortcuts} />
      <Button title="List Shortcuts" onPress={listShortcuts} />
      <Button title="Clear All" onPress={clearAll} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
    gap: 1,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 20,
  },
});
