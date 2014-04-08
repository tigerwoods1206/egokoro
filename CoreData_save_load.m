//
//  CoreData_save_load.m
//  egokoro
//
//  Created by オオタ イサオ on 2014/02/13.
//  Copyright (c) 2014年 オオタ イサオ. All rights reserved.
//

#import "CoreData_save_load.h"

@implementation CoreData_save_load

// NSManagedObjectContextのインスタンスを作成するメソッド
- (id)init {
    self = [super init];
    if (self != nil) {
        [self loadManagedObjectContext];
    }
    return self;
}

- (void)loadManagedObjectContext {
    
    if (context != nil)
        return;
    
    NSPersistentStoreCoordinator *aCoodinator = [self coordinator];
    if (aCoodinator != nil) {
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:aCoodinator];
    }
}

// NSPersistentStoreCoordinatorインスタンスを作成するメソッド。
// NSManagedObjectContextを作成する際に必要となる。
// データ永続化の具体的な方法を実装しているが、
// 今回は、sqliteを用いたデータ永続化を行う。
- (NSPersistentStoreCoordinator *)coordinator {
    
    if (coordinator != nil) {
        return coordinator;
    }
    
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *storeURL = [NSURL fileURLWithPath:[directory stringByAppendingPathComponent: @"CoreData.sqlite"]];
    
    NSError *error = nil;
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![coordinator
          addPersistentStoreWithType:NSSQLiteStoreType
          configuration:nil
          URL:storeURL
          options:nil
          error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return coordinator;
}

// NSManagedObjectModelのインスタンスを生成するクラス。
// 上記で作成したモデル定義ファイルを読み込む。
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Model"ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return managedObjectModel;
}

-(void)store_NSData:(NSData *)data anddate:(NSDate *)date
{
    
  //  NSData *image_data = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
    // 新規にNSManagedObjectを生成します。
    // 生成時にEntity名を指定して、
    // どのエンティティ（テーブル）に登録するのかを指定します。
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Entity" inManagedObjectContext:context];
    [object setValue:date forKey:@"key"];
    [object setValue:data forKey:@"data"];
    
    // 作成したNSManagedObjectインスタンスに値を設定します。
    // [object setValue:@"valueに登録する値" forKey:@"value"];
    
    // 作成したNSManagedObjectをDBに保存します。
    // 引数にNSErrorを参照渡しで渡す事で、エラー発生時には、
    // エラー内容を取得することが出来ます。
    NSError *error = nil;
    
    if (![context save:&error]) {
        NSLog(@"error = %@", error);
    } else {
        NSLog(@"Insert Completed.");
    }
    
    //[self del_UIImage:0];
}

-(void)store_NSData:(NSData *)data andkey:(NSString *)key
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Entity" inManagedObjectContext:context];
    [object setValue:[NSDate date] forKey:@"key"];
    [object setValue:data forKey:@"data"];
    [object setValue:key forKey:@"title"];
    
    // 作成したNSManagedObjectインスタンスに値を設定します。
    // [object setValue:@"valueに登録する値" forKey:@"value"];
    
    // 作成したNSManagedObjectをDBに保存します。
    // 引数にNSErrorを参照渡しで渡す事で、エラー発生時には、
    // エラー内容を取得することが出来ます。
    NSError *error = nil;
    
    if (![context save:&error]) {
        NSLog(@"error = %@", error);
    } else {
        NSLog(@"Insert Completed.");
    }

}

-(NSData *)get_Data:(NSDate *)date
{
    // DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 取得するエンティティを設定
    NSEntityDescription *entityDescription;
    entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    // ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:desc, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // 取得条件の設定
    //    NSPredicate *pred;
    //    pred = [NSPredicate predicateWithFormat:@"key = %@", keynum];
    //    [fetchRequest setPredicate:pred];
    
    // 取得最大数の設定
    [fetchRequest setFetchBatchSize:1];
    
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                         initWithFetchRequest:fetchRequest
                         managedObjectContext:context
                         sectionNameKeyPath:nil
                         cacheName:nil];
    
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // 取得結果は[fetchedObjects]プロパティに入っている
    NSArray *result = resultsController.fetchedObjects;
    
    int count = [result count];
    if (count==0) {
        return nil;
    }
    
    NSData *data = [[result objectAtIndex:0] valueForKey:@"data"];
    return data;
}

-(NSData *)get_Data_from_key:(NSString *)key
{
    // DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 取得するエンティティを設定
    NSEntityDescription *entityDescription;
    entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    // ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:desc, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // 取得条件の設定
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"title = %@", key];
    [fetchRequest setPredicate:pred];
    
    // 取得最大数の設定
    [fetchRequest setFetchBatchSize:1];
    
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                         initWithFetchRequest:fetchRequest
                         managedObjectContext:context
                         sectionNameKeyPath:nil
                         cacheName:nil];
    
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // 取得結果は[fetchedObjects]プロパティに入っている
    NSArray *result = resultsController.fetchedObjects;
    
    int count = [result count];
    if (count==0) {
        return nil;
    }
    
    NSData *data = [[result objectAtIndex:0] valueForKey:@"data"];
    return data;

}

-(NSArray *)get_Data_Array_from_key:(NSString *)key
{
    // DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 取得するエンティティを設定
    NSEntityDescription *entityDescription;
    entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    // ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
   // desc = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:desc, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // 取得条件の設定
    
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"title = %@", key];
    [fetchRequest setPredicate:pred];
    
    // 取得最大数の設定
    [fetchRequest setFetchBatchSize:10];
    
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                         initWithFetchRequest:fetchRequest
                         managedObjectContext:context
                         sectionNameKeyPath:nil
                         cacheName:nil];
    
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // 取得結果は[fetchedObjects]プロパティに入っている
    NSArray *result = resultsController.fetchedObjects;
    
    int count = [result count];
    if (count==0) {
        return nil;
    }
    
    
    NSMutableArray *data_arr = [[NSMutableArray alloc] init];
    for (int idx = 0; idx < [result count]; idx++) {
        [data_arr addObject:[[result objectAtIndex:idx] valueForKey:@"data"]];
    }
    
   // NSData *data = [[result objectAtIndex:0] valueForKey:@"data"];
    return data_arr;
}


-(NSArray *)get_dataarray:(int)before_day
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 取得するエンティティを設定
    NSEntityDescription *entityDescription;
    entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    // ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:desc, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // 取得条件の設定
    NSDate* endDate = [NSDate date];
    NSDate* startDate   = [NSDate dateWithTimeIntervalSinceNow:-86400*before_day];
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat: @"(key >= %@ ) and (key < %@)",startDate,endDate];
    //pred = [NSPredicate predicateWithFormat:@"key = %@", keynum];
    [fetchRequest setPredicate:pred];
    
    // 取得最大数の設定
    [fetchRequest setFetchBatchSize:100];
    
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                         initWithFetchRequest:fetchRequest
                         managedObjectContext:context
                         sectionNameKeyPath:nil
                         cacheName:nil];
    
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // 取得結果は[fetchedObjects]プロパティに入っている
    NSArray *result = resultsController.fetchedObjects;
    
    NSMutableArray *data_arr = [[NSMutableArray alloc] init];
    for (int idx = 0; idx < [result count]; idx++) {
        [data_arr addObject:[[result objectAtIndex:idx] valueForKey:@"data"]];
    }
   // NSData *data = [[result objectAtIndex:0] valueForKey:@"data"];
    
    return data_arr;
    
}

-(NSData *)get_data:(NSDate *)date
{
    // DBから読み取るためのリクエストを作成
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 取得するエンティティを設定
    NSEntityDescription *entityDescription;
    entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    // ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:desc, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // 取得条件の設定
    //    NSPredicate *pred;
    //    pred = [NSPredicate predicateWithFormat:@"key = %@", keynum];
    //    [fetchRequest setPredicate:pred];
    
    // 取得最大数の設定
    [fetchRequest setFetchBatchSize:1];
    
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                         initWithFetchRequest:fetchRequest
                         managedObjectContext:context
                         sectionNameKeyPath:nil
                         cacheName:nil];
    
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // 取得結果は[fetchedObjects]プロパティに入っている
    NSArray *result = resultsController.fetchedObjects;
    
    NSData *data = [[result objectAtIndex:0] valueForKey:@"data"];
    return data;
}

-(void)del_Data_from_key:(NSString *)key
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 取得するエンティティを設定
    NSEntityDescription *entityDescription;
    entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    // ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:desc, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // 取得条件の設定
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"title = %@", key];
    [fetchRequest setPredicate:pred];

    // 取得最大数の設定
    [fetchRequest setFetchBatchSize:10];
    
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                         initWithFetchRequest:fetchRequest
                         managedObjectContext:context
                         sectionNameKeyPath:nil
                         cacheName:nil];
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // 取得結果は[fetchedObjects]プロパティに入っている
    NSArray *result = resultsController.fetchedObjects;
    
    for (NSManagedObject *obj in result) {
        [context deleteObject:obj];
    }
    
    if (![context save:&error]) {
        NSLog(@"error = %@", error);
    } else {
        NSLog(@"delete Completed.");
    }

}

-(void)del_allData
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // 取得するエンティティを設定
    NSEntityDescription *entityDescription;
    entityDescription = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:context];
    [fetchRequest setEntity:entityDescription];
    
    // ソート条件配列を作成
    NSSortDescriptor *desc;
    desc = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    
    NSArray *sortDescriptors;
    sortDescriptors = [[NSArray alloc] initWithObjects:desc, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // 取得条件の設定
    //    NSPredicate *pred;
    //    pred = [NSPredicate predicateWithFormat:@"key = %@", keynum];
    //    [fetchRequest setPredicate:pred];
    
    
    // 取得最大数の設定
    [fetchRequest setFetchBatchSize:1];
    
    // データ取得用コントローラを作成
    NSFetchedResultsController *resultsController;
    resultsController = [[NSFetchedResultsController alloc]
                         initWithFetchRequest:fetchRequest
                         managedObjectContext:context
                         sectionNameKeyPath:nil
                         cacheName:nil];
    // DBから値を取得する
    NSError *error;
    if (![resultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // 取得結果は[fetchedObjects]プロパティに入っている
    NSArray *result = resultsController.fetchedObjects;
    
    for (NSManagedObject *obj in result) {
        [context deleteObject:obj];
    }
    
    if (![context save:&error]) {
        NSLog(@"error = %@", error);
    } else {
        NSLog(@"delete Completed.");
    }
}




@end
