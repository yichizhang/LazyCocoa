'''
 Copyright (c) 2015 Yichi Zhang
 https://github.com/yichizhang
 zhang-yi-chi@hotmail.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'''

import os
import sys
import argparse

def writefile (string, outputpath):
	
	fout = open(outputpath, 'w')
	fout.write(string)
	fout.close()

	return	
		
def shouldfilebeimported (filename):
	flag = False
	if filename.startswith('._'):
		flag = False
	elif filename.lower().find('bridging-header') > 0:
		flag = False
	else:
		if filename.endswith('.h'):
			flag = True
	
	return flag

# Main program

def main (rootdir, outputpath):

	headerstring = "//\n//  Use this file to import your target's public headers that you would like to expose to Swift.\n//\n\n";

	for subdir, dirs, files in os.walk(rootdir):
		for file in files:
			if shouldfilebeimported (file):
				headerstring = headerstring + '#import "' + file + '"\n'

	writefile(headerstring, outputpath)

	return

if __name__ == "__main__":
	parser = argparse.ArgumentParser()

	parser.add_argument('-d', '--dir', help="directory of header files to scan")
	parser.add_argument('-o', '--outputpath', help="path to write the generated bridging header file")

	args = parser.parse_args()

	if args.dir is None:
		rootdir = os.path.dirname(os.path.realpath(__file__))
		print "No directory specified; using: " + rootdir
	else:
		rootdir = args.dir

	if args.outputpath is None:
		print "No out put file specified."
		exit(1)
	else:
		outputpath = args.outputpath

	main(rootdir, outputpath)