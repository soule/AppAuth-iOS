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
include AppAuthTV using Carthage or Swift Package Manager, please see the main [README](../../README.md) for instructions. Also note that this Podfile uses the local copy of AppAuth, but in production, you should use the public version (as mentioned in the Podfile).

## Configuration

The example doesn't work out of the box; you need to configure it with your own client and IdP details.

### Information You'll Need

* Client ID
* Client Secret (optional)

If you are choosing to automatically discover endpoints:
* Issuer URL

If you are choosing to manually specify endpoints:
* TV Authorization Endpoint
* Token Endpoint
* User Info Endpoint

How to get this information varies by IdP, but we have
[instructions](../README.md#openid-certified-providers) for some OpenID
Certified providers.

### Configure the Example

#### In the file `AppAuthTVExampleViewController.m` 

1. Update `kClientID` with your new client ID.
2. Update `kClientSecret` with your client ID's secret, or set to empty if not using.

If using discovery:
1. Update `kIssuer` with the issuer URL.
2. set `shouldDiscoverEndpoints` to `YES`

If not using discovery:
2. set `shouldDiscoverEndpoints` to `NO`
1. Update `kTVAuthorizationEndpoint` with the TV Authorization endpoint.
4. Update `kTokenEndpoint` with the token endpoint.
5. Update `kUserInfoEndpoint` with the token endpoint.

### Running the Example

Now your example should be ready to run.
