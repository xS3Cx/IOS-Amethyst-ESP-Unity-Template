//
//  Menu.m
//  ModMenu
//
//  Created by Joey on 3/14/19.
//  Copyright © 2019 Joey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menu.h"

@interface Menu ()

@property (assign, nonatomic) CGPoint lastMenuLocation;
@property (strong, nonatomic) UILabel *menuTitle;
@property (strong, nonatomic) UIView *header;
@property (strong, nonatomic) UIView *footer;

@end


@implementation Menu

NSUserDefaults *defaults;

UIScrollView *scrollView;
CGFloat menuWidth;
CGFloat scrollViewX;
NSString *credits;
UIColor *switchOnColor;
NSString *switchTitleFont;
UIColor *switchTitleColor;
UIColor *infoButtonColor;
NSString *menuIconBase64;
NSString *menuButtonBase64;
float scrollViewHeight = 0;
BOOL hasRestoredLastSession = false;
UIButton *menuButton;

const char *frameworkName = NULL;

UIWindow *mainWindow;


// init the menu
// global variabls, extern in Macros.h
Menu *menu = [Menu alloc];
Switches *switches = [Switches alloc];


-(id)initWithTitle:(NSString *)title_ titleColor:(UIColor *)titleColor_ titleFont:(NSString *)titleFont_ credits:(NSString *)credits_ headerColor:(UIColor *)headerColor_ switchOffColor:(UIColor *)switchOffColor_ switchOnColor:(UIColor *)switchOnColor_ switchTitleFont:(NSString *)switchTitleFont_ switchTitleColor:(UIColor *)switchTitleColor_ infoButtonColor:(UIColor *)infoButtonColor_ maxVisibleSwitches:(int)maxVisibleSwitches_ menuWidth:(CGFloat )menuWidth_ menuIcon:(NSString *)menuIconBase64_ menuButton:(NSString *)menuButtonBase64_ {
    mainWindow = [UIApplication sharedApplication].keyWindow;
    defaults = [NSUserDefaults standardUserDefaults];

    menuWidth = menuWidth_;
    switchOnColor = switchOnColor_;
    credits = credits_;
    switchTitleFont = switchTitleFont_;
    switchTitleColor = switchTitleColor_;
    infoButtonColor = infoButtonColor_;
    menuButtonBase64 = menuButtonBase64_;

    // Base of the Menu UI.
    self = [super initWithFrame:CGRectMake(0,0,menuWidth_, maxVisibleSwitches_ * 60 + 50)];
    self.center = mainWindow.center;
    self.layer.opacity = 0.0f;

    self.header = [[UIView alloc]initWithFrame:CGRectMake(0, 1, menuWidth_, 50)];
    
    // Create blur effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.header.bounds;
    
    // Add color overlay with RGB(20, 20, 20)
    UIView *colorOverlay = [[UIView alloc] initWithFrame:self.header.bounds];
    colorOverlay.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:0.8];
    
    CAShapeLayer *headerLayer = [CAShapeLayer layer];
    headerLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.header.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    
    // Apply mask to the header itself
    self.header.layer.mask = headerLayer;
    
    // Add blur view first, then color overlay
    [self.header addSubview:blurView];
    [self.header addSubview:colorOverlay];
    
    // Make sure the header is transparent so blur can work
    self.header.backgroundColor = [UIColor clearColor];
    [self addSubview:self.header];



    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.header.bounds), menuWidth_, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.header.bounds))];
    
    // Create blur effect for scrollView background that covers the entire area
    UIBlurEffect *scrollBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
    UIVisualEffectView *scrollBlurView = [[UIVisualEffectView alloc] initWithEffect:scrollBlurEffect];
    scrollBlurView.frame = CGRectMake(0, 0, menuWidth_, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.header.bounds) - CGRectGetHeight(self.footer.bounds));
    scrollBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Add color overlay with RGB(30, 30, 30) that covers the entire area
    UIView *scrollColorOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth_, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.header.bounds) - CGRectGetHeight(self.footer.bounds))];
    scrollColorOverlay.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:0.8];
    scrollColorOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Make sure the scrollView is transparent so blur can work
    scrollView.backgroundColor = [UIColor clearColor];
    
    // Add blur view first, then color overlay
    [scrollView addSubview:scrollBlurView];
    [scrollView addSubview:scrollColorOverlay];
    [self addSubview:scrollView];

    // we need this for the switches, do not remove.
    scrollViewX = CGRectGetMinX(scrollView.self.bounds);

    // Create title label with Helvetica font
    self.menuTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, -2, menuWidth_, 50)];
    self.menuTitle.text = title_;
    self.menuTitle.textColor = [UIColor clearColor]; // Set to clear for gradient mask
    self.menuTitle.font = [UIFont fontWithName:@"Helvetica" size:30.0f];
    self.menuTitle.adjustsFontSizeToFitWidth = true;
    self.menuTitle.textAlignment = NSTextAlignmentCenter;
    
    // Create gradient mask for the title text
    CAGradientLayer *titleGradientLayer = [CAGradientLayer layer];
    titleGradientLayer.frame = self.menuTitle.bounds;
    titleGradientLayer.colors = @[
        (id)[UIColor colorWithRed:194.0/255.0 green:21.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:255.0/255.0 green:197.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor
    ];
    titleGradientLayer.startPoint = CGPointMake(0, 0);
    titleGradientLayer.endPoint = CGPointMake(1, 1);
    
    // Create mask from the title text
    CALayer *titleMaskLayer = [CALayer layer];
    titleMaskLayer.frame = self.menuTitle.bounds;
    titleMaskLayer.contents = (__bridge id)[self createTextMask:self.menuTitle].CGImage;
    
    // Apply mask to gradient
    titleGradientLayer.mask = titleMaskLayer;
    
    // Add gradient layer to title
    [self.menuTitle.layer addSublayer:titleGradientLayer];
    
    [self.header addSubview: self.menuTitle];

    self.footer = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 1, menuWidth_, 20)];
    
    // Create blur effect
    UIBlurEffect *footerBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
    UIVisualEffectView *footerBlurView = [[UIVisualEffectView alloc] initWithEffect:footerBlurEffect];
    footerBlurView.frame = self.footer.bounds;
    
    // Add color overlay with RGB(20, 20, 20)
    UIView *footerColorOverlay = [[UIView alloc] initWithFrame:self.footer.bounds];
    footerColorOverlay.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:0.8];
    
    CAShapeLayer *footerLayer = [CAShapeLayer layer];
    footerLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.footer.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    
    // Apply mask to the footer itself
    self.footer.layer.mask = footerLayer;
    
    // Add blur view first, then color overlay
    [self.footer addSubview:footerBlurView];
    [self.footer addSubview:footerColorOverlay];
    
    // Add footer text
    UILabel *footerText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, menuWidth_, 20)];
    footerText.text = @"T.ME/CRUEXGG";
    footerText.textColor = [UIColor clearColor]; // Set to clear for gradient mask
    footerText.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    footerText.textAlignment = NSTextAlignmentCenter;
    footerText.adjustsFontSizeToFitWidth = true;
    
    // Create gradient mask for the footer text
    CAGradientLayer *footerGradientLayer = [CAGradientLayer layer];
    footerGradientLayer.frame = footerText.bounds;
    footerGradientLayer.colors = @[
        (id)[UIColor colorWithRed:194.0/255.0 green:21.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:255.0/255.0 green:197.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor
    ];
    footerGradientLayer.startPoint = CGPointMake(0, 0);
    footerGradientLayer.endPoint = CGPointMake(1, 1);
    
    // Create mask from the footer text
    CALayer *footerMaskLayer = [CALayer layer];
    footerMaskLayer.frame = footerText.bounds;
    footerMaskLayer.contents = (__bridge id)[self createTextMask:footerText].CGImage;
    
    // Apply mask to gradient
    footerGradientLayer.mask = footerMaskLayer;
    
    // Add gradient layer to footer text
    [footerText.layer addSublayer:footerGradientLayer];
    
    [self.footer addSubview:footerText];
    
    [self addSubview:self.footer];

    UIPanGestureRecognizer *dragMenuRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(menuDragged:)];
    [self.header addGestureRecognizer:dragMenuRecognizer];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideMenu:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.header addGestureRecognizer:tapGestureRecognizer];

    [mainWindow addSubview:self];
    self.layer.zPosition = 1000; // Set high z-position to render above ESP
    [self showMenuButton];

    return self;
}

// Detects whether the menu is being touched and sets a lastMenuLocation.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.lastMenuLocation = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
    [super touchesBegan:touches withEvent:event];
}

// Update the menu's location when it's being dragged
- (void)menuDragged:(UIPanGestureRecognizer *)pan {
    CGPoint newLocation = [pan translationInView:self.superview];
    self.frame = CGRectMake(self.lastMenuLocation.x + newLocation.x, self.lastMenuLocation.y + newLocation.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (void)hideMenu:(UITapGestureRecognizer *)tap {
    if(tap.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 animations:^ {
            self.alpha = 0.0f;
            menuButton.alpha = 1.0f;
        }];
    }
}

-(void)showMenu:(UITapGestureRecognizer *)tapGestureRecognizer {
    if(tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        menuButton.alpha = 0.0f;
        [UIView animateWithDuration:0.5 animations:^ {
            self.alpha = 1.0f;
        }];
    }
    // We should only have to do this once (first launch)
    if(!hasRestoredLastSession) {
        restoreLastSession();
        hasRestoredLastSession = true;
    }
}

/**********************************************************************************************
     This function will be called when the menu has been opened for the first time on launch.
     It'll handle the memory patches for OffsetSwitch based on saved preferences.
***********************************************************************************************/
void restoreLastSession() {
    BOOL isOn = false;

    for(id switch_ in scrollView.subviews) {
        if([switch_ isKindOfClass:[OffsetSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            std::vector<MemoryPatch> memoryPatches = [switch_ getMemoryPatches];
            for(int i = 0; i < memoryPatches.size(); i++) {
                if(isOn){
                 memoryPatches[i].Modify();
                } else {
                 memoryPatches[i].Restore();
                }
            }
        }

        if([switch_ isKindOfClass:[TextFieldSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            // TextFieldSwitch doesn't need memory patches
        }

        if([switch_ isKindOfClass:[SliderSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            // SliderSwitch doesn't need memory patches
        }
    }
}

-(void)showMenuButton {
    menuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    menuButton.frame = CGRectMake((mainWindow.frame.size.width/2), (mainWindow.frame.size.height/2), 50, 50);
    menuButton.backgroundColor = [UIColor clearColor];
    
    // Create blur effect for menu button background
    UIBlurEffect *menuButtonBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterial];
    UIVisualEffectView *menuButtonBlurView = [[UIVisualEffectView alloc] initWithEffect:menuButtonBlurEffect];
    menuButtonBlurView.frame = CGRectMake(0, 0, 50, 50);
    
    // Add color overlay with RGB(30, 30, 30) like scrollView
    UIView *menuButtonColorOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    menuButtonColorOverlay.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:0.8];
    
    // Create rounded corners
    CAShapeLayer *menuButtonLayer = [CAShapeLayer layer];
    menuButtonLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 50, 50) cornerRadius:8.0].CGPath;
    
    // Apply mask to the button itself
    menuButton.layer.mask = menuButtonLayer;
    
    // Add blur view first, then color overlay
    [menuButton addSubview:menuButtonBlurView];
    [menuButton addSubview:menuButtonColorOverlay];
    
    // Create text label for "AM"
    UILabel *amLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    amLabel.text = @"AM";
    amLabel.textColor = [UIColor clearColor]; // Set to clear for gradient mask
    amLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24.0f];
    amLabel.textAlignment = NSTextAlignmentCenter;
    amLabel.adjustsFontSizeToFitWidth = true;
    
    // Create gradient mask for the AM text
    CAGradientLayer *amGradientLayer = [CAGradientLayer layer];
    amGradientLayer.frame = CGRectMake(0, 0, 50, 50);
    amGradientLayer.colors = @[
        (id)[UIColor colorWithRed:194.0/255.0 green:21.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:255.0/255.0 green:197.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor
    ];
    amGradientLayer.startPoint = CGPointMake(0, 0);
    amGradientLayer.endPoint = CGPointMake(1, 1);
    
    // Create mask from the AM text
    CALayer *amMaskLayer = [CALayer layer];
    amMaskLayer.frame = CGRectMake(0, 0, 50, 50);
    amMaskLayer.contents = (__bridge id)[self createTextMask:amLabel].CGImage;
    
    // Apply mask to gradient
    amGradientLayer.mask = amMaskLayer;
    
    // Add gradient layer to AM label
    [amLabel.layer addSublayer:amGradientLayer];
    
    [menuButton addSubview:amLabel];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMenu:)];
    [menuButton addGestureRecognizer:tapGestureRecognizer];

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(buttonDragged:)];
    [menuButton addGestureRecognizer:panGestureRecognizer];
    
    [mainWindow addSubview:menuButton];
    menuButton.layer.zPosition = 1001; // Set higher z-position than menu to render above ESP
}

// handler for when the user is dragging the menu button.
- (void)buttonDragged:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:menuButton.superview];
    menuButton.center = CGPointMake(menuButton.center.x + translation.x, menuButton.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:menuButton.superview];
}

// When the menu icon(on the header) has been tapped, we want to show proper credits!
-(void)menuIconTapped {
    [self showPopup:self.menuTitle.text description:credits];
    self.layer.opacity = 0.0f;
}

-(void)showPopup:(NSString *)title_ description:(NSString *)description_ {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];

    alert.shouldDismissOnTapOutside = NO;
    alert.customViewColor = [UIColor purpleColor];
    alert.showAnimationType = SCLAlertViewShowAnimationFadeIn;

    [alert addButton: @"Ok!" actionBlock: ^(void) {
        self.layer.opacity = 1.0f;
    }];

    [alert showInfo:title_ subTitle:description_ closeButtonTitle:nil duration:9999999.0f];
}

/*******************************************************************
    This method adds the given switch to the menu's scrollview.
    No longer adds target to the entire switch - only toggle handles interactions.
********************************************************************/
- (void)addSwitchToMenu:(id)switch_ {
    scrollViewHeight += 60;
    scrollView.contentSize = CGSizeMake(menuWidth, scrollViewHeight);
    
    [scrollView addSubview:switch_];
}





-(void)setFrameworkName:(const char *)name_ {
    frameworkName = name_;
}

-(const char *)getFrameworkName {
    return frameworkName;
}

// Helper method to create text mask for gradient
- (UIImage *)createTextMask:(UILabel *)label {
    UIGraphicsBeginImageContextWithOptions(label.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Clear background
    CGContextClearRect(context, label.bounds);
    
    // Set text rendering mode for crisp text
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    
    // Create attributed string with the same properties as the label
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];
    [attributedString addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, attributedString.length)];
    
    // Calculate text position
    CGSize textSize = [attributedString size];
    CGFloat x = (label.bounds.size.width - textSize.width) / 2.0;
    CGFloat y = (label.bounds.size.height - textSize.height) / 2.0;
    
    // Draw the text
    [attributedString drawAtPoint:CGPointMake(x, y)];
    
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return maskImage;
}

@end // End of menu class!


/********************************
    OFFSET SWITCH STARTS HERE!
*********************************/

@implementation OffsetSwitch {
    std::vector<MemoryPatch> memoryPatches;
}

- (id)initHackNamed:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::vector<uint64_t>)offsets_ bytes:(std::vector<std::string>)bytes_ {
    hackDescription = description_;
    preferencesKey = hackName_;

    if(offsets_.size() != bytes_.size()){
        [menu showPopup:@"Invalid input count" description:[NSString stringWithFormat:@"Offsets array input count (%d) is not equal to the bytes array input count (%d)", (int)offsets_.size(), (int)bytes_.size()]];
    } else {
        // For each offset, we create a MemoryPatch.
        for(int i = 0; i < offsets_.size(); i++) {
            MemoryPatch patch = MemoryPatch::createWithHex([menu getFrameworkName], offsets_[i], bytes_[i]);
            if(patch.isValid()) {
              memoryPatches.push_back(patch);
            } else {
              [menu showPopup:@"Invalid patch" description:[NSString stringWithFormat:@"Failing offset: 0x%llx, please re-check the hex you entered.", offsets_[i]]];
            }
        }
    }

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight - 1, menuWidth + 2, 60)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:0.0].CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, menuWidth - 80, 25)];
    switchLabel.text = hackName_;
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:switchLabel];

    // Add description label
    UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, menuWidth - 80, 15)];
    descriptionLabel.text = hackDescription;
    descriptionLabel.textColor = [UIColor lightGrayColor];
    descriptionLabel.font = [UIFont fontWithName:@"Arial" size:10];
    descriptionLabel.adjustsFontSizeToFitWidth = true;
    descriptionLabel.textAlignment = NSTextAlignmentLeft;
    descriptionLabel.numberOfLines = 1;
    [self addSubview:descriptionLabel];

    // Add UISwitch toggle
    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(menuWidth - 65, 15, 0, 0)];
    BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:preferencesKey];
    [toggle setOn:isOn animated:NO];
    toggle.onTintColor = [UIColor colorWithRed:255.0/255.0 green:197.0/255.0 blue:0.0/255.0 alpha:1.0];
    [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:toggle];

    // Add gradient separator at the bottom
    CAGradientLayer *separator = [CAGradientLayer layer];
    separator.frame = CGRectMake(10, 59, menuWidth - 20, 1);
    separator.colors = @[
        (id)[UIColor colorWithRed:194.0/255.0 green:21.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:255.0/255.0 green:197.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor
    ];
    separator.startPoint = CGPointMake(0, 0.5);
    separator.endPoint = CGPointMake(1, 0.5);
    [self.layer addSublayer:separator];

    return self;
}

-(void)toggleChanged:(UISwitch *)toggle {
    BOOL isOn = toggle.isOn;
    [defaults setBool:isOn forKey:[self getPreferencesKey]];
    
    // Handle memory patches for OffsetSwitch
    std::vector<MemoryPatch> memoryPatches = [self getMemoryPatches];
    for(int i = 0; i < memoryPatches.size(); i++) {
        if(isOn){
            memoryPatches[i].Modify();
        } else {
            memoryPatches[i].Restore();
        }
    }
}

-(void)showInfo:(UIGestureRecognizer *)gestureRec {
    if(gestureRec.state == UIGestureRecognizerStateEnded) {
        [menu showPopup:[self getPreferencesKey] description:[self getDescription]];
        menu.layer.opacity = 0.0f;
    }
}

-(NSString *)getPreferencesKey {
    return preferencesKey;
}

-(NSString *)getDescription {
    return hackDescription;
}

- (std::vector<MemoryPatch>)getMemoryPatches {
    return memoryPatches;
}

@end //end of OffsetSwitch class


/**************************************
    TEXTFIELD SWITCH STARTS HERE!
    - Note that this extends from OffsetSwitch.
***************************************/

@implementation TextFieldSwitch {
    UITextField *textfieldValue;
}

- (id)initTextfieldNamed:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    hackDescription = description_;

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight -1, menuWidth + 2, 60)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:0.8].CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, menuWidth - 20, 25)];
    switchLabel.text = hackName_;
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:switchLabel];

    // Add description label
    UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, menuWidth - 20, 15)];
    descriptionLabel.text = hackDescription;
    descriptionLabel.textColor = [UIColor lightGrayColor];
    descriptionLabel.font = [UIFont fontWithName:@"Arial" size:10];
    descriptionLabel.adjustsFontSizeToFitWidth = true;
    descriptionLabel.textAlignment = NSTextAlignmentLeft;
    descriptionLabel.numberOfLines = 1;
    [self addSubview:descriptionLabel];

    textfieldValue = [[UITextField alloc]initWithFrame:CGRectMake(menuWidth / 4 - 10, 40, menuWidth / 2, 20)];
    textfieldValue.layer.borderWidth = 2.0f;
    textfieldValue.layer.borderColor = inputBorderColor_.CGColor;
    textfieldValue.layer.cornerRadius = 10.0f;
    textfieldValue.textColor = switchTitleColor;
    textfieldValue.textAlignment = NSTextAlignmentCenter;
    textfieldValue.delegate = self;
    textfieldValue.backgroundColor = [UIColor clearColor];

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        textfieldValue.text = [[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey];
    }



    [self addSubview:textfieldValue];

    return self;
}

// so when click "return" the keyboard goes way, got it from internet. Common thing apparantly
-(BOOL)textFieldShouldReturn:(UITextField*)textfieldValue_ {
    switchValueKey = [[self getPreferencesKey] stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    [defaults setObject:textfieldValue_.text forKey:[self getSwitchValueKey]];
    [textfieldValue_ resignFirstResponder];

    return true;
}

-(NSString *)getSwitchValueKey {
    return switchValueKey;
}

@end // end of TextFieldSwitch Class


/*******************************
    SLIDER SWITCH STARTS HERE!
    - Note that this extends from TextFieldSwitch
 *******************************/

@implementation SliderSwitch {
    UISlider *sliderValue;
    float valueOfSlider;
}

- (id)initSliderNamed:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    hackDescription = description_;

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight -1, menuWidth + 2, 60)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:0.8].CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, menuWidth - 20, 25)];
    switchLabel.text = hackName_;
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:switchLabel];

    // Add description label
    UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, menuWidth - 20, 15)];
    descriptionLabel.text = description_;
    descriptionLabel.textColor = [UIColor lightGrayColor];
    descriptionLabel.font = [UIFont fontWithName:@"Arial" size:10];
    descriptionLabel.adjustsFontSizeToFitWidth = true;
    descriptionLabel.textAlignment = NSTextAlignmentLeft;
    descriptionLabel.numberOfLines = 1;
    [self addSubview:descriptionLabel];

    sliderValue = [[UISlider alloc]initWithFrame:CGRectMake(menuWidth / 4 - 20, 40, menuWidth / 2 + 20, 20)];
    sliderValue.thumbTintColor = sliderColor_;
    sliderValue.minimumTrackTintColor = switchTitleColor;
    sliderValue.maximumTrackTintColor = switchTitleColor;
    sliderValue.minimumValue = minimumValue_;
    sliderValue.maximumValue = maximumValue_;
    sliderValue.continuous = true;
    [sliderValue addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    valueOfSlider = sliderValue.value;

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        sliderValue.value = [[NSUserDefaults standardUserDefaults] floatForKey:switchValueKey];
        switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    }



    [self addSubview:sliderValue];

    return self;
}

-(void)sliderValueChanged:(UISlider *)slider_ {
    switchValueKey = [[self getPreferencesKey] stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", [self getPreferencesKey], slider_.value];
    [defaults setFloat:slider_.value forKey:[self getSwitchValueKey]];
}

@end // end of SliderSwitch class





@implementation Switches


-(void)addSwitch:(NSString *)hackName_ description:(NSString *)description_ {
    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ offsets:std::vector<uint64_t>{} bytes:std::vector<std::string>{}];
    [menu addSwitchToMenu:offsetPatch];

}

- (void)addOffsetSwitch:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::initializer_list<uint64_t>)offsets_ bytes:(std::initializer_list<std::string>)bytes_ {
    std::vector<uint64_t> offsetVector;
    std::vector<std::string> bytesVector;

    offsetVector.insert(offsetVector.begin(), offsets_.begin(), offsets_.end());
    bytesVector.insert(bytesVector.begin(), bytes_.begin(), bytes_.end());

    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ offsets:offsetVector bytes:bytesVector];
    [menu addSwitchToMenu:offsetPatch];
}

- (void)addTextfieldSwitch:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc]initTextfieldNamed:hackName_ description:description_ inputBorderColor:inputBorderColor_];
    [menu addSwitchToMenu:textfieldSwitch];
}

- (void)addSliderSwitch:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {
    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:hackName_ description:description_ minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToMenu:sliderSwitch];
}

- (NSString *)getValueFromSwitch:(NSString *)name {

    //getting the correct key for the saved input.
    NSString *correctKey =  [name stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];

    if([[NSUserDefaults standardUserDefaults] objectForKey:correctKey]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:correctKey];
    }
    else if([[NSUserDefaults standardUserDefaults] floatForKey:correctKey]) {
        NSString *sliderValue = [NSString stringWithFormat:@"%f", [[NSUserDefaults standardUserDefaults] floatForKey:correctKey]];
        return sliderValue;
    }

    return 0;
}

-(bool)isSwitchOn:(NSString *)switchName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:switchName];
}

@end
