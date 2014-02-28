# Directory Jump

Use The `Directory Jump` script to save your time to change directory.

# Introduction Video

[![Introduction video](http://img.youtube.com/vi/O5K86e7ymjQ/0.jpg)](http://www.youtube.com/watch?v=O5K86e7ymjQ)

# Usage

````
Usage: 
    dj                 : print directories
    dj [index]         : change directory by index
    dj add             : add current directory
    dj add [dir]       : add directory
    dj rm              : remove current directory
    dj rm [index]      : remove directory by index
    dj save <filename> : save dir list into the file
    dj load <filename> : load dir list from the file
    dj clean           : clean the stack
    dj help            : print usage

Key Map (normal):
    CTRL + Up Arrow       : move previous
    CTRL + Down Arrow     : move next
    CTRL + Left Arrow     : jump down
    CTRL + Right Arrow    : jump up

Key Map (putty + screen):
    ALT + Up Arrow       : move previous
    ALT + Down Arrow     : move next
    ALT + Left Arrow     : jump down
    ALT + Right Arrow    : jump up

Key Map (mac os):
    ESC + Up Arrow       : move previous
    ESC + Down Arrow     : move next
    ESC + Left Arrow     : jump down
    ESC + Right Arrow    : jump up
````

# Installation

the easiest way to install `dj` is to use our `automatic installer`
by simply coping and pasting the following line into a terminal.

````
git clone https://github.com/ygpark/dj
cd dj
./bootstrap.sh
````

