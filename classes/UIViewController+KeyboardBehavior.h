//
//  UIViewController+KeyboardBehavior.h
//  liveAnswer
//
//  Created by Avvakumov Dmitry on 20.01.16.
//  Copyright © 2016 Vedisoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (KeyboardBehavior)

@property (nonatomic, readonly) BOOL kb_isKeyboardPresented;
@property (nonatomic, readonly) CGFloat kb_keyboardHeight;

- (BOOL)kb_shouldKeyboardObserve;

- (void)kb_keyboardWillShowOrHideWithHeight:(CGFloat)height
                          animationDuration:(NSTimeInterval)animationDuration
                             animationCurve:(UIViewAnimationCurve)animationCurve;

- (void)kb_keyboardShowOrHideAnimationWithHeight:(CGFloat)height
                               animationDuration:(NSTimeInterval)animationDuration
                                  animationCurve:(UIViewAnimationCurve)animationCurve;

- (void)kb_keyboardShowOrHideAnimationDidFinishedWithHeight:(CGFloat)height;

@end
