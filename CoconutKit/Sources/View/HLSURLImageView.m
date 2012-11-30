//
//  HLSURLImageView.m
//  CoconutKit
//
//  Created by Samuel Défago on 09.05.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSURLImageView.h"

#import "HLSAnimation.h"
#import "HLSLayerAnimationStep.h"
#import "HLSLogger.h"
#import "HLSZeroingWeakRef.h"

@interface HLSURLImageView ()

+ (NSCache *)sharedImageCache;

- (void)hlsURLImageViewInit;

@property (nonatomic, retain) HLSZeroingWeakRef *connectionZeroingWeakRef;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) HLSAnimation *loadingAnimation;

- (void)startLoadingAnimation:(BOOL)animated;
- (void)stopLoadingAnimation:(BOOL)animated;

- (UIImage *)defaultEmptyImage;

@end

@implementation HLSURLImageView

#pragma mark Class methods

+ (NSCache *)sharedImageCache
{
    static NSCache *s_instance = nil;
    static BOOL s_created = NO;
    if (! s_created) {
        // NSCache is available starting with iOS 4
        if (NSClassFromString(@"NSCache")) {
            s_instance = [[NSCache alloc] init];
        }
        else {
            HLSLoggerWarn(@"The image cache is available for iOS 4 and above only");
        }
        s_created = YES;
    }
    return s_instance;
}

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self hlsURLImageViewInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsURLImageViewInit];
    }
    return self;
}

- (void)hlsURLImageViewInit
{   
    self.backgroundColor = [UIColor clearColor];
        
    self.imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.imageView];
    
    self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.activityIndicatorView.alpha = 0.f;
    [self.activityIndicatorView startAnimating];
    [self addSubview:self.activityIndicatorView];
    
    HLSLayerAnimation *layerAnimation11 = [HLSLayerAnimation animation];
    [layerAnimation11 addToOpacity:1.f];
    HLSLayerAnimationStep *animationStep1 = [HLSLayerAnimationStep animationStep];
    [animationStep1 addLayerAnimation:layerAnimation11 forView:self.activityIndicatorView];    
    self.loadingAnimation = [HLSAnimation animationWithAnimationStep:animationStep1];
}

- (void)dealloc
{
    self.connectionZeroingWeakRef = nil;
    self.imageView = nil;
    self.emptyImage = nil;
    self.activityIndicatorView = nil;
    self.loadingAnimation = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize connectionZeroingWeakRef = _connectionZeroingWeakRef;

@dynamic image;

- (UIImage *)image
{
    return self.imageView.image;
}

@synthesize imageView = _imageView;

@synthesize emptyImage = _emptyImage;

@synthesize activityIndicatorView = _activityIndicatorView;

@synthesize loadingAnimation = _loadingAnimation;

- (void)setContentMode:(UIViewContentMode)contentMode
{
    self.imageView.contentMode = contentMode;
}

- (UIViewContentMode)contentMode
{
    return self.imageView.contentMode;
}

#pragma mark Downloading images

- (void)loadWithRequest:(NSURLRequest *)request
{
    // Cancel any running connection
    HLSURLConnection *connection = self.connectionZeroingWeakRef.object;
    if (connection) {
        [connection cancel];
    }
    
    self.imageView.image = self.emptyImage ?: [self defaultEmptyImage];
    
    // If no request, done
    if (! request) {
        return;
    }
    
    // Find if the image is already available from the cache
    UIImage *image = [[HLSURLImageView sharedImageCache] objectForKey:[request URL]];
    if (image) {
        self.imageView.image = image;
        return;
    }
    
    [self startLoadingAnimation:YES];
        
    // Create a new connection
    connection = [HLSURLConnection connectionWithRequest:request];
    connection.delegate = self;
    
    // Use a zeroing weak ref. It will be automatically nilled when the connection ends
    self.connectionZeroingWeakRef = [[[HLSZeroingWeakRef alloc] initWithObject:connection] autorelease];
    
    // The connection is scheduled with the NSRunLoopCommonModes run loop mode to allow connection events (i.e. 
    // image assignment when the download is complete) also when scrolling occurs (which is quite common when image 
    // views are used within table view cells)
    [connection startWithRunLoopMode:NSRunLoopCommonModes];
}

#pragma mark HLSURLConnectionDelegate protocol implementation

- (void)connectionDidFinishLoading:(HLSURLConnection *)connection
{
    UIImage *image = [UIImage imageWithData:[connection data]];
    [[HLSURLImageView sharedImageCache] setObject:image forKey:[connection.request URL]];
    
    self.imageView.image = image;
    
    [self stopLoadingAnimation:YES];
}

- (void)connection:(HLSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopLoadingAnimation:YES];
}

- (void)connectionDidCancel:(HLSURLConnection *)connection
{
    [self stopLoadingAnimation:NO];
}

#pragma mark View lifecycle

- (void)willMoveToWindow:(UIWindow *)window
{
    // When removed from display, stop downloading if a connection object is attached to the image view
    if (! window) {
        HLSURLConnection *connection = self.connectionZeroingWeakRef.object;
        [connection cancel];        
    }
}

#pragma mark Animations

- (void)startLoadingAnimation:(BOOL)animated
{
    [self.loadingAnimation playAnimated:YES];
}

- (void)stopLoadingAnimation:(BOOL)animated
{    
    HLSAnimation *reverseLoadingAnimation = [self.loadingAnimation reverseAnimation];
    [reverseLoadingAnimation playAnimated:animated];
}

#pragma mark Images

- (UIImage *)defaultEmptyImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor grayColor] setStroke];
    roundedRectanglePath.lineWidth = 2.5f;
    CGFloat roundedRectanglePattern[] = {5.f, 5.f, 5.f, 5.f};
    [roundedRectanglePath setLineDash:roundedRectanglePattern count:4 phase:0.f];
    [roundedRectanglePath stroke];
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIGraphicsEndImageContext();
    return image;
}

@end
