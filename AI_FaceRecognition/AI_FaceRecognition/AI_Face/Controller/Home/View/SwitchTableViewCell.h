//
//  SwitchTableViewCell.h
//  AI_FaceRecognition
//
//  Created by 晓坤 on 2018/8/22.
//  Copyright © 2018年 xiao_kun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UISwitch *faceSwitch;
@property (nonatomic, copy) void(^switchClickedBlock)(UISwitch *sw);
@end
