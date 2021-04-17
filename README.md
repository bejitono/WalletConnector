# WalletConnector

WalletConnector creates a connection to an Ethereum wallet. It also provides a UI component for choosing different wallets to connect with.

## Requirements

- iOS 14.0+
- Xcode 12.1

## Installation

#### Swift Package Manager
You can use SPM to install `WalletConnector` by adding the package to your XCode project.

## Usage example

#### WalletConnector

```swift
import WalletConnector

let connector = WalletConnector(
   appName: "Your app",
   appDescription: "Your app description",
   url: URL(string: "https://your-app.org")!
)
try? connector.connect()
connector.deeplinkURL(fromBaseURL: "metamask:")
if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
}
```

#### WalletConnectorUI

You can also `WalletConnectorViewController` to show a modal of wallets to connect your app to. You will also have to add all supported wallet deeplinks to your Info.plist.

<img width="312" alt="Screenshot 2021-04-17 at 20 34 14" src="https://user-images.githubusercontent.com/48912582/115115000-4843c100-9fbc-11eb-927e-46d8a2edfeff.png">

