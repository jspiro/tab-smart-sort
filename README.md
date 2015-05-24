# tab-smart-sort package

Sorts tabs into logical order as they are added.

![Image inserted by Atom editor package auto-host-markdown-image](http://i.imgur.com/CahO4eD.gif)

A simple package to order tabs in a logical fashion as they are added.  The order is based on any sort priority of path, extension, and file name.  The order can be customized in settings.  After you use this for a while you will always know where to look in the tab bar.  No more hunting around.

# Installation
  
Enter `apm install tab-smart-sort` into a command window or use the Atom settings pane.

# Usage

Simply install this and every time a new tab is added it will be placed in the location matching the sort specification in settings.  If you open a new pane then the tabs in that pane will be sorted the same way.

Note that this extension only sorts tabs when they are added.  You may move the tabs around manually and they will stay in that position, even after a reload.

# Sort Order Settings

The sorting is based on the file path. There is a setting `Case Sensitive` that applies to the path. 

You specify the priority of the different parts of the path using the `Ordering` setting.  Here are some suggestions ...

- "dir, ext, base". This is the default. The highest priority is the directory, the next highest is the file extension, and the file name is last.
- "ext, base, dir". Group all files of the same type together and sort by file name in each group.  The directory is pretty much ignored.
- "base, ext, dir". Simple ordering by file name.

If a tab has no file path, such as the Settings Pane, it is considered a "special" tab and it is placed on the far left or far right based on the setting `Place Special Tabs On Right` which defaults to the left.

# License

tab-smart-sort is copyright Mark Hahn using the MIT license.

