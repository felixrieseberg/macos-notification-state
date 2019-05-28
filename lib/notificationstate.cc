#include <node.h>
#include <v8.h>
#include <nan.h>

#ifdef TARGET_OS_MAC
#include "notificationstate-query.h"
#include "do-not-disturb.h"
#endif

using namespace v8;

NAN_METHOD(QueryUserSessionState) {
  Isolate* isolate = Isolate::GetCurrent();
  HandleScope scope(isolate);
  int returnValue = -1;

  #ifdef TARGET_OS_MAC
    returnValue = queryUserSessionState();
  #endif

  info.GetReturnValue().Set(Int32::New(isolate, returnValue));
}

NAN_METHOD(GetDoNotDisturb) {
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

  info.GetReturnValue().Set(Int32::New(isolate, returnValue));
}

NAN_MODULE_INIT(Init) {
  #ifdef TARGET_OS_MAC
  Nan::SetMethod(target, "getNotificationState", QueryUserSessionState);
  Nan::SetMethod(target, "getDoNotDisturb", GetDoNotDisturb);
  #endif
}

#if NODE_MAJOR_VERSION >= 10
NAN_MODULE_WORKER_ENABLED(notificationstate, Init)
#else
NODE_MODULE(notificationstate, Init)
#endif
