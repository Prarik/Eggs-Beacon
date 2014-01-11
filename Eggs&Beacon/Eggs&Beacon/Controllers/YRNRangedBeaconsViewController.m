//
//  YRNRangedBeaconsViewController.m
//  Eggs&Beacon
//
//  Created by Mouhcine El Amine on 29/12/13.
//  Copyright (c) 2013 Yron Lab. All rights reserved.
//

#import "YRNRangedBeaconsViewController.h"
#import "YRNBeaconManager.h"
#import "YRNBeaconDetailViewController.h"
#import "YRNEventDetailViewController.h"

@interface YRNRangedBeaconsViewController () <YRNBeaconManagerDelegate>

typedef enum {
    Welcome = 0,
	MeetAlessio,
	GoodBye
} EventType;

@property (nonatomic, strong) YRNBeaconManager *beaconManager;
@property (nonatomic, strong) NSArray *beacons;
@property (nonatomic, strong) UILocalNotification *currentNotification;

@end

@implementation YRNRangedBeaconsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *configurationFilePath = [[NSBundle mainBundle] pathForResource:@"BeaconRegions"
                                                                      ofType:@"plist"];
    [[self beaconManager] registerBeaconRegions:[CLBeaconRegion beaconRegionsWithContentsOfFile:configurationFilePath]];
}

#pragma mark - Beacon manager

- (YRNBeaconManager *)beaconManager
{
    if (!_beaconManager) {
        _beaconManager = [[YRNBeaconManager alloc] init];
        [_beaconManager setDelegate:self];
    }
    return _beaconManager;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self beacons] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BeaconCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    CLBeacon *beacon = [self beacons][indexPath.row];
    cell.textLabel.text = [beacon description];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"BeaconDetail"]) {
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = sender;
            NSIndexPath *indexPath = [[self tableView] indexPathForCell:cell];
            CLBeacon *beacon = [self beacons][[indexPath row]];
            YRNBeaconDetailViewController *beaconDetailViewController = [segue destinationViewController];
            [beaconDetailViewController setBeacon:beacon];
        }
    }
    else if ([[segue identifier] isEqualToString:@"EventDetail"]) {
        UINavigationController *navigationController = segue.destinationViewController;
		YRNEventDetailViewController *eventViewController = [[navigationController viewControllers] firstObject];
        NSDictionary *notificationInfo = [[self currentNotification] userInfo];
        
        if(notificationInfo)
        {
            EventType eventType = [(NSNumber *)[notificationInfo objectForKey:@"EventType"] intValue];
            switch (eventType)
            {
                case Welcome:
                    [eventViewController setImageName:@"veespo_logo.jpg"];
                    [eventViewController setEventName:@"Benvenuto in Veespo"];
                    [eventViewController setEventText:@"Stiamo creando uno strumento per dar voce a tutti che faciliti l’espressione e la comunicazione delle proprie idee e opinioni. Queste devono arrivare con forza a chi crea, organizza e amministra. Immaginiamo un network di opinioni condivise a cui piccole e grandi organizzazioni, pubbliche e private, possano accedere per migliorare efficacemente quello che ci circonda."];
                    break;
                    
                default:
                    break;
            }
        }
    }
}

- (void)eventInfoForNotification:(UILocalNotification *)notification
{
    [self setCurrentNotification:notification];
    [self performSegueWithIdentifier:@"EventDetail" sender:self];
}

#pragma mark - YRNBeaconManagerDelegate methods

- (void)beaconManager:(YRNBeaconManager *)manager didEnterRegion:(CLBeaconRegion *)region
{
    // estimote region
    if([[[region proximityUUID] UUIDString] isEqualToString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"])
    {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        {
            // app is active, open modal, no notifications
        }
        else
        {
            NSDictionary *notificationInfo = @{@"EventType": [NSNumber numberWithInt:Welcome],
                                               @"UUID": [[region proximityUUID] UUIDString]};
            UILocalNotification *rangingNotification = [[UILocalNotification alloc] init];
            [rangingNotification setUserInfo:notificationInfo];
            [rangingNotification setAlertBody:@"Welcome to Veespo!"];
            [rangingNotification setAlertAction:@"Cool"];
            [rangingNotification setSoundName:UILocalNotificationDefaultSoundName];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:rangingNotification];
        }
    }
}

- (void)beaconManager:(YRNBeaconManager *)manager didExitRegion:(CLBeaconRegion *)region
{
    
}

- (void)beaconManager:(YRNBeaconManager *)manager
      didRangeBeacons:(NSArray *)beacons
             inRegion:(CLBeaconRegion *)region
{
    [self setTitle:[region identifier]];
    [self setBeacons:[beacons copy]];
    [[self tableView] reloadData];
    
    // here local notification
    // how can we know if we've just enetered (distance far?) or we are moving outstide?

    
}

@end