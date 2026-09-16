//
//  TurboShortcuts.mm
//  
//
//  Created by Rupesh Chaudhari.
//
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TurboShortcuts, NSObject)

RCT_EXTERN_METHOD(setShortcuts:(NSArray *)shortcuts
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(addShortcut:(NSDictionary *)shortcut
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(removeShortcut:(NSString *)id
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(clearShortcuts:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getShortcuts:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN__BLOCKING_SYNCHRONOUS_METHOD(getLaunchShortcut)

RCT_EXTERN__BLOCKING_SYNCHRONOUS_METHOD(getMaxShortcuts)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
