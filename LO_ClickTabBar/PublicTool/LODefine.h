//
//  LODefine.h
//  LO_ClickTabBar
//
//  Created by ejt_ios on 2017/6/19.
//  Copyright © 2017年 ejt_ios. All rights reserved.
//

#ifndef LODefine_h
#define LODefine_h


#define BigeFont 17.0f
#define DefaultFont 15.0f
#define ZongFont 13.0f
#define XiaoFont 12.0f



#define LO_FILE_NAME        @"lo_file_name"
#define FILE_NAME_COUNT     @"photo_count"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define RGB(x,y,z) [UIColor colorWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:1.0]
#define RGBA(x,y,z,a) [UIColor colorWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:a]

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )


#define THEME_COLOR [UIColor colorWithRed:20/255.0f green:150/255.0f blue:241/255.0f alpha:1]
#define LOGBTN_COLOR [UIColor colorWithRed:15/255.0f green:115/255.0f blue:199/255.0f alpha:1]
#define INPUT_BG_COLOR [UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1]

// 通知
#define FILE_NAME_CHANGE @"file_name_change"
// 图片发生改变时
#define IMAGE_CHANGE @"image_change"
#endif /* LODefine_h */
