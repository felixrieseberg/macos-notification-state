#include <node.h>
#include <v8.h>

#ifdef TARGET_OS_MAC
#include "notificationstate-query.h"
#include "do-not-disturb.h"
#endif

using namespace v8;

void _QueryUserSessionState(const v8::FunctionCallbackInfo<Value>& args) {
  Isolate* isolate = Isolate::GetCurrent();
  HandleScope scope(isolate);
  int returnValue = -1;

  #ifdef TARGET_OS_MAC
    returnValue = queryUserSessionState();
  #endif

  args.GetReturnValue().Set(Int32::New(isolate, returnValue));
}

void _GetDoNotDisturb(const v8::FunctionCallbackInfo<Value>& args) {
  Isolate* isolate = Isolate::GetCurrent();
  HandleScope scope(isolate);
  int returnValue = -1;

  #ifdef TARGET_OS_MAC
    bool dnd = getDoNotDisturb();

    if (dnd) {
      returnValue = 1;
    } else {
      returnValue = 0;
    }
  #endif

  args.GetReturnValue().Set(Int32::New(isolate, returnValue));
}

void Init(Handle<Object> exports) {
  Isolate* isolate = Isolate::GetCurrent();
  exports->Set(String::NewFromUtf8(isolate, "getNotificationState"),
      FunctionTemplate::New(isolate, _QueryUserSessionState)->GetFunction());
  exports->Set(String::NewFromUtf8(isolate, "getDoNotDisturb"),
      FunctionTemplate::New(isolate, _GetDoNotDisturb)->GetFunction());
}

NODE_MODULE(notificationstate, Init)