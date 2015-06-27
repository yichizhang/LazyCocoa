//
//  NSViewExtensions.m
//  The Lazy Cocoa Project
//
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "NSViewExtensions.h"

@implementation NSView (Extensions)

- (BOOL)userInteractionEnabled {
	if ([self respondsToSelector:@selector(isEditable)]) {
		return [(id)self isEditable];
	}
	if ([self respondsToSelector:@selector(isSelectable)]) {
		return [(id)self isSelectable];
	}
	return NO;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
	if ([self respondsToSelector:@selector(setSelectable:)]) {
		[(id)self setSelectable:userInteractionEnabled];
	}
	if ([self respondsToSelector:@selector(setEditable:)]) {
		[(id)self setEditable:userInteractionEnabled];
	}
}

+ (instancetype)newViewWithNibName:(NSString*)nibName {
	NSNib *nib = [[NSNib alloc] initWithNibNamed:nibName bundle:nil];
	NSArray *objects;
	if (![nib instantiateWithOwner:self topLevelObjects:&objects]) {
		// error
	}
		
	id view = nil;
	for (id obj in objects) {
		if ([obj isKindOfClass:[self class]]) {
			view = obj;
			break;
		}
	}
	
	return view;
}

- (void)setupConstraintsMakingViewAdhereToEdgesOfSuperview {
	
	NSView *contentView = self.superview;
	NSView *itemView = self;
	
	self.translatesAutoresizingMaskIntoConstraints = NO;
	
	NSLayoutConstraint *topConstraint =
	[NSLayoutConstraint constraintWithItem:itemView
								 attribute:NSLayoutAttributeTop
								 relatedBy:NSLayoutRelationEqual
									toItem:contentView
								 attribute:NSLayoutAttributeTop
								multiplier:1.0f
								  constant:0.f];
	
	NSLayoutConstraint *leadingConstraint =
	[NSLayoutConstraint constraintWithItem:itemView
								 attribute:NSLayoutAttributeLeading
								 relatedBy:NSLayoutRelationEqual
									toItem:contentView
								 attribute:NSLayoutAttributeLeading
								multiplier:1.0f
								  constant:0.f];
	
	NSLayoutConstraint *bottomConstraint =
	[NSLayoutConstraint constraintWithItem:contentView
								 attribute:NSLayoutAttributeBottom
								 relatedBy:NSLayoutRelationEqual
									toItem:itemView
								 attribute:NSLayoutAttributeBottom
								multiplier:1.0f
								  constant:0.f];
	
	NSLayoutConstraint *trailingConstraint =
	[NSLayoutConstraint constraintWithItem:contentView
								 attribute:NSLayoutAttributeTrailing
								 relatedBy:NSLayoutRelationEqual
									toItem:itemView
								 attribute:NSLayoutAttributeTrailing
								multiplier:1.0f
								  constant:0.f];
	
	[contentView addConstraint:topConstraint];
	[contentView addConstraint:leadingConstraint];
	[contentView addConstraint:bottomConstraint];
	[contentView addConstraint:trailingConstraint];
}

@end
