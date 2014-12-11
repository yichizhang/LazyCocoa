GenColor-Mac
============

GenColor is a Mac app written in Swift to help you generate UIColor/ NSColor class methods from your color settings text file. For example, you write 'awesomeColor #FFF'. It generates +(UIColor*)awesomeColor{ return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1]; } 

![Screenshot 1](https://raw.githubusercontent.com/yichizhang/GenColor-Mac/master/Screenshots/screen1.png)

The goal of this application is:

You have your color (colour) settings file like this:

```
defaultColor #F00
backgroundColor #000

buttonColor defaultColor
myImageViewColor #00F
myBlackColor backgroundColor 
```

Then you press update button. It generates UIColor/ NSColor files for you. (NSColor is not supported yet) The above settings file would generate UIColor Objective-C class methods like:

```
+ (UIColor *)defaultColor {
  return [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1];
}

+ (UIColor *)backgroundColor {
  return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1];
}

+ (UIColor *)buttonColor {
  return [UIColor defaultColor];
}

+ (UIColor *)myImageViewColor {
  return [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1];
}

+ (UIColor *)myBlackColor {
  return [UIColor backgroundColor];
}
```