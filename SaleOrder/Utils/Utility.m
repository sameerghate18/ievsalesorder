//
//  Utility.m
//  ERPMobile
//
//  Created by Sameer Ghate on 07/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "Utility.h"

@implementation Utility


+(NSString*)lastRefreshString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterLongStyle];
    NSString *retStr = [dateFormat stringFromDate:[NSDate date]];
    return retStr;
}

+(NSString*)stringWithCurrencySymbolForValue:(NSString*)valStr
{
    
    NSLocale *lcl = [[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"];
                     
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setLocale:lcl];
    [currencyFormatter setMaximumFractionDigits:2];
    [currencyFormatter setMinimumFractionDigits:2];
    [currencyFormatter setAlwaysShowsDecimalSeparator:YES];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *someAmount = [NSNumber numberWithFloat:[valStr floatValue]];
    NSString *string = [currencyFormatter stringFromNumber:someAmount];
    
    return string;
}

+(NSString*)stringWithCurrencySymbolForValue:(NSString*)valStr forCurrencyCode:(NSString*)currencyCode
{
    
//    NSLocale *lcl = [[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
//    [currencyFormatter setLocale:lcl];
    [currencyFormatter setMaximumFractionDigits:2];
    [currencyFormatter setCurrencyCode:currencyCode];
    [currencyFormatter setMinimumFractionDigits:2];
    [currencyFormatter setAlwaysShowsDecimalSeparator:YES];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *someAmount = [NSNumber numberWithDouble:[valStr doubleValue]];
    NSString *string = [currencyFormatter stringFromNumber:someAmount];
    
    return string;
}


+(UIColor *)randomColor
{
    
    CGFloat red = arc4random()% 256 / 256.0;
    CGFloat green = arc4random()% 256 / 256.0;
    CGFloat blue = arc4random()% 256 / 256.0;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    return color;
}

+(NSString*)stringFromDate:(NSDate*)inputDate   {
    
    //2/22/2017 12:00:00 AM
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:kOnlyDateFormat];
    return [format stringFromDate:inputDate];
}

+(NSString*)stringDateFromServerDate:(NSString*)serverDate  {
    //4/2/2016 12:00:00 AM
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss a"];
    NSDate *newDate = [dateFormat dateFromString:serverDate];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *finalString = [dateFormat stringFromDate:newDate];
    return finalString;
}

+(NSDate*)dateFromInputString:(NSString*)inputString    {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:kDateFormat];
    
    return [format dateFromString:inputString];
}
@end
