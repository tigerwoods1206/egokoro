//
//  AnyData_forSimpleDB.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/15.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "AnyData_forSimpleDB.h"
#import "Pair_Data.h"

@implementation AnyData_forSimpleDB

-(id)initWithKeys:(NSString *)key andUser:(NSString *)user andPubday:(NSString *)pubday
{
    self = [super init];
    if (self)
    {
        self.s3Data    = key;
        self.User      = user;
        self.Pubday    = pubday;
        // self_archived_Data = archived_Data;
        pairdata_Array = nil;
        NSMutableArray *getpro = [[NSMutableArray alloc] init];

        for (NSString *pro in [self propertyNames]) {
            Pair_Data *pair = [[Pair_Data alloc] init];
            pair.prop  = pro;
            pair.value = [self valueForKey:pro];
            [getpro addObject:pair];
        }
        
        pairdata_Array = getpro;
    }
    return self;
}

-(id)initWithAttributes:(NSArray *)Attributes andPropNames:(NSArray *)props andMainKey:(NSString *)key
{
    self = [super init];
    if (self)
    {
        self.s3Data = key;
        self_archived_Data = nil;
        
        NSMutableArray *getpro = [[NSMutableArray alloc] init];
        for (NSString *pro in props) {
            
            if ([pro compare:S3DATA_ATTRIBUTE]== NSOrderedSame) {
                self.s3Data = [self getStringValueForAttribute:pro fromList:Attributes];
            }

            Pair_Data *pair = [[Pair_Data alloc] init];
            pair.prop  = pro;
            pair.value = [self getStringValueForAttribute:pro fromList:Attributes];
            
            [getpro addObject:pair];
        }
        
        pairdata_Array = getpro;
    }
    return self;
}

-(id)initWithSimpleDBItem:(SimpleDBItem *)Item andPropNames:(NSArray *)props andMainKey:(NSString *)key
{
    self = [super init];
    if (self)
    {
        //self.s3Data = key;
        self_archived_Data = nil;
        
        NSMutableArray *getpro = [[NSMutableArray alloc] init];
        for (NSString *pro in props) {
            if ([pro compare:S3DATA_ATTRIBUTE]== NSOrderedSame) {
                NSString *ret;
                ret = [self getStringValueForAttribute:pro fromList:Item.attributes];
                self.s3Data = ret;
            }
            Pair_Data *pair = [[Pair_Data alloc] init];
            pair.prop  = pro;
            pair.value = [self getStringValueForAttribute:pro fromList:Item.attributes];
            
            [getpro addObject:pair];
        }

        pairdata_Array = getpro;
    }
    return self;
}

-(NSString *)get_value:(NSString *)key
{
    if (self_archived_Data!=nil && pairdata_Array == nil) {
        id any_instanse = [NSKeyedUnarchiver unarchiveObjectWithData:self_archived_Data];
        for (NSString *prop in [any_instanse propertyNames]) {
            if([prop compare:key] == NSOrderedSame){
                return [any_instanse valueForKey:prop];
            }
        }

    }
    
    else if (pairdata_Array != nil && self_archived_Data==nil) {
        for (Pair_Data *pair in pairdata_Array) {
            if([pair.prop compare:key]){
                return pair.value;
            }
        }

    }
    return nil;
}

-(NSMutableArray *)get_Attribute_Array
{
    NSMutableArray *attributes = [[NSMutableArray alloc] initWithCapacity:0];
    /*
    SimpleDBReplaceableAttribute *attrib = [[SimpleDBReplaceableAttribute alloc]
                                            initWithName:S3DATA_ATTRIBUTE
                                            andValue:self.Mainkey
                                            andReplace:YES];
    [attributes addObject:attrib];
*/
    if (self_archived_Data!=nil && pairdata_Array == nil) {
        id any_instanse = [NSKeyedUnarchiver unarchiveObjectWithData:self_archived_Data];
        for (NSString *prop in [any_instanse propertyNames]) {
            SimpleDBReplaceableAttribute *attrib = [[SimpleDBReplaceableAttribute alloc]
                                                    initWithName:prop
                                                    andValue:[any_instanse valueForKey:prop]
                                                    andReplace:YES];
            [attributes addObject:attrib];
        }
        return attributes;
    }
    
    else if (pairdata_Array != nil && self_archived_Data==nil) {
        for (Pair_Data *pair in pairdata_Array) {
            SimpleDBReplaceableAttribute *attrib = [[SimpleDBReplaceableAttribute alloc]
                                                    initWithName:pair.prop
                                                    andValue:pair.value
                                                    andReplace:YES];
            [attributes addObject:attrib];
        }
        return attributes;
    }
    return nil;
}

#pragma mark private method
-(NSString *)getStringValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList
{
    for (SimpleDBAttribute *attribute in attributeList) {
        if ( [attribute.name compare:theAttribute] == NSOrderedSame) {
            return attribute.value;
        }
    }
    
    return @"";
}


@end
