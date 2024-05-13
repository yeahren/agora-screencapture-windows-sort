#include <napi.h>
#include <Cocoa/Cocoa.h>
#include <string>

unsigned long getStringLength(NSString *content){
  NSUInteger maxLength = [content lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  return maxLength;
}

napi_value getWindowsList(const Napi::CallbackInfo &info)
{
  Napi::Env env = info.Env();
  CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
  napi_value result;
  napi_create_array(env, &result);
  int i = 0;
  for (NSMutableDictionary *entry in (__bridge NSArray *)windowList)
  {
    napi_value ele;
    napi_create_object(env, &ele);
    // 窗口Order
     NSInteger windowOrder = [[entry objectForKey:(id)kCGWindowLayer] integerValue];
     NSInteger windowOwnerPID = [[entry objectForKey:(id)kCGWindowOwnerPID] integerValue];
     NSInteger windowNumber = [[entry objectForKey:(id)kCGWindowNumber] integerValue];
     NSString *windowName = [entry objectForKey:(__bridge NSString *) kCGWindowName];
     NSString *windowOwnerName = [entry objectForKey:(__bridge NSString *) kCGWindowOwnerName];
     NSString *windowTitleName ;

    //  NSLog(@"Window - Name: %@, length: %lu , %lu ", windowName, [windowName length], getStringLength(windowName));
    //  NSLog(@"Window - windowOwnerName: %@, length: %lu , %lu", windowOwnerName, [windowOwnerName length], getStringLength(windowOwnerName));

     if(windowName && ![windowName isEqualToString:@""]){
      windowTitleName = [NSString stringWithFormat:@"%@-%@", windowName, windowOwnerName];
     }else{
      windowTitleName =  windowOwnerName;
     }
     NSDictionary *windowBounds = [entry objectForKey:( __bridge NSDictionary *) kCGWindowBounds];
     NSInteger windowX = [[windowBounds objectForKey:@"X"] integerValue];
     NSInteger windowY = [[windowBounds objectForKey:@"Y"] integerValue];
     NSInteger windowWidth = [[windowBounds objectForKey:@"Width"] integerValue];
     NSInteger windowHeight = [[windowBounds objectForKey:@"Height"] integerValue];
    napi_value order;
    napi_value nWindowTitleName;
    napi_value windowPID;
    napi_value nWindowNumber;
    napi_value nWindowName;
    napi_value nWindowOwnerName;
    napi_value nWindowX;
    napi_value nWindowY;
    napi_value nWindowWidth;
    napi_value nWindowHeight;
    napi_create_int32(env,windowOrder, &order);
    napi_create_int32(env,windowOwnerPID, &windowPID);
    napi_create_int32(env,windowNumber, &nWindowNumber);
    napi_create_string_utf8(env,[windowTitleName UTF8String],getStringLength(windowTitleName), &nWindowTitleName);
    napi_create_string_utf8(env,[windowName UTF8String],getStringLength(windowName) , &nWindowName);
    napi_create_string_utf8(env,[windowOwnerName UTF8String],getStringLength(windowOwnerName), &nWindowOwnerName);
    napi_create_int32(env,windowX, &nWindowX);
    napi_create_int32(env,windowY, &nWindowY);
    napi_create_int32(env,windowWidth, &nWindowWidth);
    napi_create_int32(env,windowHeight, &nWindowHeight);
    napi_set_named_property(env, ele, "windowOrder" , order);
    napi_set_named_property(env, ele, "windowOwnerName" , nWindowOwnerName);
    napi_set_named_property(env, ele, "windowName" , nWindowName);
    napi_set_named_property(env, ele, "windowTitleName" , nWindowTitleName);
    napi_set_named_property(env, ele, "windowPID" , windowPID);
    napi_set_named_property(env, ele, "windowNumber" , nWindowNumber);
    napi_set_named_property(env, ele, "windowX" , nWindowX);
    napi_set_named_property(env, ele, "windowY" , nWindowY);
    napi_set_named_property(env, ele, "windowWidth" , nWindowWidth);
    napi_set_named_property(env, ele, "windowHeight" , nWindowHeight);
    napi_set_element(env, result,i, ele);
    i++;
  }

  CFRelease(windowList);
  return result;
};

Napi::Object init(Napi::Env env, Napi::Object exports)
{
  exports.Set(
      Napi::String::New(env, "getWindowsList"),
      Napi::Function::New(env, getWindowsList));
  return exports;
};

NODE_API_MODULE(VincentAddon, init);