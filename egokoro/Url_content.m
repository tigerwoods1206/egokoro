//
//  Url_content.m
//  NewsReader
//
//  Created by オオタ イサオ on 2013/12/23.
//  Copyright (c) 2013年 Dolice. All rights reserved.
//

#import "Url_content.h"

@implementation Url_content

+(void)get_content_form_url:(NSString *)urlstring reload_table:(UITableView *)tableview setitem:(Item *)item
{
    //http://boilerpipe-web.appspot.com/extract?url=%@&output=json
    //http://ec2-54-199-163-10.ap-northeast-1.compute.amazonaws.com/php/get_test.php?page=http://headlines.yahoo.co.jp/hl?a=20140125-00000055-mai-soci
    NSString *urlString = [NSString stringWithFormat:@"http://ec2-54-199-163-10.ap-northeast-1.compute.amazonaws.com/php/get_text.php?page=%@", urlstring];
    urlString = [urlString  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

  //  NSError *error;
  //  NSURLResponse *response;
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    [request setHTTPMethod:type];
    
    
    NSURLRequest *requests = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
  
    
  //  NSData *data = [NSURLConnection sendSynchronousRequest:requests returningResponse:&response error:&error];
   
    [NSURLConnection sendAsynchronousRequest:requests queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        
        if (error==nil && data) {
       // if (data) {
            // NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSMutableDictionary*  directions = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error) {
                NSLog(@"%@",error);
            }
            NSDictionary* result=[directions objectForKey:@"result"];
            //[urlstr stringByAddingPercentEscapesUsingEncoding:NSJapaneseEUCStringEncoding]
         //   NSLog(@"Result: %@",[result stringByAddingPercentEscapesUsingEncoding:NSJapaneseEUCStringEncoding]);
            NSString* status=[result objectForKey:@"status"];
            NSLog(@"Status: %@", status);
            
            if ([status isEqualToString:@"true"]) {
                //NSDictionary *resp = [result valueForKey:@"response"];
                NSString *content = [result valueForKey:@"description"];
                //NSLog(@"Result: %@",[content stringByAddingPercentEscapesUsingEncoding:NSJapaneseEUCStringEncoding]);
               // content = [content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                //[urlstr stringByAddingPercentEscapesUsingEncoding:NSJapaneseEUCStringEncoding]);
               // NSLog(@"Result: %@",content);
               //  NSString *title = [result valueForKey:@"title"];
               // title = [title ]
                //NSLog(@"Title: %@",[title stringByAddingPercentEscapesUsingEncoding:NSJapaneseEUCStringEncoding]);
                 item.description = content;
                // 文字列strの中に@"AAA"というパターンが存在するかどうか
              
                NSRange searchResult_maru = [content rangeOfString:@"。\n"];
                NSRange searchResult_kako = [content rangeOfString:@"\n"];
                if(searchResult_maru.location == NSNotFound && searchResult_kako.location == NSNotFound){
                    // みつからない場合の処理
                   // NSLog(@"%@",content);
                    item.description = content;
                }else{
                    // みつかった場合の処理
                    NSString *one_content;
                    /*
                    if (searchResult_kako.length > searchResult_maru.length) {
                        one_content = [content substringToIndex:searchResult_kako.location];
                    }
                    else {
                        one_content = [content substringToIndex:searchResult_maru.location];
                    */
                    one_content= [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    NSLog(@"%@",one_content);
                    item.description = one_content;
                    
                }
                
            }
        }else NSLog(@"%@",error);
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"Request Done" object:nil];
        
        
    }];

}

@end
