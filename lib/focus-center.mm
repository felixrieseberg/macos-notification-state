#import "napi.h"
#import <Foundation/Foundation.h>

#if __has_include("Intents/Intents.h")
#import <Intents/Intents.h>
#endif

// Requirements for make it work:
// 1. add entitlement <key>com.apple.developer.usernotifications.communication</key><true/>
// 2. create ProvisioningProfile (if have not yet) - allow Communication Notification service access
// 3. "NSFocusStatusUsageDescription": "some description", - in order to show Request access to FocusStatus
// note: for reset use "tccutil reset FocusStatus".

Napi::Value NoOp(const Napi::CallbackInfo &info) {
  return info.Env().Undefined();
}
Napi::Promise GetFocusStatus(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);
  Napi::ThreadSafeFunction ts_fn = Napi::ThreadSafeFunction::New(
      env, Napi::Function::New(env, NoOp), "focusStatusCallback", 0, 1,
      [](Napi::Env) {});

#if __has_include("Intents/Intents.h")
  NSLog(@"MacosNotificationState: FocusStatusCenter API available");

  [[INFocusStatusCenter defaultCenter]
      requestAuthorizationWithCompletionHandler:^(
          INFocusStatusAuthorizationStatus status) {
        NSLog(@"MacosNotificationState: INFocusStatusAuthorizationStatus: %ld",
              status);
        auto isAuthorized =
            status == INFocusStatusAuthorizationStatusAuthorized;
        // request FocusStatus.isFocused
        // calc real state according to schedule/personal/dnd focus modes also ensure allowed apps
        auto isFocused =
            [[[INFocusStatusCenter defaultCenter] focusStatus] isFocused];

        NSLog(@"MacosNotificationState: isFocused: %@", isFocused);

        auto callback = [=](Napi::Env env, Napi::Function noop_cb) {
          if (isAuthorized) {
            // resolve Promise with value
            deferred.Resolve(Napi::Number::New(env, [isFocused intValue]));
          } else {
            NSString *errorStatus = [NSString
                stringWithFormat:
                    @"FocusStatus access not authorized, status: %ld", status];
            deferred.Reject(
                Napi::TypeError::New(
                    env, Napi::String::New(env, [errorStatus UTF8String]))
                    .Value());
          }
        };
        ts_fn.BlockingCall(callback);
      }];
#endif
  NSLog(@"MacosNotificationState: promise created");
  return deferred.Promise();
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
#if __has_include("Intents/Intents.h")
  exports.Set(Napi::String::New(env, "getFocusStatus"),
              Napi::Function::New(env, GetFocusStatus));
#endif
  return exports;
}
NODE_API_MODULE(target_name, Init)
