//
//  HLSWebViewController.m
//  CoconutKit
//
//  Created by Cédric Luthi on 02.03.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSWebViewController.h"

#import "HLSActionSheet.h"
#import "HLSAutorotation.h"
#import "HLSNotifications.h"
#import "NSBundle+HLSDynamicLocalization.h"
#import "NSBundle+HLSExtensions.h"
#import "NSError+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"
#import "NSString+HLSExtensions.h"

@interface HLSWebViewController ()

@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURL *currentURL;
@property (nonatomic, retain) NSError *currentError;

@property (nonatomic, retain) UIImage *refreshImage;

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *goBackBarButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *goForwardBarButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation HLSWebViewController

#pragma mark Object creation and destruction

- (id)initWithRequest:(NSURLRequest *)request
{
    if ((self = [super initWithBundle:[NSBundle coconutKitBundle]])) {
        self.request = request;
        self.errorTemplateURL = [[NSBundle coconutKitBundle] URLForResource:@"HLSWebViewControllerErrorTemplate" withExtension:@"html"];
    }
    return self;
}

- (void)dealloc
{
    self.request = nil;
    self.currentURL = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.webView = nil;
    self.toolbar = nil;
    self.goBackBarButtonItem = nil;
    self.goForwardBarButtonItem = nil;
    self.refreshBarButtonItem = nil;
    self.actionBarButtonItem = nil;
    self.activityIndicator = nil;
    self.refreshImage = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshImage = self.refreshBarButtonItem.image;
    
    // Start with the initial URL when the view gets (re)loaded
    self.currentURL = nil;
    
    self.webView.delegate = self;
    [self.webView loadRequest:self.request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateInterface];
    [self layoutForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else {
        return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskAll;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self layoutForInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    [self updateTitle];
}

#pragma mark Layout and display

- (void)layoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Adjust the toolbar height depending on the screen orientation
    CGSize toolbarSize = [self.toolbar sizeThatFits:self.view.bounds.size];
    self.toolbar.frame = (CGRect){CGPointMake(0.f, CGRectGetHeight(self.view.bounds) - toolbarSize.height), toolbarSize};
    self.webView.frame = (CGRect){CGPointZero, CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetMinY(self.toolbar.frame))};
    
    // Center UI elements accordingly
    self.activityIndicator.center = CGPointMake(self.activityIndicator.center.x, CGRectGetMidY(self.toolbar.frame));
}

- (void)updateInterface
{
    self.goBackBarButtonItem.enabled = self.webView.canGoBack;
    self.goForwardBarButtonItem.enabled = self.webView.canGoForward;
    self.refreshBarButtonItem.enabled = ! self.webView.loading;
    self.refreshBarButtonItem.image = self.webView.loading ? nil : self.refreshImage;
    self.actionBarButtonItem.enabled = ! self.webView.loading && self.currentURL;
    
    [self updateTitle];
}

- (void)updateTitle
{
    if (self.currentURL) {
        self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    else {
        self.title = NSLocalizedStringFromTableInBundle(@"Untitled", @"Localizable", [NSBundle coconutKitBundle], nil);
    }
}

- (void) setErrorTemplateURL:(NSURL *)errorTemplateURL
{
    if (_errorTemplateURL == errorTemplateURL) {
        return;
    }
    
    if (![errorTemplateURL isFileURL]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The error template URL must be a file URL." userInfo:nil];
    }
    
    [_errorTemplateURL release];
    _errorTemplateURL = [errorTemplateURL retain];
}

#pragma mark MFMailComposeViewControllerDelegate protocol implementation

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark UIWebViewDelegate protocol implementation

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[HLSNotificationManager sharedNotificationManager] notifyBeginNetworkActivity];
    [self.activityIndicator startAnimating];
    
    [self updateInterface];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    [self.activityIndicator stopAnimating];
    
    // A new page has been displayed. Remember its URL
    self.currentURL = [self.webView.request URL];
    
    [self updateInterface];
    
    if (self.currentError) {
        NSString *escapedErrorDescription = [[self.currentError localizedDescription] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        NSString *replaceErrorJavaScript = [NSString stringWithFormat:@"document.getElementById('localizedErrorDescription').innerHTML = '%@'", escapedErrorDescription];
        [webView stringByEvaluatingJavaScriptFromString:replaceErrorJavaScript];
    }
    
    self.currentError = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[HLSNotificationManager sharedNotificationManager] notifyEndNetworkActivity];
    [self.activityIndicator stopAnimating];
    
    self.currentError = error;
    
    [self updateInterface];
    
    if (![error hasCode:NSURLErrorCancelled withinDomain:NSURLErrorDomain]) {
        [webView loadRequest:[NSURLRequest requestWithURL:self.errorTemplateURL]];
    }
}

#pragma mark Action callbacks

- (IBAction)goBack:(id)sender
{
    [self.webView goBack];
    [self updateInterface];
}

- (IBAction)goForward:(id)sender
{
    [self.webView goForward];
    [self updateInterface];
}

- (IBAction)refresh:(id)sender
{
    NSURL *webViewURL = [self.webView.request URL];
    
    // Reload the currently displayed page (if any)
    if ([[webViewURL absoluteString] isFilled] && ![webViewURL.path isEqualToString:self.errorTemplateURL.path]) {
        [self.webView loadRequest:self.webView.request];
    }
    // Reload the start page
    else {
        [self.webView loadRequest:self.request];
    }
    
    [self updateInterface];
}

- (IBAction)displayActionSheet:(id)sender
{    
    HLSActionSheet *actionSheet = [[[HLSActionSheet alloc] init] autorelease];
    actionSheet.title = [self.currentURL absoluteString];
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Open in Safari", @"Localizable", [NSBundle coconutKitBundle], nil)
                             target:self
                             action:@selector(openInSafari:)];
    if ([MFMailComposeViewController canSendMail]) {
        [actionSheet addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Mail Link", @"Localizable", [NSBundle coconutKitBundle], nil)
                                 target:self
                                 action:@selector(mailLink:)];
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [actionSheet addCancelButtonWithTitle:HLSLocalizedStringFromUIKit(@"Cancel") 
                                       target:nil
                                       action:NULL];
    }
    [actionSheet showFromBarButtonItem:self.actionBarButtonItem animated:YES];
}

- (void)openInSafari:(id)sender
{
    [[UIApplication sharedApplication] openURL:[self.webView.request URL]];
}

- (void)mailLink:(id)sender
{
    MFMailComposeViewController *mailComposeViewController = [[[MFMailComposeViewController alloc] init] autorelease];
    mailComposeViewController.mailComposeDelegate = self;
    [mailComposeViewController setSubject:self.title];
    [mailComposeViewController setMessageBody:[[self.webView.request URL] absoluteString] isHTML:NO];
    [self presentModalViewController:mailComposeViewController animated:YES];
}

@end
