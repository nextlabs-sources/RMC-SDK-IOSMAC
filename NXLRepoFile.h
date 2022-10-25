//
//  NXLRepoFile.h
//  nxSDK
//
//  Created by Paul (Qian) Chen on 12/07/2017.
//  Copyright © 2017 Eren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXLRepoFile : NSObject
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, strong) NSString *repoId;
@property(nonatomic, strong) NSString *filePath;
@property(nonatomic, strong) NSString *filePathId;
@end
