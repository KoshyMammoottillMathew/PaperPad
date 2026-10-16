# PaperPad

A simple, privacy-first digital sticky-note app for iOS, built with SwiftUI and WidgetKit.

PaperPad is designed to feel like a small sheet of paper that is always ready for the next thought. Notes are stored locally on the user's device and shared only between the PaperPad app and its Home Screen widget through an iOS App Group.

## Features

- Create lightweight sticky-note style thoughts
- Mark notes complete with a strikethrough
- Edit and delete notes
- Undo recent deletions
- Automatic pages with up to 8 notes per page
- Home Screen widget support
- Interactive widget completion toggles
- Local persistence between launches
- No account required
- No ads, analytics or tracking

## Privacy by design

PaperPad does not contain an analytics SDK, advertising SDK, tracking SDK, cloud database or PaperPad server. The current app does not make network requests or transmit note contents.

Notes are encoded on-device and stored in `UserDefaults` inside the App Group container used by the main app and widget:

```text
group.com.koshymammoottillmathew.PaperPad
```

The widget reads the same local data so it can display notes and update their completion state.

See [PRIVACY.md](PRIVACY.md) for the project's privacy model and scope.

> Note: notes displayed in a Home Screen widget may be visible to anyone who can see the device's Home Screen. This is a device-display consideration, not external data collection by PaperPad.

## Technology

- Swift
- SwiftUI
- WidgetKit
- App Intents
- Codable / JSON
- App Groups
- UserDefaults

## Project structure

```text
PaperPad/
├── PaperPad/                         # Main iOS application
├── PaperPadWidget/                   # WidgetKit extension
├── PaperPadWidgetExtension.entitlements
└── PaperPad.xcodeproj/
```

## Running locally

1. Clone the repository.
2. Open `PaperPad.xcodeproj` in Xcode.
3. Select your own Apple Development team for both the PaperPad app and widget extension.
4. If necessary, replace the bundle identifiers and App Group with identifiers registered to your developer account.
5. Ensure the same App Group is enabled for both targets.
6. Build and run the `PaperPad` scheme on a compatible iOS simulator or device.

The identifiers included in this repository belong to the original project and may need to be changed when another developer signs their own build.

## Privacy-oriented contribution rule

PaperPad's defining constraint is that note content remains on-device. Contributions that introduce networking, analytics, advertising, telemetry, cloud synchronization or third-party SDKs should not be merged without an explicit privacy review and a corresponding update to the privacy documentation.

## License

Released under the [MIT License](LICENSE).
