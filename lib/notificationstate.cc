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

void Init(Local<Object> exports) {
  Isolate* isolate = Isolate::GetCurrent();

  Nan::Set(exports, String::NewFromUtf8(isolate, "getNotificationState"),
     Nan::GetFunction(FunctionTemplate::New(isolate, _QueryUserSessionState)).ToLocalChecked()
  );

  Nan::Set(exports, String::NewFromUtf8(isolate, "getDoNotDisturb"),
     Nan::GetFunction(FunctionTemplate::New(isolate, _GetDoNotDisturb)).ToLocalChecked()
  );
}

NODE_MODULE(notificationstate, Init)