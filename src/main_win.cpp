#include <napi.h>
#include <string>
#include <vector>
#include <iostream>
#include <windows.h>

Napi::Value getWindowsList(const Napi::CallbackInfo &info)
{
  Napi::Env env = info.Env();
  
  int argc = info.Length();
  if (argc != 1) {
    Napi::TypeError::New(env, "Invalid number of arguments")
        .ThrowAsJavaScriptException();
    return env.Null();
  }
  
  if (!info[0].IsArray()) {
    Napi::TypeError::New(env, "Argument should be an Array")
        .ThrowAsJavaScriptException();
    return env.Null();
  }
  
  Napi::Array array = info[0].As<Napi::Array>();
  int length = array.Length();

  struct MyScreenCaptureSourceInfo {
    Napi::Object coreInfo;
    ULONGLONG processStartUnixTime;
    DWORD processId;
  };

  std::vector<MyScreenCaptureSourceInfo> infos;

  for (int i = 0; i < length; i++) {
    Napi::Value value = array.Get(i);

    if (value.IsObject()) {
      Napi::Object objectValue = value.As<Napi::Object>();
      Napi::Value sourceId = objectValue.Get("sourceId");
      
      if (!value.IsEmpty() && !value.IsNull() && !value.IsUndefined()) {
        std::string str_id = sourceId.ToString().Utf8Value();
        HWND curWnd = (HWND)std::stoll(str_id);
        DWORD dwProcessId;
        GetWindowThreadProcessId(curWnd, &dwProcessId);

        HANDLE handle = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, dwProcessId);

        FILETIME createTime, exitTime, kernelTime, userTime;
        if (GetProcessTimes(handle, &createTime, &exitTime, &kernelTime, &userTime))
        {
          ULARGE_INTEGER startTime;
            startTime.LowPart = createTime.dwLowDateTime;
            startTime.HighPart = createTime.dwHighDateTime;

            ULONGLONG unixTime = (startTime.QuadPart - 116444736000000000) / 10000000;

            MyScreenCaptureSourceInfo myInfo;
            myInfo.coreInfo = objectValue;
            myInfo.processId = dwProcessId;
            myInfo.processStartUnixTime = unixTime;

            infos.emplace_back(myInfo);
        }

        CloseHandle(handle);
      } 
    }
  }

  std::sort(infos.begin(), infos.end(), [](const MyScreenCaptureSourceInfo& one, const MyScreenCaptureSourceInfo& two) {
    if (one.processId != two.processId) {
      return one.processStartUnixTime > two.processStartUnixTime;
    }
    else {
      return one.processId > two.processId;
    }
  });

  Napi::Array ret_array = Napi::Array::New(env);

  for(int i = 0; i < infos.size(); ++i) {
    ret_array.Set(ret_array.Length(), infos[i].coreInfo);
  }

  return ret_array;
}

Napi::Object Init(Napi::Env env, Napi::Object exports)
{
  exports.Set(
      Napi::String::New(env, "getWindowsList"), // key
      Napi::Function::New(env, getWindowsList)  // value
  );
  return exports;
}

NODE_API_MODULE(VincentAddon, Init)