//
//  StaticViewController.h
//  AI_FaceRecognition
//
//  Created by 晓坤 on 2018/8/9.
//  Copyright © 2018年 Dongxk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaticViewController : UIViewController

@property (nonatomic, copy) void(^faceRecognitionBlock)(BOOL isSuccess);
@end
