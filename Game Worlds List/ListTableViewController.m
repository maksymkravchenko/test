//
//  ListTableViewController.m
//  Game Worlds List
//
//  Created by max on 2/27/16.
//  Copyright © 2016 Max. All rights reserved.
//

#import "ListTableViewController.h"

static NSString * const kTableViewCellIdentifier = @"Cell";

static NSString * const kDefaultEmailValue = @"ios.test@xyrality.com";
static NSString * const kDefaultPasswordValue = @"password";

//parsing fetched data from URL strings
static NSString * const kOnlineStringValue = @"online";
static NSString * const kAllAvailableWorldsKey = @"allAvailableWorlds";
static NSString * const kWorldNameKey = @"name";
static NSString * const kDescriptionKey = @"description";
static NSString * const kWorldStatusKey = @"worldStatus";

@interface ListTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property BOOL updatingWorldsList;
@property (nonatomic) NSURLRequest *request;
@property NSArray <NSString *> *availableWorldsNamesList;

@end

@implementation ListTableViewController

- (void)viewDidAppear:(BOOL)animated
{
	[self updateWorldsList];
	[super viewDidAppear:animated];
}

- (NSURLRequest *)request
{
	NSMutableString *mutableURLpath = [NSMutableString stringWithString:@"http://backend1.lordsandknights.com/XYRALITY/WebObjects/BKLoginServer.woa/wa/worlds?"];
	
	NSString *deviceType = [NSString stringWithFormat:@"deviceType=%@-%@%@", [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
	NSString *deviceUUID = [NSString stringWithFormat:@"&deviceId=%@", [[NSUUID UUID] UUIDString]];
	NSString *login = [NSString stringWithFormat:@"&login=%@", kDefaultEmailValue];
	NSString *password = [NSString stringWithFormat:@"&password=%@", kDefaultPasswordValue];
	
	[mutableURLpath appendString:deviceType];
	[mutableURLpath appendString:deviceUUID];
	[mutableURLpath appendString:login];
	[mutableURLpath appendString:password];
	
	NSString *normalizedURLPath = [mutableURLpath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
	
	NSURL *requestURL = [NSURL URLWithString:normalizedURLPath];
	
	NSMutableURLRequest *result = [NSMutableURLRequest requestWithURL:requestURL];
	result.HTTPMethod = @"POST";
	
	return result;
}

- (void)updateWorldsList
{
	__weak ListTableViewController *weakSelf = self;
	NSURLSession *session = [NSURLSession sharedSession];
	
	[[session dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (error == nil)
		{
			NSDictionary *result = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:&error];
			NSArray *allWorldsList = [result objectForKey:kAllAvailableWorldsKey];

			[weakSelf storeAvailableWorldsList:allWorldsList];
			dispatch_async(dispatch_get_main_queue(), ^{
				[weakSelf.tableView reloadData];
			});
		}
		else
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self handleURLError];
			});
		}
	}] resume];
}

- (void)storeAvailableWorldsList:(NSArray *)worldsList
{
	NSMutableArray *result = [NSMutableArray new];
	NSDictionary *worldStatus = nil;
	NSString *description = nil;
	for (NSDictionary *currentWorld in worldsList)
	{
		worldStatus = [currentWorld objectForKey:kWorldStatusKey];
		description = [worldStatus objectForKey:kDescriptionKey];
		if ([description isEqualToString:kOnlineStringValue])
		{
			[result addObject:[currentWorld objectForKey:kWorldNameKey]];
		}
	}

	self.availableWorldsNamesList = result;
}

- (void)handleURLError
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An Error occurred" message:@"Please Check Internet Connection." preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *onRetryAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self updateWorldsList];
		[alert dismissViewControllerAnimated:YES completion:nil];
	}];
	
	UIAlertAction *onCancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[alert dismissViewControllerAnimated:YES completion:nil];
	}];
	
	[alert addAction:onRetryAction];
	[alert addAction:onCancelAction];
	
	[self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return self.availableWorldsNamesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
 
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTableViewCellIdentifier];
	}

	cell.textLabel.text = self.availableWorldsNamesList[indexPath.row];
	return cell;
}

@end
