//
//  rememberTests.m
//  rememberTests
//
//  Created by RentonTheUncoped on 14-8-18.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReviewItem.h"
#import "ReviewItemManager.h"
#import "ReviewItemGenerator.h"
#import <CloudKit/CloudKit.h>

@interface rememberTests : XCTestCase

@end

@implementation rememberTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}

- (void)testGetNextReviewDateId
{
    ReviewItem* item = [ReviewItem createReviewItem];
    item.dateId_created = 20150818;
    item.dateId_lastReviewed = 20150818;
    XCTAssert(20150818 == [item getNextReviewDateId], @"");
    XCTAssert(20150818 == [item getReviewDateIdOnIndex:1], @"");
    XCTAssert(20150819 == [item getReviewDateIdOnIndex:2], @"");
    XCTAssert(20150821 == [item getReviewDateIdOnIndex:3], @"");
    XCTAssert(20150825 == [item getReviewDateIdOnIndex:4], @"");
    XCTAssert(20150901 == [item getReviewDateIdOnIndex:5], @"");
    XCTAssert(20150916 == [item getReviewDateIdOnIndex:6], @"");
    XCTAssert(20151016 == [item getReviewDateIdOnIndex:7], @"");
    
    item.time_reviews = 1;
    XCTAssert(20150819 == [item getNextReviewDateId], @"");
    XCTAssert(-1 == [item getReviewDateIdOnIndex:1], @"");
    XCTAssert(20150819 == [item getReviewDateIdOnIndex:2], @"");
    XCTAssert(20150821 == [item getReviewDateIdOnIndex:3], @"");
    XCTAssert(20150825 == [item getReviewDateIdOnIndex:4], @"");
    XCTAssert(20150901 == [item getReviewDateIdOnIndex:5], @"");
    XCTAssert(20150916 == [item getReviewDateIdOnIndex:6], @"");
    XCTAssert(20151016 == [item getReviewDateIdOnIndex:7], @"");
    
    item.time_reviews = 2;
    XCTAssert(20150820 == [item getNextReviewDateId], @"");
    XCTAssert(-1 == [item getReviewDateIdOnIndex:1], @"");
    XCTAssert(-1 == [item getReviewDateIdOnIndex:2], @"");
    XCTAssert(20150820 == [item getReviewDateIdOnIndex:3], @"");
    XCTAssert(20150824 == [item getReviewDateIdOnIndex:4], @"");
    XCTAssert(20150831 == [item getReviewDateIdOnIndex:5], @"");
    XCTAssert(20150915 == [item getReviewDateIdOnIndex:6]);
    XCTAssert(20151015 == [item getReviewDateIdOnIndex:7], @"");
}

- (void)testReviewItemManagerSaveAndLoad
{
    ReviewItemManager* manager = [ReviewItemManager sharedInstance];
    ReviewItem* item = [ReviewItem createReviewItem];
    ReviewItem* item2 = [ReviewItem createReviewItem];
    XCTAssert([manager deleteAllItems], @"");
    XCTAssert([manager addItem:item], @"");
    XCTAssert([manager addItem:item2], @"");
    XCTAssert([manager save], @"");
    XCTAssert([manager load], @"");
    XCTAssert(2 == manager.items.count, @"");
    XCTAssert([manager deleteItemByID:item.id_review], @"");
    XCTAssert(1 == manager.items.count, @"");
    
}

- (void)testReviewGenerator
{
    ReviewItemManager* manager = [ReviewItemManager sharedInstance];
    ReviewItem* item = [ReviewItem createReviewItem];
    ReviewItem* item2 = [ReviewItem createReviewItem];
    XCTAssert([manager deleteAllItems], @"");
    XCTAssert([manager addItem:item], @"");
    XCTAssert([manager addItem:item2], @"");
    XCTAssert([manager save], @"");
    XCTAssert([manager load], @"");
    XCTAssert(2 == manager.items.count, @"");
    XCTAssert([manager deleteItemByID:item2.id_review], @"");
    XCTAssert(1 == manager.items.count, @"");
    [[ReviewItemGenerator sharedInstance] refresh];
    item = manager.items.firstObject;
    [item review];
    [item review];
    [[ReviewItemGenerator sharedInstance] refreshForItem:item];
}

//- (void)testICloudKit
//{
//    CKContainer* container = [CKContainer defaultContainer];
//    CKDatabase* dataBase = [container publicCloudDatabase];
//    CKRecordID* recordID = [[CKRecordID alloc]initWithRecordName:@"TestID"];
//    CKRecord* record = [[CKRecord alloc]initWithRecordType:@"TestUnit" recordID:recordID];
//    
//    record[@"key1"] = @"22";
//    [dataBase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
//        if (error)
//        {
//            NSLog(@"%@", error);
//        }
//        else
//        {
//            id sth = record;
//            NSLog(@"%@", sth);
//        }
//    }];
//}
@end
