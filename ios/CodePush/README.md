#  CodePush

## Installation

### Cocoa Pods

``` swift
     pod 'CodePush', :git => 'https://github.com/chmoulds/react-native-code-push.git', :branch => 'chrism/swift-imp' 
```

## Usage

``` swift
let codePushBuilder = CodePushBuilder()
codePushBuilder.setDeploymentKey(key: deployKey) // Required
codePushBuilder.setAppName(name: appName)
codePushBuilder.setAppVersion(version: version)
let codePush = codePushBuilder.result()

if (codePush != nil) {

    // Try checking for an update
    codePush!.checkForUpdate(callback: { result in
        do {
            let remotePackage = try result.resolve()
            if (remotePackage != nil) {
                print(String(format: "Remote Package available at %@", (remotePackage!.downloadURL?.absoluteString)!))
            } else {
                print("Already up to date!")
            }
        } catch {
            print("Something bad happened during the update fetch...")
            print(error)
        }
    })
    
    // Try syncing an update if available
    codePush!.sync(callback: { result in
        do {
            let didSync = try result.resolve()
            if (didSync) {
                print("Synced!") 
            } else {
                print("You're up to date. Nothing to sync.")
            }
        } catch {
            print("Something bad happened during synchronization...")
            print(error)
        }
    })
}
```


