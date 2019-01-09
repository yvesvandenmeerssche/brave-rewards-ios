/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(BraveAdsDelegate)
@protocol BATNativeAdsDelegate <NSObject>

//- (void)nativeAds:(BATNativeAds *)nativeAds shouldShow

@end

NS_SWIFT_NAME(BraveAds)
@interface BATBraveAds : NSObject

/// Whether or not Brave Ads is enabled
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/// The max number of ads the user can see in an hour
@property (nonatomic, assign) NSInteger numberOfAllowableAdsPerHour;

/// The max number of ads the user can see in a day
@property (nonatomic, assign) NSInteger numberOfAllowableAdsPerDay;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAppVersion:(NSString *)version;
/// Create an instance of brave native ads and set its enabled state right away
- (instancetype)initWithAppVersion:(NSString *)version enabled:(BOOL)enabled NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END