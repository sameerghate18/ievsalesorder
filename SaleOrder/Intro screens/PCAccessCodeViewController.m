//
//  PCAccessCodeViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 16/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCAccessCodeViewController.h"
#import "SVProgressHUD.h"
#import "ConnectionHandler.h"
#import "PCUserLoginViewController.h"
#import "PCViewController.h"
#import "AppDelegate.h"
#import "PCDeviceLicenseModel.h"
#import "PCDeviceRegisterModel.h"
#import "PCDemoViewController.h"
#import "PCDeviceRegisterCheckModel.h"
#import "PCUpdateMobileNumberViewController.h"

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif

typedef enum{
    SetupConnectionTypeDeviceRegister,
    SetupConnectionTypeUpdateLicense,
    SetupConnectionTypeCheckDevice
}SetupConnectionType;

@interface PCAccessCodeViewController () <UITextFieldDelegate,PCUpdateMobileNumberViewControllerDelegate, ConnectionHandlerDelegate>

{
    NSMutableArray *usersList;
    NSString *companyURL;
    SetupConnectionType setupConnectionType;
    AppDelegate *appDel;
    PCDeviceLicenseModel *licenseModel;
    PCDeviceRegisterModel *deviceRegisterModel;
}

@property (nonatomic, weak) IBOutlet UITextField *codeTF, *phoneNumberTF;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageview;
@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, strong) NSString *userPhoneNumber;

@end

@implementation PCAccessCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)animate {
    
    [UIView animateWithDuration:1.0 animations:^{
//        CGRect rect = _logoImageview.frame;
//        [_logoImageview setFrame:CGRectMake(rect.origin.x, rect.origin.y - 100, rect.size.width, rect.size.height)];
//        [_logoImageview setAlpha:1.0];
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1.0 animations:^{
            [_codeTF setAlpha:1.0];
            [_phoneNumberTF setAlpha:1.0];
        }];
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigate_strip.png"] forBarMetrics:UIBarMetricsDefault];
//    
//    self.navigationController.view.backgroundColor =
//    [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-568h@2x.png"]];
//    
//    self.navigationItem.title = @"Provide your access code";
//    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    
//    [self animate];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startDemo:(id)sender
{
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 480)
    {
        // iPhone Classic
        UINavigationController *navFor4 = [kStoryboard instantiateViewControllerWithIdentifier:@"DemoRootNavigation"];
        [self presentViewController:navFor4 animated:YES completion:NULL];
    }
    if(result.height >= 568)
    {
        UINavigationController *navFor4 = [kStoryboard instantiateViewControllerWithIdentifier:@"DemoRootNavigation-4"];
        [self presentViewController:navFor4 animated:YES completion:NULL];
    }
}

- (IBAction)registerButtonAction:(id)sender
{
    [self checkForIsDeviceAlreadyRegistered];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    if (textField == _codeTF) {
//        [_phoneNumberTF becomeFirstResponder];
//        return NO;
//    }
//    
//    [textField resignFirstResponder];
//    [self checkForIsDeviceAlreadyRegistered];
    return YES;
}

- (void)checkForIsDeviceAlreadyRegistered
{
    [self resignFirstResponder];
    
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSString *accessCode = _codeTF.text;
    accessCode = [accessCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *phoneNumber = _phoneNumberTF.text;
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (accessCode.length == 0 || phoneNumber.length==0) {
        [SVProgressHUD dismiss];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"You need to provide the access code and your 10-digit phone number to use the application." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];

        return;
    }
    
    [self setUserPhoneNumber:phoneNumber];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.userPhoneNumber forKey:kPhoneNumber];
    [defaults setValue:accessCode forKey:kAccessCode];
    [defaults synchronize];
    
    ConnectionHandler *registerDeviceConnection = [[ConnectionHandler alloc] init];
//    registerDeviceConnection.delegate = self;
    registerDeviceConnection.tag = kCheckDeviceRegisteredTag;
    
    NSString *urlString = [NSString stringWithFormat:@"%@isregisterDevice?scocd=%@&DeviceId=%@&MobNo=%@",
                           kAppBaseURL,
                           _codeTF.text,
                           appDel.appUniqueIdentifier,
                           self.userPhoneNumber];
    
    setupConnectionType = SetupConnectionTypeCheckDevice;
    
//    [registerDeviceConnection fetchDataForURL:urlString body:nil completion:NULL];
    
    [registerDeviceConnection fetchDataForPOSTURL:urlString body:nil completion:^(id responseData, NSError *error) {
        
        {
            NSError *jsonerror = nil;
            NSArray *opArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonerror];
            
//            NSString *opstring = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"kCheckDeviceRegisteredTag output - %@",responseData);
            
            if (!error) {
                
                if (opArray.count > 0) {
                    
                    NSDictionary *dict = [opArray objectAtIndex:0];
                    
                    PCDeviceRegisterCheckModel *model = [[PCDeviceRegisterCheckModel alloc] init];
                    [model setValuesForKeysWithDictionary:dict];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [SVProgressHUD dismiss];
                        if ([model.IsDeviceRegistered isEqualToString:@"YES"] && [model.IsMobileRegistered isEqualToString:@"YES"]) {
                                                        
                            if ([model.IsActive isEqualToString:@"A"]) {
                                // registered and active.
                                
                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_REGISTRATION_COMPLETE_KEY];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                [self verifyCode:nil];
                                
                            }
                            else {
                                // registered but not active.
                                
                                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                                [details setValue:@"Your limited use of IEV services for this device has ended.\nPlease contact PCSOFT ERP Solutions for enabling IEV services." forKey: NSLocalizedDescriptionKey];
                                NSError *error_device = [NSError errorWithDomain:kErrorDomainDeviceErrors code:-5002 userInfo:details];
                                
                                [self connectionHandler:nil errorRecievingData:error_device];
                            }
                        }
                        else if ([model.IsDeviceRegistered isEqualToString:@"YES"] && [model.IsMobileRegistered isEqualToString:@"NO"]) {
                            
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"Your mobile number is not registered. App will now register your mobile number." preferredStyle:UIAlertControllerStyleAlert];
                            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                
                                PCUpdateMobileNumberViewController *updateMobVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCUpdateMobileNumberViewController"];
                                
                                NSString *accessCode = [NSString stringWithString:_codeTF.text];
                                accessCode = [accessCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                updateMobVC.accessCode = accessCode;
                                NSString *phoneNumber = _phoneNumberTF.text;
                                phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                updateMobVC.phoneNumber = phoneNumber;
                                updateMobVC.delegate = self;
                                [self presentViewController:updateMobVC animated:YES completion:NULL];
                            }]];
                            [self presentViewController:alert animated:YES completion:nil];
                            
                        }
                        else if ([model.IsDeviceRegistered isEqualToString:@"NO"] && [model.IsMobileRegistered isEqualToString:@"YES"]) {
                            
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"You have not registered your device. App will now register your device." preferredStyle:UIAlertControllerStyleAlert];
                            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                
                                [self updateDeviceRegistration];
                                
                            }]];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                        else {
                            // device not registered. Proceed with device registration.
                            [self updateLicenseCount];
                        }
                        
                        
                    });
                    
                }
            }
            else {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"There seems some problem connecting with the server.\nPlease try again after some time." forKey: NSLocalizedDescriptionKey];
                
                NSError *error = [NSError errorWithDomain:kErrorDomainUnwantedOutput code:-5001 userInfo:details];
                
                [self connectionHandler:nil errorRecievingData:error];
            }
        }
        
        
    }];
    
    
}

-(void)updateMobileNumberToServer   {
    
    ConnectionHandler *updateMobileHandler = [[ConnectionHandler alloc] init];
    updateMobileHandler.delegate = self;
    updateMobileHandler.tag = kUpdateMobileNumberTag;
        
    NSString *urlString = [NSString stringWithFormat:@"%@updatemobileno?scocd=%@&deviceid=%@&mobno=%@",
                           kAppBaseURL,
                           _codeTF.text,
                           appDel.appUniqueIdentifier,
                           self.userPhoneNumber];
    
    setupConnectionType = SetupConnectionTypeCheckDevice;
    
    [updateMobileHandler fetchDataForPOSTURL:urlString body:nil completion:^(id responseData, NSError *error) {
        
        
        
    }];
    
    [updateMobileHandler fetchDataForURL:urlString body:nil completion:NULL];
}

-(void)updateDeviceRegistration {
    
    ConnectionHandler *updateDevieRegHandler = [[ConnectionHandler alloc] init];
//    updateDevieRegHandler.delegate = self;
    updateDevieRegHandler.tag = kUpdateDeviceRegisterTag;
    
    NSString *urlString = [NSString stringWithFormat:@"%@updatedeviceid?scocd=%@&deviceid=%@&mobno=%@",
                           kAppBaseURL,
                           _codeTF.text,
                           appDel.appUniqueIdentifier,
                           self.userPhoneNumber];
    
//    [updateDevieRegHandler fetchDataForURL:urlString body:nil completion:NULL];
    
    [updateDevieRegHandler fetchDataForPOSTURL:urlString body:nil completion:^(id responseData, NSError *error) {
        
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *opString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                opString = [opString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if ([opString isEqualToString:@"true"]) {
                    [SVProgressHUD dismiss];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Registration" message:@"Device registered succesfully." preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Registration" message:@"Some unexpected error has occured, could not register the device." preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }
    }];
}

-(void)updateLicenseCount
{
    NSString *accessCode = _codeTF.text;
    
    accessCode = [accessCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *phoneNumber = _phoneNumberTF.text;
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (accessCode.length == 0 || phoneNumber.length==0) {
        [SVProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"You need to provide the access code and your 10-digit phone number to use the application." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self setUserPhoneNumber:phoneNumber];
    
    ConnectionHandler *registerDeviceConnection = [[ConnectionHandler alloc] init];
    registerDeviceConnection.tag = kUpdateLicenseTag;
    
    NSString *urlString = kLicenseAddURL(_codeTF.text);
    //[NSString stringWithFormat:@"%@GetUpdateLic?scocd=%@",kAppBaseURL,_codeTF.text];
    setupConnectionType = SetupConnectionTypeUpdateLicense;
    
    [registerDeviceConnection fetchDataForPOSTURL:urlString body:nil completion:^(id responseData, NSError *error) {
        
        NSError *jsonerror = nil;
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonerror];
        
        if (arr.count > 0) {
            NSDictionary *dict = [arr objectAtIndex:0];
            licenseModel = [[PCDeviceLicenseModel alloc] init];
            [licenseModel setValuesForKeysWithDictionary:dict];
            
             // TODO : 100 needs to be replaced with a definite number.
            int totalLicenses = licenseModel.LIC_NOS==nil?100:[licenseModel.LIC_NOS intValue];
            int usedLicenses = [licenseModel.LIC_USED intValue];
            if (usedLicenses < totalLicenses) {
                [self registerDevice];
            }
            else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"Available licenses for are already used.\nPlease contact your license adminstrator for getting access to the IEV app.\nMeanwhile, you can take a demo tour of the features." preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self startDemo:nil];
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"Error occured during access code verification.\nPlease make sure you have provided a valid access code." preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            });
        }
       
        
    }];
}

- (void)registerDevice
{
    [SVProgressHUD showWithStatus:@"Registering device..."];
    
    NSString *accessCode = [NSString stringWithString:
                            _codeTF.text];
    
    accessCode = [accessCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *phoneNumber = [NSString stringWithString:_phoneNumberTF.text];
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (accessCode.length == 0 || phoneNumber.length==0) {
        [SVProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"You need to provide the access code and your 10-digit phone number to use the application." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    ConnectionHandler *registerDeviceConnection = [[ConnectionHandler alloc] init];
//    registerDeviceConnection.delegate = self;
    registerDeviceConnection.tag = kRegisterDeviceTag;
    
    NSString *urlString = [NSString stringWithFormat:@"%@registerDeviceID?scocd=%@&DeviceId=%@&MobNo=%@",
                           kAppBaseURL,
                           accessCode,
                           appDel.appUniqueIdentifier,
                           phoneNumber];
    
    setupConnectionType = SetupConnectionTypeDeviceRegister;
    
//    [registerDeviceConnection fetchDataForURL:urlString body:nil completion:NULL];
    
    [registerDeviceConnection fetchDataForPOSTURL:urlString body:nil completion:^(id responseData, NSError *error) {
        
        
        NSError *jsonerror = nil;
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonerror];
        
        if (arr.count > 0) {
            NSDictionary *dict = [arr objectAtIndex:0];
            deviceRegisterModel = [[PCDeviceRegisterModel alloc] init];
            [deviceRegisterModel setValuesForKeysWithDictionary:dict];
            
            NSString *activeString = [deviceRegisterModel.ACTIVE stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([activeString isEqualToString:@"A"]) {
                    
                    [self verifyCode:nil];
                }
                else {
                    
                    NSMutableDictionary* details = [NSMutableDictionary dictionary];
                    [details setValue:@"Your limited use of IEV services for this device has ended.\nPlease contact PCSOFT ERP Solutions for enabling IEV services." forKey: NSLocalizedDescriptionKey];
                    NSError *error_device = [NSError errorWithDomain:kErrorDomainDeviceErrors code:-5002 userInfo:details];
                    
                    [self connectionHandler:nil errorRecievingData:error_device];
                }
                
            });
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Device registration failed.\nPlease try again." forKey: NSLocalizedDescriptionKey];
                NSError *error_blank = [NSError errorWithDomain:kErrorDomainBlankOutput code:-5003 userInfo:details];
                
                [self connectionHandler:nil errorRecievingData:error_blank];
                
            });
            
        }
        
    }];
}

-(void)verifyCode:(NSString*)userCode
{
    NSString *accessCode = _codeTF.text;
    
    accessCode = [accessCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *phoneNumber = _phoneNumberTF.text;
    phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (accessCode.length == 0 || phoneNumber.length==0) {
        [SVProgressHUD dismiss];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"You need to provide the access code and your 10-digit phone number to use the application." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Verifying"];
    ConnectionHandler *verifyCode = [[ConnectionHandler alloc] init];
    verifyCode.tag = kGetServiceURLTag;
    
    NSString *urlString =  kVerifyCodeURL(accessCode);  //[NSString stringWithFormat:@"%@%@",kVerifyCodeURL,accessCode];
    setupConnectionType = SetupConnectionTypeUpdateLicense;
    
    [verifyCode fetchDataForPOSTURL:urlString body:nil completion:^(id responseData, NSError *error) {
        
        {
            NSArray *arr;
            __block NSString *errorString;
            
            NSError *jsonerror = nil;
            NSArray *opArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonerror];
            
            id output = opArray;
            
            if ([output isKindOfClass:[NSArray class]]) {
                arr = (NSArray*)output;
                
                if (arr.count > 0) {
                    
                    NSDictionary *dict = [arr objectAtIndex:0];
                    
                    errorString = [[NSString alloc] initWithString:[dict valueForKey:@"ERRORMESSAGE"]];
                    
                    if ([errorString  caseInsensitiveCompare:@"IEVC001"] == NSOrderedSame) {
                        
                        [SVProgressHUD dismiss];
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Register" message:@"Unable to connect to PCSOFT IEV services.\nPlease try again." preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else if ([errorString  caseInsensitiveCompare:@"IEVC002"] == NSOrderedSame)   {
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Register" message:@"Invalid company code provided.\nPlease try again." preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else if ([errorString  isEqualToString:@""])    {
                        companyURL = [[NSString alloc] initWithString:[dict valueForKey:@"WEB_URL"]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (companyURL) {

                                [SVProgressHUD showSuccessWithStatus:@"Verified"];
                                
                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_REGISTRATION_COMPLETE_KEY];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                [defaults setObject:companyURL forKey:kCompanyBaseURL];
                                [defaults synchronize];
                                [appDel setBaseURL:companyURL];
                                
                                [SVProgressHUD showSuccessWithStatus:@"Done"];
                                
                                PCViewController *compListVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCViewController"];
                                [compListVC setTitle:@"Select your company"];
                                
                                [self.navigationController pushViewController:compListVC animated:NO];
                                
//                                [self performSelector:@selector(getUsernamesList) withObject:nil afterDelay:1.0];
                                
                            }
                            else {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    [SVProgressHUD dismiss];
                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid code" message:@"Some unexpected error has occured, could not register the device." preferredStyle:UIAlertControllerStyleAlert];
                                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                    [self presentViewController:alert animated:YES completion:nil];
                                });
                            }
                        });
                    }
                }
                else {
                }
            }
            else if ([output isKindOfClass:[NSString class]])   {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [SVProgressHUD dismiss];
                    errorString = [[NSString alloc] initWithString:responseData];
                    errorString = [errorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    errorString = [errorString substringWithRange:NSMakeRange(1, errorString.length-2)];
                    errorString = [errorString capitalizedString];
                    
                    if ([errorString  caseInsensitiveCompare:@"IEV C001"] == NSOrderedSame) {
                        
                        [SVProgressHUD dismiss];
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Register" message:@"Unable to connect to PCSOFT IEV services.\nPlease try again." preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else if ([errorString  caseInsensitiveCompare:@"IEV C002"] == NSOrderedSame)   {
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Register" message:@"Invalid company code provided.\nPlease try again." preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                });
                return;
            }
            else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [SVProgressHUD dismiss];
                    UIAlertController *msgActionSheet = [UIAlertController alertControllerWithTitle:nil message:@"Some unexpected error has occured, please try again after sometime." preferredStyle:UIAlertControllerStyleAlert];
                    [msgActionSheet addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self dismissViewControllerAnimated:YES completion:NULL];
                    }]];
                    
                    [self presentViewController:msgActionSheet animated:YES completion:NULL];
                    
                });
                
            }
            
        }
        
        
    }];
}

- (void)getUsernamesList
{
    [SVProgressHUD showWithStatus:@"Please wait..."];
    ConnectionHandler *fetchUsers = [[ConnectionHandler alloc] init];
//    fetchUsers.delegate = self;
    fetchUsers.tag = kGetUserNamesListTag;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",companyURL,kUsernamesService];
    
//    [fetchUsers fetchDataForURL:url body:nil completion:NULL];
    
    [fetchUsers fetchDataForPOSTURL:url body:nil completion:^(id responseData, NSError *error) {
        
        {
            if (!usersList) {
                usersList = [[NSMutableArray alloc] init];
            }
            
            NSArray *arr = (NSArray*)responseData;
            
            for (NSDictionary *dict in arr) {
                
                PCUserModel *uMod = [[PCUserModel alloc] init];
                [uMod setValuesForKeysWithDictionary:dict];
                [usersList addObject:uMod];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"Done"];
                
                PCViewController *compListVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCViewController"];
                [compListVC setTitle:@"Select your company"];
                
                [self.navigationController pushViewController:compListVC animated:NO];
            });
        }
        
    }];
}



-(void)connectionHandler:(ConnectionHandler*)conHandler errorRecievingData:(NSError*)error
{
    if ([error code] == -5000) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:@"Internet connection appears to be unavailable.\nPlease check your connection and try again." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            
        });
        return;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IEV" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        });
        return;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [SVProgressHUD dismiss];
    
    switch (alertView.tag) {
        case 100:
            if (buttonIndex == 0) {
                [self startDemo:nil];
            }
            break;
            
        case 101:
            if (buttonIndex == 0) {
                
            }
            else if (buttonIndex == 1) {
                
            }
            break;
            
        case 102:
            if (buttonIndex == 0) {
                
                PCUpdateMobileNumberViewController *updateMobVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCUpdateMobileNumberViewController"];
                
                NSString *accessCode = [NSString stringWithString:
                                        _codeTF.text];
                
                accessCode = [accessCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                updateMobVC.accessCode = accessCode;
                
                NSString *phoneNumber = _phoneNumberTF.text;
                phoneNumber = [phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                updateMobVC.phoneNumber = phoneNumber;
                
                updateMobVC.delegate = self;
                
                [self presentViewController:updateMobVC animated:YES completion:NULL];
                
            }
            else if (buttonIndex == 1) {
                
            }
            break;
            
        case 103:
            if (buttonIndex == 0) {
                
//                [self updateDeviceRegistration];
            }
            else if (buttonIndex == 1) {
                
            }
            break;
            
        default:
            break;
    }
}

-(void)didUpdateMobileNumber:(NSString*)newNumber   {
    
    [self setUserPhoneNumber:newNumber];
    self.phoneNumberTF.text = self.userPhoneNumber;
}

-(void)didCancelUpdatingNumber  {
    
}

-(void)mobileNumberRemainUnchanged  {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
