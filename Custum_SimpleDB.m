//
//  Custum_SimpleDB.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/03/30.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "Custum_SimpleDB.h"

@implementation Custum_SimpleDB


-(id)init
{
    self = [super init];
    if(self)
    {
        //self.Data_Arr = [[NSMutableArray alloc] init];
        [self sdb_init];
    }
    return self;
}

-(void)Save_props:(Save_Props *)prop andkey:(NSString *)key;
{
    
    [self sdb_init];
    //NSString *key = [Const makeUniqueString];
    prop.s3Data = key;
    AnyData_forSimpleDB *any_data = [[AnyData_forSimpleDB alloc] initWithKeys:key andProps:prop];
    [self.sdb addData:any_data];
}

-(NSArray *)Load_Data_Arr_add_query:(NSString *)query
{
    [self sdb_init];
    NSString *count_query = [NSString stringWithFormat:@"select count(*) from %@",self.domain];
    int count = [self.sdb DataCount:count_query];
    if (count==0) {
        return nil;
    }
    NSArray *arr = [self.sdb getDatas:query];
    return arr;
}

-(void)delete_Data:(AnyData_forSimpleDB *)deldb
{
    [self sdb_init];
    
    [self.sdb removeData:deldb];
}


-(void)Clear_All_Data
{
    [self sdb_init];
    
    [self.sdb clearData];
}

-(void)sdb_init
{
    //AnyData_forSimpleDB *dum = [[AnyData_forSimpleDB alloc] init];
    Save_Props *dum = [[Save_Props alloc] init];
    NSArray *props = [dum propertyNames];
    self.domain = @"IINes";
    self.sdb = [[SimpleDB_DataList alloc] initWithProperties:props andDomainName:self.domain andMainkey:[Const makeUniqueString]];
    //[self.sdb createDataDomain];
}


@end
