//
//  BFToast.h
//  VideoCurter
//
//  Created by Sk Borhan Uddin on 11/14/17.
//  Copyright © 2017 Sk Borhan Uddin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFToast : NSObject
+ (void) showToastMessage:(NSString*) message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared;//
+ (void) showToastMessageForDraft:(NSString*) message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared;
+ (void) showToastInCenterMessage:(NSString*) message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared;
+ (void) showToastInViewCenter:(NSString*) message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared;
+ (void) showToastForExportMessage:(NSString*) message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared;
+ (void) showToastForResizeExportMessage:(NSString*) message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared;
+ (void) showToastAtCenterPoint:(CGPoint)center message:(NSString *)message after:(CGFloat)after delay:(CGFloat)delay disappeared:(void (^)(BOOL))disappeared;
@end
