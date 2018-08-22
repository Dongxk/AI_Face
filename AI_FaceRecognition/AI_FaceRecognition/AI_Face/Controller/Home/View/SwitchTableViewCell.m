//
//  SwitchTableViewCell.m
//  AI_FaceRecognition
//
//  Created by 晓坤 on 2018/8/22.
//  Copyright © 2018年 xiao_kun. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)switchClicekde:(UISwitch *)sender {
    
    if (self.switchClickedBlock) {
        self.switchClickedBlock(sender);
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
