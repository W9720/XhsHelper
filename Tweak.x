#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

// 声明全局变量
extern BOOL gWatermarkEnabled;
extern BOOL gSaveEnabled;
extern BOOL gHidePublishButton;
extern BOOL gHideMessageButton;
extern BOOL gHideHotButton;
extern BOOL gCustomTextEnabled;
extern NSMutableDictionary *gCustomTextRules;
extern BOOL gLivePhotoWatermarkEnabled;
extern BOOL gAutoReplyEnabled;
extern NSString *gAutoReplyText;
extern BOOL gCommentAutoReplyEnabled;
extern NSString *gCommentAutoReplyText;
extern BOOL gCustomFontEnabled;
extern NSString *gCustomFontName;

// 水印处理函数
void handleWatermarkRemoval(UIImage *image, void (^completion)(UIImage *processedImage)) {
    completion(image);
}

%group HideTabBarItems
%hook XYPHBottomBarContainerView

- (void)setHidden:(BOOL)hidden {
    %orig(NO);
}

%end
%end

%group HidePublishButton
%hook XYPHBottomBarContainerView

- (void)setHidden:(BOOL)hidden {
    %orig(NO);
}

- (UIView *)publishButton {
    UIView *original = %orig;
    if (original) {
        original.hidden = YES;
        original.userInteractionEnabled = NO;
        original.alpha = 0;
    }
    return original;
}

%end
%end

%group HideMessageButton
%hook XYPHBottomBarContainerView

- (UIView *)messageButton {
    UIView *original = %orig;
    if (original) {
        original.hidden = YES;
        original.userInteractionEnabled = NO;
        original.alpha = 0;
    }
    return original;
}

%end
%end

%group HideHotButton
%hook XYPHBottomBarContainerView

- (UIView *)hotButton {
    UIView *original = %orig;
    if (original) {
        original.hidden = YES;
        original.userInteractionEnabled = NO;
        original.alpha = 0;
    }
    return original;
}

%end
%end

%hook XYNoteBasicNoteModel

- (void)setWatermarkHidden:(BOOL)hidden {
    %orig(YES);
}

- (BOOL)watermarkHidden {
    return YES;
}

%end

%hook XYImageFeedViewController

- (void)viewDidLoad {
    %orig;
}

%end

%hook XYImageFeedView

- (void)setWatermarkViewHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYImageFeedWatermarkView

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
}

%end

%hook XYImageFeedWatermarkInfoView

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook UIImageView

- (void)setImage:(UIImage *)image {
    %orig;
}

%end

%hook XYNoteBasicCommentViewModel

- (void)setWatermarkHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYNoteBasicCommentView

- (void)setWatermarkViewHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook UIView

- (void)layoutSubviews {
    %orig;
    
    if (self.superview) {
        NSString *superviewClassName = NSStringFromClass([self.superview class]);
        
        if ([superviewClassName containsString:@"Watermark"]) {
            self.hidden = YES;
        }
        
        if ([self.accessibilityIdentifier containsString:@"watermark"] || 
            [self.accessibilityIdentifier containsString:@"水印"]) {
            self.hidden = YES;
        }
    }
}

%end

%hook UIViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    
    if ([self isKindOfClass:NSClassFromString(@"XYImageFeedViewController")]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIView *view = self.view;
            for (UIView *subview in view.subviews) {
                if ([NSStringFromClass([subview class]) containsString:@"Watermark"]) {
                    [subview setHidden:YES];
                }
            }
        });
    }
}

%end

%hook XYFeedPictureView

- (void)setWatermarkViewHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYFeedPictureWatermarkView

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYNoteBasicNoteViewController

- (void)viewDidLoad {
    %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIView *noteView = self.view;
        for (UIView *subview in noteView.subviews) {
            if ([NSStringFromClass([subview class]) containsString:@"Watermark"]) {
                [subview setHidden:YES];
            }
        }
    });
}

%end

%hook XYNoteBasicNoteView

- (void)setWatermarkViewHidden:(BOOL)hidden {
    %orig(YES);
}

- (void)layoutSubviews {
    %orig;
    
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass([subview class]) containsString:@"Watermark"]) {
            [subview setHidden:YES];
        }
    }
}

%end

%hook XYNoteBasicNoteCell

- (void)setWatermarkViewHidden:(BOOL)hidden {
    %orig(YES);
}

- (void)layoutSubviews {
    %orig;
    
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass([subview class]) containsString:@"Watermark"]) {
            [subview setHidden:YES];
        }
    }
}

%end

%hook XYNoteBasicCommentService

- (id)createNoteWithContent:(id)content images:(NSArray *)images completion:(void (^)(id note, NSError *error))completion {
    return %orig(content, images, completion);
}

%end

%hook XYNoteBasicDraftManager

- (id)createDraftWithContent:(id)content images:(NSArray *)images completion:(void (^)(id draft, NSError *error))completion {
    return %orig(content, images, completion);
}

%end

%hook XYNoteBasicNoteService

- (id)createNoteWithContent:(id)content images:(NSArray *)images completion:(void (^)(id note, NSError *error))completion {
    return %orig(content, images, completion);
}

%end

%hook XYNoteBasicNoteEditViewController

- (void)viewDidLoad {
    %orig;
}

%end

%hook XYNoteBasicNoteEditView

- (void)setWatermarkViewHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYNoteBasicNoteEditViewWatermark

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYNoteBasicNoteEditViewWatermarkInfo

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYNoteBasicNoteEditViewWatermarkContainer

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYNoteBasicNoteEditViewWatermarkPreview

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSetting

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingCell

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingView

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewController

- (void)viewDidLoad {
    %orig;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkHidden:(BOOL)hidden {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (BOOL)watermarkSettingView:(id)view shouldShowWatermark:(NSInteger)index {
    return NO;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkVisible:(BOOL)visible {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (BOOL)watermarkSettingView:(id)view shouldShowWatermarkAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkAlpha:(CGFloat)alpha {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkAlphaAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkFont:(id)font {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkFontAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkText:(NSString *)text {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSString *)watermarkSettingView:(id)view watermarkTextAtIndexPath:(NSIndexPath *)indexPath {
    return @"";
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkPosition:(CGPoint)position {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGPoint)watermarkSettingView:(id)view watermarkPositionAtIndexPath:(NSIndexPath *)indexPath {
    return CGPointZero;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkSize:(CGSize)size {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGSize)watermarkSettingView:(id)view watermarkSizeAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeZero;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkRotation:(CGFloat)rotation {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkRotationAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkColor:(UIColor *)color {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIColor *)watermarkSettingView:(id)view watermarkColorAtIndexPath:(NSIndexPath *)indexPath {
    return [UIColor clearColor];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkStyle:(NSInteger)style {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSInteger)watermarkSettingView:(id)view watermarkStyleAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTemplate:(id)template {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkTemplateAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkEnabled:(BOOL)enabled {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (BOOL)watermarkSettingView:(id)view watermarkEnabledAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkLocked:(BOOL)locked {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (BOOL)watermarkSettingView:(id)view watermarkLockedAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkAspectRatio:(CGFloat)aspectRatio {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkAspectRatioAtIndexPath:(NSIndexPath *)indexPath {
    return 1.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkOpacity:(CGFloat)opacity {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkOpacityAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkBlendMode:(CGBlendMode)blendMode {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGBlendMode)watermarkSettingView:(id)view watermarkBlendModeAtIndexPath:(NSIndexPath *)indexPath {
    return kCGBlendModeNormal;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkShadow:(NSShadow *)shadow {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSShadow *)watermarkSettingView:(id)view watermarkShadowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkBorder:(id)border {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkBorderAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkBackground:(id)background {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkBackgroundAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkGradient:(id)gradient {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkGradientAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkPattern:(id)pattern {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkPatternAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkImage:(UIImage *)image {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIImage *)watermarkSettingView:(id)view watermarkImageAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextAlignment:(NSTextAlignment)alignment {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSTextAlignment)watermarkSettingView:(id)view watermarkTextAlignmentAtIndexPath:(NSIndexPath *)indexPath {
    return NSTextAlignmentNatural;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextLineBreakMode:(NSLineBreakMode)lineBreakMode {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSLineBreakMode)watermarkSettingView:(id)view watermarkTextLineBreakModeAtIndexPath:(NSIndexPath *)indexPath {
    return NSLineBreakByWordWrapping;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextLineSpacing:(CGFloat)lineSpacing {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextLineSpacingAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextParagraphSpacing:(CGFloat)paragraphSpacing {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextParagraphSpacingAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextFirstLineHeadIndent:(CGFloat)indent {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextFirstLineHeadIndentAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextHeadIndent:(CGFloat)indent {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextHeadIndentAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextTailIndent:(CGFloat)indent {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextTailIndentAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextMinimumLineHeight:(CGFloat)height {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextMinimumLineHeightAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextMaximumLineHeight:(CGFloat)height {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextMaximumLineHeightAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextBaseWritingDirection:(NSWritingDirection)direction {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSWritingDirection)watermarkSettingView:(id)view watermarkTextBaseWritingDirectionAtIndexPath:(NSIndexPath *)indexPath {
    return NSWritingDirectionNatural;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextTransform:(CATransform3D)transform {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CATransform3D)watermarkSettingView:(id)view watermarkTextTransformAtIndexPath:(NSIndexPath *)indexPath {
    return CATransform3DIdentity;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextShadowOffset:(CGSize)offset {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGSize)watermarkSettingView:(id)view watermarkTextShadowOffsetAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeZero;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextShadowBlur:(CGFloat)blur {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextShadowBlurAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextShadowColor:(UIColor *)color {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIColor *)watermarkSettingView:(id)view watermarkTextShadowColorAtIndexPath:(NSIndexPath *)indexPath {
    return [UIColor clearColor];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextStrokeColor:(UIColor *)color {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIColor *)watermarkSettingView:(id)view watermarkTextStrokeColorAtIndexPath:(NSIndexPath *)indexPath {
    return [UIColor clearColor];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextStrokeWidth:(CGFloat)width {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextStrokeWidthAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextFillColor:(UIColor *)color {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIColor *)watermarkSettingView:(id)view watermarkTextFillColorAtIndexPath:(NSIndexPath *)indexPath {
    return [UIColor clearColor];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextKern:(CGFloat)kern {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextKernAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextTracking:(CGFloat)tracking {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextTrackingAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextStretching:(CGFloat)stretching {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextStretchingAtIndexPath:(NSIndexPath *)indexPath {
    return 1.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextUnderlineStyle:(NSUnderlineStyle)style {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSUnderlineStyle)watermarkSettingView:(id)view watermarkTextUnderlineStyleAtIndexPath:(NSIndexPath *)indexPath {
    return NSUnderlineStyleNone;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextUnderlineColor:(UIColor *)color {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIColor *)watermarkSettingView:(id)view watermarkTextUnderlineColorAtIndexPath:(NSIndexPath *)indexPath {
    return [UIColor clearColor];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextUnderlineWidth:(CGFloat)width {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextUnderlineWidthAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextStrikethroughStyle:(NSUnderlineStyle)style {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSUnderlineStyle)watermarkSettingView:(id)view watermarkTextStrikethroughStyleAtIndexPath:(NSIndexPath *)indexPath {
    return NSUnderlineStyleNone;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextStrikethroughColor:(UIColor *)color {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIColor *)watermarkSettingView:(id)view watermarkTextStrikethroughColorAtIndexPath:(NSIndexPath *)indexPath {
    return [UIColor clearColor];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextStrikethroughWidth:(CGFloat)width {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextStrikethroughWidthAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextObliqueness:(CGFloat)obliqueness {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextObliquenessAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextLigature:(NSInteger)ligature {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSInteger)watermarkSettingView:(id)view watermarkTextLigatureAtIndexPath:(NSIndexPath *)indexPath {
    return 1;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextGlyphInfo:(id)glyphInfo {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkTextGlyphInfoAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementCharacter:(unichar)character {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (unichar)watermarkSettingView:(id)view watermarkTextReplacementCharacterAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementString:(NSString *)string {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSString *)watermarkSettingView:(id)view watermarkTextReplacementStringAtIndexPath:(NSIndexPath *)indexPath {
    return @"";
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementImage:(UIImage *)image {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIImage *)watermarkSettingView:(id)view watermarkTextReplacementImageAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementView:(UIView *)view {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIView *)watermarkSettingView:(id)view watermarkTextReplacementViewAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementLayer:(CALayer *)layer {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CALayer *)watermarkSettingView:(id)view watermarkTextReplacementLayerAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementPath:(UIBezierPath *)path {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIBezierPath *)watermarkSettingView:(id)view watermarkTextReplacementPathAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementShape:(CAShapeLayer *)shape {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CAShapeLayer *)watermarkSettingView:(id)view watermarkTextReplacementShapeAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementGradient:(CAGradientLayer *)gradient {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CAGradientLayer *)watermarkSettingView:(id)view watermarkTextReplacementGradientAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementReplicator:(CAReplicatorLayer *)replicator {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CAReplicatorLayer *)watermarkSettingView:(id)view watermarkTextReplacementReplicatorAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementScroll:(CAScrollLayer *)scroll {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CAScrollLayer *)watermarkSettingView:(id)view watermarkTextReplacementScrollAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementDisplay:(CADisplayLink *)display {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CADisplayLink *)watermarkSettingView:(id)view watermarkTextReplacementDisplayAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementEmitter:(CAEmitterLayer *)emitter {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CAEmitterLayer *)watermarkSettingView:(id)view watermarkTextReplacementEmitterAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementVideo:(AVPlayerLayer *)video {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (AVPlayerLayer *)watermarkSettingView:(id)view watermarkTextReplacementVideoAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementAudio:(AVAudioPlayer *)audio {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (AVAudioPlayer *)watermarkSettingView:(id)view watermarkTextReplacementAudioAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementMedia:(AVPlayerItem *)media {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (AVPlayerItem *)watermarkSettingView:(id)view watermarkTextReplacementMediaAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementAsset:(AVAsset *)asset {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (AVAsset *)watermarkSettingView:(id)view watermarkTextReplacementAssetAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementURL:(NSURL *)url {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSURL *)watermarkSettingView:(id)view watermarkTextReplacementURLAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementData:(NSData *)data {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSData *)watermarkSettingView:(id)view watermarkTextReplacementDataAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementObject:(id)object {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkTextReplacementObjectAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementValue:(id)value {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkTextReplacementValueAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementKey:(NSString *)key {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSString *)watermarkSettingView:(id)view watermarkTextReplacementKeyAtIndexPath:(NSIndexPath *)indexPath {
    return @"";
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementKeys:(NSArray *)keys {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSArray *)watermarkSettingView:(id)view watermarkTextReplacementKeysAtIndexPath:(NSIndexPath *)indexPath {
    return @[];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementValues:(NSDictionary *)values {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSDictionary *)watermarkSettingView:(id)view watermarkTextReplacementValuesAtIndexPath:(NSIndexPath *)indexPath {
    return @{};
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementArray:(NSArray *)array {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSArray *)watermarkSettingView:(id)view watermarkTextReplacementArrayAtIndexPath:(NSIndexPath *)indexPath {
    return @[];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementDictionary:(NSDictionary *)dictionary {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSDictionary *)watermarkSettingView:(id)view watermarkTextReplacementDictionaryAtIndexPath:(NSIndexPath *)indexPath {
    return @{};
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementSet:(NSSet *)set {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSSet *)watermarkSettingView:(id)view watermarkTextReplacementSetAtIndexPath:(NSIndexPath *)indexPath {
    return [NSSet set];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementOrderedSet:(NSOrderedSet *)orderedSet {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSOrderedSet *)watermarkSettingView:(id)view watermarkTextReplacementOrderedSetAtIndexPath:(NSIndexPath *)indexPath {
    return [NSOrderedSet orderedSet];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementNumber:(NSNumber *)number {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSNumber *)watermarkSettingView:(id)view watermarkTextReplacementNumberAtIndexPath:(NSIndexPath *)indexPath {
    return @0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementBool:(BOOL)boolean {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (BOOL)watermarkSettingView:(id)view watermarkTextReplacementBoolAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementInt:(NSInteger)integer {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSInteger)watermarkSettingView:(id)view watermarkTextReplacementIntAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementFloat:(CGFloat)floatNumber {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGFloat)watermarkSettingView:(id)view watermarkTextReplacementFloatAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementDouble:(double)doubleNumber {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (double)watermarkSettingView:(id)view watermarkTextReplacementDoubleAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementLong:(long)longNumber {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (long)watermarkSettingView:(id)view watermarkTextReplacementLongAtIndexPath:(NSIndexPath *)indexPath {
    return 0L;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementLongLong:(long long)longLongNumber {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (long long)watermarkSettingView:(id)view watermarkTextReplacementLongLongAtIndexPath:(NSIndexPath *)indexPath {
    return 0LL;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUnsignedInt:(NSUInteger)unsignedInt {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSUInteger)watermarkSettingView:(id)view watermarkTextReplacementUnsignedIntAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUnsignedLong:(unsigned long)unsignedLong {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (unsigned long)watermarkSettingView:(id)view watermarkTextReplacementUnsignedLongAtIndexPath:(NSIndexPath *)indexPath {
    return 0UL;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUnsignedLongLong:(unsigned long long)unsignedLongLong {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (unsigned long long)watermarkSettingView:(id)view watermarkTextReplacementUnsignedLongLongAtIndexPath:(NSIndexPath *)indexPath {
    return 0ULL;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementChar:(char)charNumber {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (char)watermarkSettingView:(id)view watermarkTextReplacementCharAtIndexPath:(NSIndexPath *)indexPath {
    return '\0';
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUnsignedChar:(unsigned char)unsignedChar {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (unsigned char)watermarkSettingView:(id)view watermarkTextReplacementUnsignedCharAtIndexPath:(NSIndexPath *)indexPath {
    return '\0';
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementShort:(short)shortNumber {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (short)watermarkSettingView:(id)view watermarkTextReplacementShortAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUnsignedShort:(unsigned short)unsignedShort {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (unsigned short)watermarkSettingView:(id)view watermarkTextReplacementUnsignedShortAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementPoint:(CGPoint)point {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGPoint)watermarkSettingView:(id)view watermarkTextReplacementPointAtIndexPath:(NSIndexPath *)indexPath {
    return CGPointZero;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementSize:(CGSize)size {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGSize)watermarkSettingView:(id)view watermarkTextReplacementSizeAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeZero;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementRect:(CGRect)rect {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (CGRect)watermarkSettingView:(id)view watermarkTextReplacementRectAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectZero;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementEdgeInsets:(UIEdgeInsets)edgeInsets {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIEdgeInsets)watermarkSettingView:(id)view watermarkTextReplacementEdgeInsetsAtIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsZero;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementDirection:(UIUserInterfaceLayoutDirection)direction {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIUserInterfaceLayoutDirection)watermarkSettingView:(id)view watermarkTextReplacementDirectionAtIndexPath:(NSIndexPath *)indexPath {
    return UIUserInterfaceLayoutDirectionLeftToRight;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementLayoutDirection:(UIUserInterfaceLayoutDirection)layoutDirection {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIUserInterfaceLayoutDirection)watermarkSettingView:(id)view watermarkTextReplacementLayoutDirectionAtIndexPath:(NSIndexPath *)indexPath {
    return UIUserInterfaceLayoutDirectionLeftToRight;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementSemanticContentAttribute:(UISemanticContentAttribute)attribute {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UISemanticContentAttribute)watermarkSettingView:(id)view watermarkTextReplacementSemanticContentAttributeAtIndexPath:(NSIndexPath *)indexPath {
    return UISemanticContentAttributeUnspecified;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceLayoutDirection:(UIUserInterfaceLayoutDirection)direction {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIUserInterfaceLayoutDirection)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceLayoutDirectionAtIndexPath:(NSIndexPath *)indexPath {
    return UIUserInterfaceLayoutDirectionLeftToRight;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceLayoutOrientation:(UIUserInterfaceLayoutDirection)direction {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIUserInterfaceLayoutDirection)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceLayoutOrientationAtIndexPath:(NSIndexPath *)indexPath {
    return UIUserInterfaceLayoutDirectionLeftToRight;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceIdiom:(UIUserInterfaceIdiom)idiom {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIUserInterfaceIdiom)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceIdiomAtIndexPath:(NSIndexPath *)indexPath {
    return UIUserInterfaceIdiomPhone;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceStyle:(UIUserInterfaceStyle)style {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIUserInterfaceStyle)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceStyleAtIndexPath:(NSIndexPath *)indexPath {
    return UIUserInterfaceStyleUnspecified;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceLevel:(UIUserInterfaceLevel)level {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIUserInterfaceLevel)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceLevelAtIndexPath:(NSIndexPath *)indexPath {
    return UIUserInterfaceLevelUnspecified;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceSizeCategory:(UIUserInterfaceSizeCategory)sizeCategory {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UIUserInterfaceSizeCategory)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceSizeCategoryAtIndexPath:(NSIndexPath *)indexPath {
    return UIUserInterfaceSizeCategoryUnspecified;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceTraitCollection:(UITraitCollection *)traitCollection {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (UITraitCollection *)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceTraitCollectionAtIndexPath:(NSIndexPath *)indexPath {
    return [UITraitCollection currentTraitCollection];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceTrait:(id)trait {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceTraitAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceTraits:(NSSet *)traits {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSSet *)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceTraitsAtIndexPath:(NSIndexPath *)indexPath {
    return [NSSet set];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceTraitValue:(id)traitValue {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceTraitValueAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceTraitValues:(NSDictionary *)traitValues {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSDictionary *)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceTraitValuesAtIndexPath:(NSIndexPath *)indexPath {
    return @{};
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceTraitKey:(NSString *)traitKey {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSString *)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceTraitKeyAtIndexPath:(NSIndexPath *)indexPath {
    return @"";
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceTraitKeys:(NSArray *)traitKeys {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (NSArray *)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceTraitKeysAtIndexPath:(NSIndexPath *)indexPath {
    return @[];
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceTraitValueForTraitKey:(id)traitValue forTraitKey:(NSString *)traitKey {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceTraitValueForTraitKeyAtIndexPath:(NSIndexPath *)indexPath forTraitKey:(NSString *)traitKey {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceTraitValueForTraitKeyForced:(id)traitValue forTraitKey:(NSString *)traitKey forced:(BOOL)forced {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceTraitValueForTraitKeyAtIndexPath:(NSIndexPath *)indexPath forTraitKey:(NSString *)traitKey forced:(BOOL)forced {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceTraitValueForTraitKeyForcedWithCompletion:(id)traitValue forTraitKey:(NSString *)traitKey forced:(BOOL)forced completion:(void (^)(id value))completion {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceTraitValueForTraitKeyAtIndexPath:(NSIndexPath *)indexPath forTraitKey:(NSString *)traitKey forced:(BOOL)forced completion:(void (^)(id value))completion {
    return nil;
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDelegate

- (void)watermarkSettingView:(id)view didChangeWatermarkTextReplacementUserInterfaceTraitValueForTraitKeyForcedWithCompletionWithDefault:(id)traitValue forTraitKey:(NSString *)traitKey forced:(BOOL)forced completion:(void (^)(id value))completion defaultValue:(id)defaultValue {
}

%end

%hook XYNoteBasicNoteEditViewWatermarkSettingViewDataSource

- (id)watermarkSettingView:(id)view watermarkTextReplacementUserInterfaceTraitValueForTraitKeyAtIndexPath:(NSIndexPath *)indexPath forTraitKey:(NSString *)traitKey forced:(BOOL)forced completion:(void (^)(id value))completion defaultValue:(id)defaultValue {
    return nil;
}

%end

// 自定义字体 Hook - 使用更简单的方式
%hook UIFont

+ (UIFont *)systemFontOfSize:(CGFloat)size {
    if (gCustomFontEnabled && gCustomFontName.length > 0) {
        UIFont *customFont = [UIFont fontWithName:gCustomFontName size:size];
        if (customFont) {
            return customFont;
        }
    }
    return %orig;
}

+ (UIFont *)systemFontOfSize:(CGFloat)size weight:(UIFontWeight)weight {
    if (gCustomFontEnabled && gCustomFontName.length > 0) {
        UIFont *customFont = [UIFont fontWithName:gCustomFontName size:size];
        if (customFont) {
            return customFont;
        }
    }
    return %orig;
}

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)size {
    if (gCustomFontEnabled && gCustomFontName.length > 0) {
        // 如果请求的字体名称与自定义字体不同，则返回自定义字体
        if (![fontName isEqualToString:gCustomFontName]) {
            UIFont *customFont = [UIFont fontWithName:gCustomFontName size:size];
            if (customFont) {
                return customFont;
            }
        }
    }
    return %orig(fontName, size);
}

%end

%ctor {
    @autoreleasepool {
        NSLog(@"[XHSNOWatermark] Xhs Helper 已加载，版本 1.0");
        
        gWatermarkEnabled = YES;
        gSaveEnabled = YES;
        gLivePhotoWatermarkEnabled = YES;
        
        if (!gCustomTextRules) {
            gCustomTextRules = [NSMutableDictionary dictionary];
        }
        
        %init(HideTabBarItems);
        %init(HidePublishButton);
        %init(HideMessageButton);
        %init(HideHotButton);
        
        %init;
    }
}
