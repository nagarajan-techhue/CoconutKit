//
//  HLSApplicationPreloader.h
//  CoconutKit
//
//  Created by Samuel Défago on 02.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Collects the code which can be executed right after an application has started so that perceived performance can be
 * increased
 */
@interface HLSApplicationPreloader : NSObject <UIWebViewDelegate> {
@private
    UIApplication *_application;
}

/**
 * Call this method as soon as possible if you want to enable UIWebView preloading. For simplicity you should use the
 * HLSEnableWebViewPreloading convenience macro instead (see HLSOptionalFeatures.h)
 */
+ (void)enableForWebView;

/**
 * Call this method as soon as possible if you want to enable NSURLCache preloading. For simplicity you should use the
 * HLSEnableURLCachePreloading convenience macro instead (see HLSOptionalFeatures.h)
 */
+ (void)enableForURLCache;

@end
