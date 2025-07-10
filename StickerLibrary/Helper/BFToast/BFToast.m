//
//  BFToast.m
//  VideoCurter
//
//  Created by Sk Borhan Uddin on 11/14/17.
//  Copyright © 2017 Sk Borhan Uddin. All rights reserved.
//

#import "BFToast.h"
#import "UIKit/UIKit.h"

#define SCREEN_WIDTH UIScreen.mainScreen.bounds.size.width
#define SCREEN_HEIGHT UIScreen.mainScreen.bounds.size.height
#define IS_IPHONE_X UIScreen.mainScreen.bounds.size.height > 736.0
#define SAFE_AREA_INSETS UIApplication.sharedApplication.keyWindow.safeAreaInsets
#define RATIO UIScreen.mainScreen.bounds.size.width / 414.0

@implementation BFToast
+ (void) showToastMessageForDraft:(NSString*) message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 206)/2.0, 64, 206, 40)];
        view.backgroundColor = [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:255.f/255.f alpha:1.0f];//[UIColor colorWithRed:239/255.f green:239/255.f blue:239/255.f alpha:1.f];
        view.layer.cornerRadius = 20;
        view.tag = 1797;
        UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectInset(view.bounds, 8, 4)];
        lbl.text = message;
        lbl.numberOfLines = 0;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont fontWithName:@"BeVietnam-Medium" size:16.0f];
        lbl.textColor = [UIColor colorWithRed:28.0/255.0f green:30.0/255.0f blue:33.0/255.0f alpha:1.0f];
        [view addSubview:lbl];
        view.alpha = 0;
        UIWindow *main = [[[UIApplication sharedApplication] delegate] window];
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state != UIApplicationStateBackground || state != UIApplicationStateInactive)
        {
            [main addSubview:view];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:1.0 animations:^{
                        view.alpha = 0;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            if (disappeared) {
                                disappeared(finished);
                            }
                            [main willRemoveSubview:view];
                        }
                    }];
                });
            }
        }];
        
    });
}

+ (void) showToastMessage:(NSString*) message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - (SCREEN_WIDTH * 0.75))/2.0, SCREEN_HEIGHT - 80, SCREEN_WIDTH * 0.75, 50)];
        view.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:239.f/255.f alpha:1.0];//[UIColor colorWithRed:239/255.f green:239/255.f blue:239/255.f alpha:1.f];
        view.layer.cornerRadius = 25;
        view.tag = 1797;
        UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectInset(view.bounds, 8, 4)];
        lbl.text = message;
        lbl.numberOfLines = 2;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize: 12 weight: UIFontWeightSemibold];
        lbl.textColor = [UIColor blackColor];
        [view addSubview:lbl];
        view.alpha = 0;
        UIWindow *main = [[[UIApplication sharedApplication] delegate] window];
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state != UIApplicationStateBackground || state != UIApplicationStateInactive)
        {
            [main addSubview:view];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:1.0 animations:^{
                        view.alpha = 0;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            if (disappeared) {
                                disappeared(finished);
                            }
                            [main willRemoveSubview:view];
                        }
                    }];
                });
            }
        }];
        
    });
}

+ (void) showToastInViewCenter:(NSString*) message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - (SCREEN_WIDTH * 0.6))/2.0, SCREEN_HEIGHT + 25 - (SCREEN_HEIGHT/2.0), SCREEN_WIDTH * 0.6, 50)];
        view.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:239.f/255.f alpha:1.0];
        view.layer.cornerRadius = 25;
        view.tag = 1797;
        UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectInset(view.bounds, 8, 4)];
        lbl.text = message;
        lbl.numberOfLines = 0;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize: 12 weight: UIFontWeightSemibold];
        lbl.textColor = [UIColor blackColor];
        [view addSubview:lbl];
        view.alpha = 0;
        UIWindow *main = [[[UIApplication sharedApplication] delegate] window];
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state != UIApplicationStateBackground || state != UIApplicationStateInactive)
        {
            [main addSubview:view];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:1.0 animations:^{
                        view.alpha = 0;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            if (disappeared) {
                                disappeared(finished);
                            }
                            
                            [main willRemoveSubview:view];
                        }
                    }];
                });
            }
        }];
        
    });
}

+ (void) showToastInCenterMessage:(NSString*) message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - (SCREEN_WIDTH * 0.6))/2.0, (288 * (736/SCREEN_HEIGHT))/3.3f + (IS_IPHONE_X ? 75 : 0), SCREEN_WIDTH * 0.6, 50)];
        view.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:239.f/255.f alpha:0.8];
        view.layer.cornerRadius = 25;
        view.tag = 1797;
        UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectInset(view.bounds, 8, 4)];
        lbl.text = message;
        lbl.numberOfLines = 0;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize: 12 weight: UIFontWeightSemibold];
        lbl.textColor = [UIColor blackColor];
        [view addSubview:lbl];
        view.alpha = 0;
        UIWindow *main = [[[UIApplication sharedApplication] delegate] window];
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state != UIApplicationStateBackground || state != UIApplicationStateInactive)
        {
            [main addSubview:view];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:1.0 animations:^{
                        view.alpha = 0;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            if (disappeared) {
                                disappeared(finished);
                            }
                            
                            [main willRemoveSubview:view];
                        }
                    }];
                });
            }
        }];
        
    });
}

+ (void)showToastAtCenterPoint:(CGPoint)center
                       message:(NSString *)message
                         after:(CGFloat)after
                         delay:(CGFloat)delay
                    disappeared:(void (^)(BOOL))disappeared {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat width = SCREEN_WIDTH * 0.6;
        CGFloat height = 50;
        CGRect frame = CGRectMake(0, 0, width, height);
        UIView *view = [[UIView alloc] initWithFrame:frame];
        CGFloat adjustedX = center.x;
        CGFloat adjustedY = (SAFE_AREA_INSETS.top / 2.0) + center.y;
        view.center = CGPointMake(adjustedX, adjustedY);
        view.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:239.f/255.f alpha:1.0];
        view.layer.cornerRadius = 25;
        view.clipsToBounds = YES;
        view.tag = 1797;
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectInset(view.bounds, 8, 4)];
        lbl.text = message;
        lbl.numberOfLines = 0;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize: 12 weight: UIFontWeightSemibold];
        lbl.textColor = [UIColor blackColor];
        [view addSubview:lbl];
        
        view.alpha = 0;

        UIWindow *mainWindow = UIApplication.sharedApplication.keyWindow ?: UIApplication.sharedApplication.windows.firstObject;
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            [mainWindow addSubview:view];
        }

        [UIView animateWithDuration:0.5 animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:1.0 animations:^{
                        view.alpha = 0;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            [view removeFromSuperview];
                            if (disappeared) {
                                disappeared(finished);
                            }
                        }
                    }];
                });
            }
        }];
    });
}


+ (void) showToastForExportMessage:(NSString*) message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - (SCREEN_WIDTH * 0.6))/2.0, SCREEN_HEIGHT/2-50.0f, SCREEN_WIDTH * 0.6, 50)];
        view.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:239.f/255.f alpha:1.0f];
        view.layer.cornerRadius = 8;
        UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectInset(view.bounds, 8, 4)];
        lbl.text = message;
        lbl.numberOfLines = 0;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",lbl.font.fontName] size:12];
        lbl.textColor = [UIColor blackColor];
        [view addSubview:lbl];
        view.alpha = 0;
        view.tag = 1797;
        UIWindow *main = [[[UIApplication sharedApplication] delegate] window];
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state != UIApplicationStateBackground || state != UIApplicationStateInactive)
        {
            [main addSubview:view];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:1.0 animations:^{
                        view.alpha = 0;
                    } completion:^(BOOL finished) {
                        if (finished) {
                            if (disappeared) {
                                disappeared(finished);
                            }
                            
                            [main willRemoveSubview:view];
                        }
                    }];
                });
            }
        }];
        
    });
}


@end
