//
//  iPhotoToGallery_Tests.m
//  iPhotoToGallery Tests
//
//  Created by Arjan Franzen on 10-01-14.
//
//

#import <XCTest/XCTest.h>
#import "iPhotoToGallery.h"

@interface iPhotoToGallery_Tests : XCTestCase

@end

@implementation iPhotoToGallery_Tests

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

- (void)testExample
{
    iPhotoToGallery *galleryExporter = [[iPhotoToGallery alloc]init];
    
    [galleryExporter addItemsThread:nil];
    
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end



