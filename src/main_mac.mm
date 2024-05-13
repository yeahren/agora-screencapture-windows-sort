#include <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h>
#include <napi.h>
#include <objc/NSObjCRuntime.h>
#include <string>
#include <iostream>
#include <map>
#include <vector>
#include <libproc.h>

struct MyWindowInfo {
    Napi::Object    coreObject;
    NSInteger       windowNumber;
    NSInteger       windowOwnerPID;
    uint64_t        startTime;
    bool            isScreen;
};

std::map<NSInteger, MyWindowInfo> getAllWindowsInfoMap() {
    std::map<NSInteger, MyWindowInfo> retMap;
    
    struct proc_taskallinfo pinfo;
    memset(&pinfo, 0, sizeof(struct proc_taskallinfo));

    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionAll | kCGWindowListExcludeDesktopElements , kCGNullWindowID);

    if (windowList != nullptr) {
        for (NSMutableDictionary *entry in (__bridge NSArray *)windowList) {
            NSInteger windowOwnerPID = [[entry objectForKey:(id)kCGWindowOwnerPID] integerValue];
            NSInteger windowNumber = [[entry objectForKey:(id)kCGWindowNumber] integerValue];
            
            int ret = proc_pidinfo(windowOwnerPID, PROC_PIDTASKALLINFO, 0, &pinfo, sizeof(struct proc_taskallinfo));

            if (ret > 0) {
                MyWindowInfo info;
                info.windowNumber = windowNumber;
                info.windowOwnerPID = windowOwnerPID;
                info.startTime = pinfo.pbsd.pbi_start_tvsec;
                info.isScreen = false;

                retMap[windowNumber] = info;
            }
        }

        CFRelease(windowList);
    }
        
    return retMap;
}


Napi::Object getWindowsList(const Napi::CallbackInfo &info)
{
    Napi::Env env = info.Env();

    int argc = info.Length();
    if (argc != 1) {
        Napi::TypeError::New(env, "Invalid number of arguments")
            .ThrowAsJavaScriptException();

        return Napi::Array::New(env, 0);
    }
    
    if (!info[0].IsArray()) {
        Napi::TypeError::New(env, "Argument should be an Array")
            .ThrowAsJavaScriptException();

        return Napi::Array::New(env, 0);
    }

    std::map<NSInteger, MyWindowInfo> allInfosMap = getAllWindowsInfoMap();
    std::vector<MyWindowInfo> infos;
    
    Napi::Array array = info[0].As<Napi::Array>();
    int length = array.Length();

    for (int i = 0; i < length; i++) {
        Napi::Value value = array.Get(i);

        if (value.IsObject()) {
            Napi::Object objectValue = value.As<Napi::Object>();
            Napi::Value sourceId = objectValue.Get("sourceId");
            
            if (!value.IsEmpty() && !value.IsNull() && !value.IsUndefined()) {
                std::string str_id = sourceId.ToString().Utf8Value();
                NSInteger curWnd = (NSInteger)std::stoll(str_id);

                auto pIt = allInfosMap.find(curWnd);

                if (pIt != allInfosMap.end()) {
                    pIt->second.coreObject = objectValue;

                    MyWindowInfo info;
                    info.coreObject = objectValue;
                    info.startTime = pIt->second.startTime;
                    info.windowNumber = pIt->second.windowNumber;
                    info.windowOwnerPID = pIt->second.windowOwnerPID;
                    info.isScreen = false;

                    infos.emplace_back(info);
                }
                else {
                    MyWindowInfo info;
                    info.coreObject = objectValue;
                    info.isScreen = true;
                    info.windowNumber = curWnd;

                    infos.emplace_back(info);
                }
            }
        }
        
    }

    std::sort(infos.begin(), infos.end(), [](const MyWindowInfo& one, const MyWindowInfo& two) {
        if (one.isScreen && two.isScreen) {
            return one.windowNumber < two.windowNumber;
        }

        if (one.isScreen && !two.isScreen) {
            return true;
        }

        if (!one.isScreen && two.isScreen) {
            return false;
        }

        if (!one.isScreen && !two.isScreen) {
                if (one.windowOwnerPID != two.windowOwnerPID) {
                return one.startTime > two.startTime;
            }
            else {
                return one.windowNumber > two.windowNumber;
            }
        }
    });

    Napi::Array ret_array = Napi::Array::New(env);

    for(size_t i = 0; i < infos.size(); ++i) {
        ret_array.Set(ret_array.Length(), infos[i].coreObject);
    }

  return ret_array;

};

Napi::Object init(Napi::Env env, Napi::Object exports)
{
  exports.Set(
      Napi::String::New(env, "getWindowsList"),
      Napi::Function::New(env, getWindowsList));
  return exports;
};

NODE_API_MODULE(SortWindowsAddon, init);