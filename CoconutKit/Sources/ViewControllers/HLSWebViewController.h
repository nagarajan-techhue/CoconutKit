//
//  HLSWebViewController.h
//  CoconutKit
//
//  Created by Cédric Luthi on 02.03.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSViewController.h"

/**
 * A web browser with standard features (navigation buttons, link sharing, etc.)
 *
 * Designated initializer: -initWithRequest:
 */
@interface HLSWebViewController : HLSViewController <MFMailComposeViewControllerDelegate, UIWebViewDelegate>

/**
 * Create the browser using the specified request
 */
- (id)initWithRequest:(NSURLRequest *)request;

/**
 * The initial request
 */
@property (nonatomic, readonly, retain) NSURLRequest *request;

/**
 * A file URL pointing to an html file that is displayed when a connection error occurs
 *
 * If an html element with id="localizedErrorDescription" is present, its content is replaced with a localized description of the error that occured
 * A default template which looks like the Safari error page is provided.
 *
 * This property must be set before the view is loaded.
 */
@property (nonatomic, retain) NSURL *errorTemplateURL;

@end
