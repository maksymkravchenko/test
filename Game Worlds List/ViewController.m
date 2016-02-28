//
//  ViewController.m
//  Game Worlds List
//
//  Created by max on 2/27/16.
//  Copyright © 2016 Max. All rights reserved.
//

#import "ViewController.h"

static NSString * const kShowWorldsSegueID = @"ShowWorldList";

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[super viewWillDisappear:animated];
}

- (BOOL)validateEmailAddress:(NSString *)emailString
{
	BOOL result = NO;
	if (emailString != nil)
	{
		NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}";
		NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
		
		result = [emailTest evaluateWithObject:emailString];
	}
	return result;
}

- (IBAction)onMainAction:(id)sender
{
	if ([self validateEmailAddress:self.emailTextField.text] && ![self.passwordTextField.text isEqualToString:@""])
	{
		[self performSegueWithIdentifier:kShowWorldsSegueID sender:self];
	}
	else if (![self validateEmailAddress:self.emailTextField.text])
	{
		[self shakeTextField:self.emailTextField];
		[self.emailTextField becomeFirstResponder];
	}
	else
	{
		[self shakeTextField:self.passwordTextField];
		[self.passwordTextField becomeFirstResponder];
	}
}

- (void)shakeTextField:(UITextField *)textField
{
	const int kMaxShakes = 6;
	const CGFloat kShakeDuration = 0.05;
	const CGFloat kShakeTransform = 4;
	CGFloat direction = 1;
	
	for (int i = 0; i <= kMaxShakes; i++)
	{
		[UIView animateWithDuration:kShakeDuration delay:kShakeDuration * i options:UIViewAnimationOptionCurveEaseIn animations:^{
			 if (i >= kMaxShakes)
			 {
				 textField.transform = CGAffineTransformIdentity;
			 } else
			 {
				 textField.transform = CGAffineTransformMakeTranslation(kShakeTransform * direction, 0);
			 }
		 } completion:nil];
		
		direction *= -1;
	}
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	BOOL result = NO;
	if (textField == self.emailTextField)
	{
		if ([self validateEmailAddress:self.emailTextField.text])
		{
			[self.emailTextField resignFirstResponder];
			[self.passwordTextField becomeFirstResponder];
			result = YES;
		}
		else
		{
			[self shakeTextField:self.emailTextField];
		}
	}
	else
	{
		if (![self.passwordTextField.text isEqualToString:@""])
		{
			if ([self validateEmailAddress:self.emailTextField.text])
			{
				[self.passwordTextField resignFirstResponder];
				[self performSegueWithIdentifier:kShowWorldsSegueID sender:self];
			}
			else
			{
				[self.passwordTextField resignFirstResponder];
				[self.emailTextField becomeFirstResponder];
				[self shakeTextField:self.emailTextField];
			}

			result = YES;
		}
		else
		{
			[self shakeTextField:self.passwordTextField];
		}
	}
	
	return result;
}

@end
