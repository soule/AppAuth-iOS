# Example Project

## Setup & Open the Project

1. In the `Example-tvOS` folder, run the following command to install the
AppAuth pod.

```
pod install
```

2. Open the `Example-tvOS.xcworkspace` workspace

```
open Example-tvOS.xcworkspace
```

This workspace is configured to include AppAuth via CocoaPods. You can also
include AppAuthTV using Carthage or Swift Package Manager, please see the main [README](../../README.md) for instructions. Also note that this Podfile uses the local copy of AppAuth, but in production, should use the public version.

## Configuration

The example doesn't work out of the box; you need to configure it with your own
client ID, client secret (optional), TV authorization endpoint, token endpoint, and user info endpoint.

### Information You'll Need

* Client ID
* Client Secret (optional)
* TV Authorization Endpoint
* Token Endpoint
* User Info Endpoint

How to get this information varies by IdP, but we have
[instructions](../README.md#openid-certified-providers) for some OpenID
Certified providers.

### Configure the Example

#### In the file `AppAuthTVExampleViewController.m` 

1. Update `kTVAuthorizationEndpoint` with the TV Authorization endpoint.
2. Update `kClientID` with your new client ID.
3. Update `kClientSecret` with your client ID's secret.
4. Update `kTokenEndpoint` with the token endpoint.
5. Update `kUserInfoEndpoint` with the token endpoint.

### Running the Example

Now your example should be ready to run.
