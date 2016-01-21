//
//  UIViewController+KeyboardBehavior.m
//  liveAnswer
//
//  Created by Avvakumov Dmitry on 20.01.16.
//  Copyright © 2016 Vedisoft. All rights reserved.
//

#import "UIViewController+KeyboardBehavior.h"

#import <objc/runtime.h>

@implementation UIViewController (KeyboardBehavior)

#pragma mark - Properties

- (BOOL)kb_isKeyboardPresented {
    return [self kb_keyboardHeight] > 0.0;
}

- (CGFloat)kb_keyboardHeight {
    NSNumber *keyboardHeightNumber = objc_getAssociatedObject(self, @selector(kb_keyboardHeight));
    return keyboardHeightNumber.floatValue;
}

- (void)kb_setKeyboardHeight:(CGFloat)keyboardHeight {
    objc_setAssociatedObject(self, @selector(kb_keyboardHeight), @(keyboardHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Swizzling

static void keyboardBehavior_swizzleInstanceMethod(Class c, SEL original, SEL replacement) {
    Method a = class_getInstanceMethod(c, original);
    Method b = class_getInstanceMethod(c, replacement);
    if (class_addMethod(c, original, method_getImplementation(b), method_getTypeEncoding(b))) {
        class_replaceMethod(c, replacement, method_getImplementation(a), method_getTypeEncoding(a));
    } else {
        method_exchangeImplementations(a, b);
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        keyboardBehavior_swizzleInstanceMethod(class, @selector(viewWillAppear:), @selector(keyboardBehavior_viewWillAppear:));
        keyboardBehavior_swizzleInstanceMethod(class, @selector(viewDidDisappear:), @selector(keyboardBehavior_viewDidDisappear:));

    });
}

- (void)keyboardBehavior_viewWillAppear:(BOOL)animated {
    [self keyboardBehavior_viewWillAppear:animated];
    
    // check observing
    BOOL needObserving = [self kb_shouldKeyboardObserve];
    if (needObserving == NO) return;
    
    // start observing
    [self kb_startObservingKeyboardNotifications];
}

- (void)keyboardBehavior_viewDidDisappear:(BOOL)animated {
    [self keyboardBehavior_viewDidDisappear:animated];
    
    // check observing
    BOOL needObserving = [self kb_shouldKeyboardObserve];
    if (needObserving == NO) return;
    
    // stop observing
    [self kb_stopObservingKeyboardNotifications];
}


#pragma mark - Control methods

- (BOOL)kb_shouldKeyboardObserve {
    return NO;
}



- (void)kb_keyboardWillShowOrHideWithHeight:(CGFloat)height
                          animationDuration:(NSTimeInterval)animationDuration
                             animationCurve:(UIViewAnimationCurve)animationCurve {
    // override me if needed
}

- (void)kb_keyboardShowOrHideAnimationWithHeight:(CGFloat)height
                               animationDuration:(NSTimeInterval)animationDuration
                                  animationCurve:(UIViewAnimationCurve)animationCurve {
    // override me if needed
}

- (void)kb_keyboardShowOrHideAnimationDidFinishedWithHeight:(CGFloat)height {
    // override me if needed
}

#pragma mark - Implementation methods

- (void)kb_startObservingKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kb_keyboardWillShowOrHideNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kb_keyboardWillShowOrHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)kb_stopObservingKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Private

- (void)kb_keyboardWillShowOrHideNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    // When keyboard is hiding, the height value from UIKeyboardFrameEndUserInfoKey sometimes is incorrect
    // Sets it manually to 0
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedRect = [self.view convertRect:keyboardFrame fromView:nil];
    BOOL isShowNotification = [notification.name isEqualToString:UIKeyboardWillShowNotification];
    CGFloat keyboardHeight = isShowNotification ? CGRectGetHeight(convertedRect) : 0.0;
    
    [self kb_setKeyboardHeight:keyboardHeight];
    
    
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [self kb_keyboardWillShowOrHideWithHeight:keyboardHeight
                            animationDuration:animationDuration
                               animationCurve:animationCurve];
    
    [UIView beginAnimations:@"UIViewController+KeyboardBehavior-Animation" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(kb_keyboardAnimationDidStop:finished:context:)];
    
    [self kb_keyboardShowOrHideAnimationWithHeight:keyboardHeight
                                 animationDuration:animationDuration
                                    animationCurve:animationCurve];
    
    [UIView commitAnimations];
}

- (void)kb_keyboardAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    CGFloat keyboardHeight = [self kb_keyboardHeight];
    [self kb_keyboardShowOrHideAnimationDidFinishedWithHeight:keyboardHeight];
}

@end
