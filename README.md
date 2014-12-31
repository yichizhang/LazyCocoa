LazyCocoa (former GenColor)
===========================

LazyCocoa is a repository made up of tools and scripts to help you code iOS/Mac applications. It has a Python script to generate a list of all the h files for your Swift Bridging header. Its GenColor component can generate UIColor/ UIFont class methods from a text file. For example, you write 'awesomeColor #FFF'. It generates:

```
+ (UIColor*)awesomeColor{ 

	return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];

}
``` 

## Components

### Swift Bridging Header Generator

```
usage: bridgingheadergenerator.py [-h] [-d DIR] [-o OUTPUTPATH]

optional arguments:
  -h, --help            show this help message and exit
  -d DIR, --dir DIR     directory of header files to scan
  -o OUTPUTPATH, --outputpath OUTPUTPATH
                        path to write the generated bridging header file
```

FOR EXAMPLE:

I have lots of .h files in /Repos/YZLibrary/YZLibraryDemo/YZLibraryDemo ; I would like to quickly generate a Bridging header for Swift. I would the bridging header to be placed at /Repos/YZLibrary/YZLibraryDemo/Bridging-Header.h

I need to run this command:

```
 python bridgingheadergenerator.py -d /Repos/YZLibrary/YZLibraryDemo/YZLibraryDemo -o /Repos/YZLibrary/YZLibraryDemo/Bridging-Header.h
```

PLEASE NOTE: THE OUTPUT FILE WILL BE OVERWRITTEN

### LazyCocoa-MacApp: GenColor/ GenFont

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

Updates
=======


### 26 December 2014

Changed project name to 'LazyCocoa' as I realised I would need to not only generate UIColor/NSColor files but also UIFont/NSFont files and also perhaps other tasks

### 11 December 2014

Project Started