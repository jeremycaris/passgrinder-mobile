# passgrinder-mobile

## Running on iOS Simulator (macOS)

1. Open **Simulator** from Spotlight (`⌘ Space` → type "Simulator" → hit Enter)
2. If no device appears, go to **File → Open Simulator** and pick an iPhone (e.g. iPhone 16 Pro)
3. Wait for the home screen to fully load
4. In VS Code, open the terminal (`⌃ ~`) and run:
   ```bash
   flutter run
   ```
5. Flutter will detect the simulator automatically and launch the app

### Hot Reload / Restart

While `flutter run` is active in the terminal:

- Press **r** for hot reload (applies code changes instantly)
- Press **R** for hot restart (restarts the app state)
- Press **q** to quit