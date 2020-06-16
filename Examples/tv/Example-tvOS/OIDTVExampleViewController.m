/*! @file OIDTVExampleViewController.m
    @brief OID tvOS SDK Example

 @copyright
        Copyright 2016 Google Inc.
    @copydetails
        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
 */

#import "OIDTVExampleViewController.h"

#import <AppAuth/AppAuthCore.h>

#import <AppAuth/AppAuthTV.h>

#import "Secrets.h"

/*! @brief The OAuth client ID.
    @discussion For Google, register your client at
        https://console.developers.google.com/apis/credentials?project=_
 */
//static NSString *const kClientID = @"";

/*! @brief The OAuth client secret.
    @discussion For Google, register your client at
        https://console.developers.google.com/apis/credentials?project=_
 */
//static NSString *const kClientSecret = @"";

/*! @brief NSCoding key for the authorization property.
 */
static NSString *const kExampleAuthorizerKey = @"authorization";

/*! @brief Google's device authorization endpoint.
 */
NSString *const kGoogleDeviceAuthorizationEndpoint =
    @"https://accounts.google.com/o/oauth2/device/code";

/*! @brief NSCoding key for the authState property.
 */
static NSString *const kAppAuthExampleAuthStateKey = @"authState";

@interface OIDTVExampleViewController () <OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate>
-(OIDTVServiceConfiguration *) TVConfigurationForGoogle;
@end

@implementation OIDTVExampleViewController {
  OIDTVAuthorizationCancelBlock _cancelBlock;
}

- (OIDTVServiceConfiguration *)TVConfigurationForGoogle {
  NSURL *authorizationEndpoint =
      [NSURL URLWithString:@"https://accounts.google.com/o/oauth2/v2/auth"];
  NSURL *tokenEndpoint =
      [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v4/token"];
  NSURL *TVAuthorizationEndpoint =
      [NSURL URLWithString:kGoogleDeviceAuthorizationEndpoint];

  OIDTVServiceConfiguration *configuration =
      [[OIDTVServiceConfiguration alloc] initWithAuthorizationEndpoint:authorizationEndpoint
                                               TVAuthorizationEndpoint:TVAuthorizationEndpoint
                                                         tokenEndpoint:tokenEndpoint];
  return configuration;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  logTextView.text = @"";
  signInView.hidden = YES;
  cancelSignInButton.hidden = YES;
  logTextView.selectable = YES;
  logTextView.panGestureRecognizer.allowedTouchTypes = @[ @(UITouchTypeIndirect) ];

  [self loadState];
  [self updateUI];
}

- (void)stateChanged {
  [self saveState];
  [self updateUI];
}

- (void)didChangeState:(OIDAuthState *)state {
  [self stateChanged];
}

- (void)authState:(OIDAuthState *)state didEncounterAuthorizationError:(nonnull NSError *)error {
  [self logMessage:@"Received authorization error: %@", error];
}

- (IBAction)signin:(id)sender {
  if (_cancelBlock) {
    [self cancelSignIn:nil];
  }

  // builds authentication request
  OIDTVServiceConfiguration *configuration = [self TVConfigurationForGoogle];
  OIDTVAuthorizationRequest *request =
      [[OIDTVAuthorizationRequest alloc] initWithConfiguration:configuration
                                                      clientId:kClientID
                                                  clientSecret:kClientSecret
                                                        scopes:@[ OIDScopeOpenID, OIDScopeProfile ]
                                          additionalParameters:nil];

  _cancelBlock = [OIDTVAuthorizationService authorizeTVRequest:request
      initialization:^(OIDTVAuthorizationResponse *_Nullable response,
                       NSError *_Nullable error) {
    if (response) {
      [self logMessage:@"Authorization response: %@", response];
      signInView.hidden = NO;
      cancelSignInButton.hidden = NO;
      verificationURLLabel.text = response.verificationURL;
      userCodeLabel.text = response.userCode;
    } else {
      [self logMessage:@"Initialization error %@", error];
    }
  } completion:^(OIDAuthState *_Nullable authState,
                 NSError *_Nullable error) {
    signInView.hidden = YES;
    if (authState) {
      [self setAuthState:authState];
      [self logMessage:@"Token response: %@", authState.lastTokenResponse];
    } else {
      [self setAuthState:nil];
      [self logMessage:@"Error: %@", error];
    }
  }];
}

- (IBAction)cancelSignIn:(nullable id)sender {
  if (_cancelBlock) {
    _cancelBlock();
    _cancelBlock = nil;
  }
  signInView.hidden = YES;
  cancelSignInButton.hidden = YES;
}

- (void)setAuthState:(nullable OIDAuthState *)authState {
  if (_authState == authState) {
    return;
  }
  _authState = authState;
  _authState.stateChangeDelegate = self;
  [self stateChanged];
}

/*! @brief Saves the @c OIDAuthState to @c NSUSerDefaults.
 */
- (void)saveState {
  // for production usage consider using the OS Keychain instead
  NSData *archivedAuthState = [ NSKeyedArchiver archivedDataWithRootObject:_authState];
  [[NSUserDefaults standardUserDefaults] setObject:archivedAuthState
                                            forKey:kAppAuthExampleAuthStateKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

/*! @brief Loads the @c OIDAuthState from @c NSUSerDefaults.
 */
- (void)loadState {
  // loads OIDAuthState from NSUSerDefaults
  NSData *archivedAuthState =
      [[NSUserDefaults standardUserDefaults] objectForKey:kAppAuthExampleAuthStateKey];
  OIDAuthState *authState = [NSKeyedUnarchiver unarchiveObjectWithData:archivedAuthState];
  [self setAuthState:authState];
}


/*! @brief Refreshes UI, typically called after the auth state changed.
 */
- (void)updateUI {
  signInButtons.hidden = [_authState isAuthorized];
  signedInButtons.hidden = !signInButtons.hidden;
}

- (IBAction)clearAuthState:(nullable id)sender {
    [self setAuthState:nil];
    [self logMessage:@"Authorization state cleared."];
}

- (IBAction)clearLog:(nullable id)sender {
  [logTextView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
}

- (IBAction)userinfo:(nullable id)sender {
//    NSURL *userinfoEndpoint =
//        _authState.lastAuthorizationResponse.request.configuration.discoveryDocument.userinfoEndpoint;
    
    NSURL *userinfoEndpoint = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v3/userinfo"];
    
    if (!userinfoEndpoint) {
      [self logMessage:@"Userinfo endpoint not declared in discovery document"];
      return;
    }
    NSString *currentAccessToken = _authState.lastTokenResponse.accessToken;

    [self logMessage:@"Performing userinfo request"];

    [_authState performActionWithFreshTokens:^(NSString *_Nonnull accessToken,
                                               NSString *_Nonnull idToken,
                                               NSError *_Nullable error) {
      if (error) {
        [self logMessage:@"Error fetching fresh tokens: %@", [error localizedDescription]];
        return;
      }

      // log whether a token refresh occurred
      if (![currentAccessToken isEqual:accessToken]) {
        [self logMessage:@"Access token was refreshed automatically (%@ to %@)",
                           currentAccessToken,
                           accessToken];
      } else {
        [self logMessage:@"Access token was fresh and not updated [%@]", accessToken];
      }

      // creates request to the userinfo endpoint, with access token in the Authorization header
      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:userinfoEndpoint];
      NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
      [request addValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];

      NSURLSessionConfiguration *configuration =
          [NSURLSessionConfiguration defaultSessionConfiguration];
      NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                            delegate:nil
                                                       delegateQueue:nil];

      // performs HTTP request
      NSURLSessionDataTask *postDataTask =
          [session dataTaskWithRequest:request
                     completionHandler:^(NSData *_Nullable data,
                                         NSURLResponse *_Nullable response,
                                         NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^() {
          if (error) {
            [self logMessage:@"HTTP request failed %@", error];
            return;
          }
          if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
            [self logMessage:@"Non-HTTP response"];
            return;
          }

          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
          id jsonDictionaryOrArray =
              [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];

          if (httpResponse.statusCode != 200) {
            // server replied with an error
            NSString *responseText = [[NSString alloc] initWithData:data
                                                           encoding:NSUTF8StringEncoding];
            if (httpResponse.statusCode == 401) {
              // "401 Unauthorized" generally indicates there is an issue with the authorization
              // grant. Puts OIDAuthState into an error state.
              NSError *oauthError =
                  [OIDErrorUtilities resourceServerAuthorizationErrorWithCode:0
                                                                errorResponse:jsonDictionaryOrArray
                                                              underlyingError:error];
              [_authState updateWithAuthorizationError:oauthError];
              // log error
              [self logMessage:@"Authorization Error (%@). Response: %@", oauthError, responseText];
            } else {
              [self logMessage:@"HTTP: %d. Response: %@",
                               (int)httpResponse.statusCode,
                               responseText];
            }
            return;
          }

          // success response
          [self logMessage:@"Success: %@", jsonDictionaryOrArray];
        });
      }];

      [postDataTask resume];
    }];
}

/*! @brief Logs a message to stdout and the textfield.
    @param format The format string and arguments.
 */
- (void)logMessage:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
  // gets message as string
  va_list argp;
  va_start(argp, format);
  NSString *log = [[NSString alloc] initWithFormat:format arguments:argp];
  va_end(argp);

  // outputs to stdout
  NSLog(@"%@", log);

  // appends to output log
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateFormat = @"hh:mm:ss";
  NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
  NSString *logLine = [NSString stringWithFormat:@"\n%@: %@", dateString, log];
  UIFont *systemFont = [UIFont systemFontOfSize:36.0f];
  NSDictionary * fontAttributes =
      [[NSDictionary alloc] initWithObjectsAndKeys:systemFont, NSFontAttributeName, nil];
  NSMutableAttributedString* logLineAttr =
      [[NSMutableAttributedString alloc] initWithString:logLine attributes:fontAttributes];
  [[logTextView textStorage] appendAttributedString:logLineAttr];

  // Scroll to bottom
  if(logTextView.text.length > 0 ) {
    NSRange bottom = NSMakeRange(logTextView.text.length - 1, 1);
    [logTextView scrollRangeToVisible:bottom];
  }
}

@end

