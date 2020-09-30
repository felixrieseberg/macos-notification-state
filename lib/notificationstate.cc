#define NAPI_VERSION 3
#include <node_api.h>

#define NAPI_CALL(env, call)                                      \
  do {                                                            \
    napi_status status = (call);                                  \
    if (status != napi_ok) {                                      \
      const napi_extended_error_info* error_info = NULL;          \
      napi_get_last_error_info((env), &error_info);               \
      bool is_pending;                                            \
      napi_is_exception_pending((env), &is_pending);              \
      if (!is_pending) {                                          \
        const char* message = (error_info->error_message == NULL) \
            ? "empty error message"                               \
            : error_info->error_message;                          \
        napi_throw_error((env), NULL, message);                   \
        return NULL;                                              \
      }                                                           \
    }                                                             \
  } while(0)


#ifdef __APPLE__
#include "notificationstate-query.h"
#include "do-not-disturb.h"
#endif

static napi_value QueryUserSessionState(napi_env env, napi_callback_info info) {
  int returnValue = -1;

  #ifdef __APPLE__
  returnValue = queryUserSessionState();
  #endif

  napi_value result;
  NAPI_CALL(env, napi_create_int32(env, returnValue, &result));
  return result;
}

static napi_value GetDoNotDisturb(napi_env env, napi_callback_info info) {
  int returnValue = -1;

  #ifdef __APPLE__
  bool dnd = getDoNotDisturb();

  if (dnd) {
    returnValue = 1;
  } else {
    returnValue = 0;
  }
  #endif

  napi_value result;
  NAPI_CALL(env, napi_create_int32(env, returnValue, &result));
  return result;
}

NAPI_MODULE_INIT() {
  napi_value result = nullptr;
  NAPI_CALL(env, napi_create_object(env, &result));

  #ifdef __APPLE__
  napi_value exported_function;
  NAPI_CALL(env, napi_create_function(env, "getNotificationState", NAPI_AUTO_LENGTH, QueryUserSessionState, NULL, &exported_function));
  NAPI_CALL(env, napi_set_named_property(env, result, "getNotificationState", exported_function));

  NAPI_CALL(env, napi_create_function(env, "getDoNotDisturb", NAPI_AUTO_LENGTH, GetDoNotDisturb, NULL, &exported_function));
  NAPI_CALL(env, napi_set_named_property(env, result, "getDoNotDisturb", exported_function));
  #endif
  return result;
}
