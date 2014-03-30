//
//  Imagetext_save_load.h
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/19.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "CoreData_save_load.h"
#import "UIImage+Text.h"
#import "Codable.h"

@interface Imagetext_save_load : CoreData_save_load
{
    CoreData_save_load *inst;
}

-(UIImage_Text *)getImageText:(NSString *)title;
-(NSArray *)getImage_OneTitle_Array:(NSString *)title;
-(void)setImageText:(UIImage_Text *)imagetext and_key:(NSString *)title;
-(NSArray *)getImageArray;
-(void)delAllImage;

@end
