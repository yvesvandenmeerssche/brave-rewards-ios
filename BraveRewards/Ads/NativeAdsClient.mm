/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <iostream>

#import "NativeAdsClient.h"
#import "BATCommonOperations.h"
#import "BATBraveAds+Private.h"

@class BATBraveAds;

// Simply for pulling the NSBundle
@interface _BATBundleClass : NSObject
@end
@implementation _BATBundleClass
@end

class LogStreamImpl : public ads::LogStream {
public:
  LogStreamImpl(
                    const char* file,
                    const int line,
                    const ads::LogLevel log_level) {
    std::map<ads::LogLevel, std::string> map {
      {ads::LOG_ERROR, "ERROR"},
      {ads::LOG_WARNING, "WARNING"},
      {ads::LOG_INFO, "INFO"}
    };
    
    log_message_ = map[log_level] + ": in " + file + " on line "
    + std::to_string(line) + ": ";
  }
  
  std::ostream& stream() override {
    std::cout << std::endl << log_message_;
    return std::cout;
  }
  
private:
  std::string log_message_;
  
  // Not copyable, not assignable
  LogStreamImpl(const LogStreamImpl&) = delete;
  LogStreamImpl& operator=(const LogStreamImpl&) = delete;
};

namespace ads {
  NativeAdsClient::NativeAdsClient(BATBraveAds *objcAds, const std::string& applicationVersion)
    : objcAds(objcAds),
      common([[BATCommonOperations alloc] initWithStoragePath:@"brave_ads"]),
      ads(Ads::CreateInstance(this)),
      applicationVersion(applicationVersion) {
  };
  
  NativeAdsClient::~NativeAdsClient() {
    objcAds = nil;
    common = nil;
  }
  
  void NativeAdsClient::Initialize() {
    ads->Initialize();
  }
  
  // Should return true if Brave Ads is enabled otherwise returns false
  bool NativeAdsClient::IsAdsEnabled() const {
    return isEnabled;
  }
  
  // Should return the operating system's locale, i.e. en, en_US or en_GB.UTF-8
  const std::string NativeAdsClient::GetAdsLocale() const {
    return std::string([NSLocale currentLocale].localeIdentifier.UTF8String);
  }
  
  // Should return the number of ads that can be shown per hour
  uint64_t NativeAdsClient::GetAdsPerHour() const {
    return adsPerHour;
  }
  
  // Should return the number of ads that can be shown per day
  uint64_t NativeAdsClient::GetAdsPerDay() const {
    return adsPerDay;
  }
  
  // Sets the idle threshold specified in seconds, for how often OnIdle or
  // OnUndle should be called
  void NativeAdsClient::SetIdleThreshold(const int threshold) {
    idleThreshold = threshold;
  }
  
  // Should return true if there is a network connection otherwise returns false
  bool NativeAdsClient::IsNetworkConnectionAvailable() {
    return isNetworkConnectivityAvailable;
  }
  
  // Should get information about the client
  void NativeAdsClient::GetClientInfo(ClientInfo* info) const {
    info->platform = IOS;
  }
  
  // Should return a list of supported User Model locales
  const std::vector<std::string> NativeAdsClient::GetLocales() const {
    std::vector<std::string> locales = { "en", "fr", "de" };
    return locales;
  }
  
  // Should load the User Model for the specified locale, user models are a
  // dependency of the application and should be bundled accordingly, the
  // following file structure could be used:
  void NativeAdsClient::LoadUserModelForLocale(const std::string& locale, OnLoadCallback callback) const {
    const auto bundle = [NSBundle bundleForClass:[_BATBundleClass class]];
    const auto localeKey = [[[NSString stringWithUTF8String:locale.c_str()] substringToIndex:2] lowercaseString];
    const auto path = [[bundle pathForResource:@"locales" ofType:nil]
                       stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/user_model.json", localeKey]];
    if (!path || path.length == 0) {
      callback(FAILED, "");
      return;
    }
    
    NSError *error = nil;
    const auto contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!contents || error) {
      callback(FAILED, "");
      return;
    }
    callback(SUCCESS, std::string(contents.UTF8String));
  }
  
  // Should generate return a v4 UUID
  const std::string NativeAdsClient::GenerateUUID() const {
    return [common generateUUID];
  }
  
  // Should return true if the browser is in the foreground otherwise returns
  // false
  bool NativeAdsClient::IsForeground() const {
    return UIApplication.sharedApplication.applicationState == UIApplicationStateActive;
  }
  
  // Should return true if the operating system supports notifications otherwise
  // returns false
  bool NativeAdsClient::IsNotificationsAvailable() const {
    return true;
  }
  
  // Should show a notification
  void NativeAdsClient::ShowNotification(std::unique_ptr<NotificationInfo> info) {
    const auto& notification = info.get();
    if (notification != nullptr) {
      [objcAds showNotification:*notification];
    }
  }
  
  // Should notify that the catalog issuers have changed
  void NativeAdsClient::SetCatalogIssuers(std::unique_ptr<IssuersInfo> info) {
    // TODO: Add implementation
  }
  
  // Should be called to inform Confirmations that an ad was sustained
  void NativeAdsClient::ConfirmAd(std::unique_ptr<NotificationInfo> info) {
    // TODO: Add implementation
  }
  
  // Should create a timer to trigger after the time offset specified in
  // seconds. If the timer was created successfully a unique identifier should
  // be returned, otherwise returns 0
  uint32_t NativeAdsClient::SetTimer(const uint64_t time_offset) {
    return [common createTimerWithOffset:time_offset timerFired:^(uint32_t timer_id) {
      // If this object dies, common will get nil'd out
      if (common != nil) {
        ads->OnTimer(timer_id);
      }
    }];
  }
  
  // Should destroy the timer associated with the specified timer identifier
  void NativeAdsClient::KillTimer(uint32_t timer_id) {
    [common removeTimerWithID:timer_id];
  }
  
  // Should start a URL request
  void NativeAdsClient::URLRequest(const std::string& url,
                                   const std::vector<std::string>& headers,
                                   const std::string& content,
                                   const std::string& content_type,
                                   const URLRequestMethod method,
                                   URLRequestCallback callback) {
    std::map<ads::URLRequestMethod, std::string> methodMap {
      {ads::GET, "GET"},
      {ads::POST, "POST"},
      {ads::PUT, "PUT"}
    };
    return [common loadURLRequest:url headers:headers content:content content_type:content_type method:methodMap[method] callback:^(int statusCode, const std::string &response, const std::map<std::string, std::string> &headers) {
      callback(statusCode, response, headers);
    }];
  }
  
  // Should save a value to persistent storage
  void NativeAdsClient::Save(const std::string& name, const std::string& value, OnSaveCallback callback) {
    if ([common saveContents:value name:name]) {
      callback(SUCCESS);
    } else {
      callback(FAILED);
    }
  }
  
  // Should save the bundle state to persistent storage
  void NativeAdsClient::SaveBundleState(std::unique_ptr<BundleState> state, OnSaveCallback callback) {
    bundleState.reset(state.release());
    if ([common saveContents:bundleState->ToJson() name:"bundle.json"]) {
      callback(SUCCESS);
    } else {
      callback(FAILED);
    }
  }
  
  // Should load a value from persistent storage
  void NativeAdsClient::Load(const std::string& name, OnLoadCallback callback) {
    const auto contents = [common loadContentsFromFileWithName:name];
    if (contents.empty()) {
      callback(FAILED, "");
    } else {
      callback(SUCCESS, contents);
    }
  }
  
  // Should load a JSON schema from persistent storage, schemas are a dependency
  // of the application and should be bundled accordingly
  const std::string NativeAdsClient::LoadJsonSchema(const std::string& name) {
    const auto bundle = [NSBundle bundleForClass:[_BATBundleClass class]];
    const auto path = [bundle pathForResource:[NSString stringWithUTF8String:name.c_str()] ofType:nil];
    if (!path || path.length == 0) {
      return "";
    }
    NSError *error = nil;
    const auto contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!contents || error) {
      return "";
    }
    return std::string(contents.UTF8String);
  }
  
  // Should load the sample bundle from persistent storage
  void NativeAdsClient::LoadSampleBundle(OnLoadSampleBundleCallback callback) {
    const auto bundle = [NSBundle bundleForClass:[_BATBundleClass class]];
    const auto path = [bundle pathForResource:@"sample_bundle" ofType:@"json"];
    if (!path || path.length == 0) {
      callback(FAILED, "");
      return;
    }
    NSError *error = nil;
    const auto contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!contents || error) {
      callback(FAILED, "");
      return;
    }
    callback(SUCCESS, std::string(contents.UTF8String));
  }
  
  // Should reset a previously saved value, i.e. remove the file from persistent
  // storage
  void NativeAdsClient::Reset(const std::string& name, OnResetCallback callback) {
    if ([common removeFileWithName:name]) {
      callback(SUCCESS);
    } else {
      callback(FAILED);
    }
  }
  
  // Should get ads for the specified region and category from the previously
  // persisted bundle state
  void NativeAdsClient::GetAds(const std::string& category, OnGetAdsCallback callback) {
    auto categories = bundleState->categories.find(category);
    if (categories == bundleState->categories.end()) {
      callback(FAILED, category, {});
      return;
    }
    
    callback(SUCCESS, category, categories->second);
  }
  
  // Should log an event to persistent storage however as events may be queued
  // they need an event name and timestamp adding as follows, replacing ... with
  // the value of the "json" parameter:
  //
  // {
  //   "time": "2018-11-19T15:47:43.634Z",
  //   "eventName": "Event logged",
  //   ...
  // }
  void NativeAdsClient::EventLog(const std::string& json) {
  }
  
  // Should log diagnostic information
  std::unique_ptr<LogStream> NativeAdsClient::Log(const char* file, const int line, const LogLevel log_level) const {
    return std::make_unique<LogStreamImpl>(file, line, log_level);
  }
}
