GenColor-Mac
============

An app to generate UIColor/ NSColor class methods from your color settings text file. (I'm still working on it, so still doesn't work yet.)

The goal of this application is:

You have your color (colour) settings file like this:

```
defaultColor #F00
backgroundColor #000

buttonColor defaultColor
myImageViewColor #00F
myBlackColor backgroundColor 
```

Then you press update button. It generates UIColor category files for you:

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
  return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1];
}

+ (UIColor *)myBlackColor {
  return [UIColor backgroundColor];
}
```