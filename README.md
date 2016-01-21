# DMKeyboardBehavior
Category of UIViewController for keyboard behavior observing

## Introduction

Let`s make using keyboard more easy

## Install

**Via cocoapods**

1. Add into your Podfile file: 

```
pod 'DMKeyboardBehavior', :git => 'https://github.com/DimaAvvakumov/DMKeyboardBehavior.git'
```

2. Import header file

```objectiv-c
#import <DMKeyboardBehavior/UIViewController+KeyboardBehavior.h>
```

**Copy files**

1. Simple drag and drop DMKeyboardBehavior category files into your project
2. Add header file 

```objectiv-c
#import "UIViewController+KeyboardBehavior.h"
```

## Usage

Just add method

```objectiv-c
    - (BOOL)kb_shouldKeyboardObserve {
      return YES;
    }
```

And now, you can implement method for customize behavior of your controller

```objectiv-c
    - (void)kb_keyboardShowOrHideAnimationWithHeight:(CGFloat)height animationDuration:(NSTimeInterval)animationDuration animationCurve:(UIViewAnimationCurve)animationCurve {
    
      self.bottomConstraint.constant = height;
    
      [self.view layoutIfNeeded];
  }
```
