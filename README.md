CueTableReloader
================

A really handy class that automatically figures out insertions, deletions, moves, and reloads in UITableView 
based on unique item keys.

#Usage
1. Ensure that your data model consists of a two level array: `[sections][rows]`. 
1. Implement the `CueTableItem` protocol on all of your data objects and ensure that all of your keys are 100% unique.
1. Replace all reloadData calls with calls to CueTableReloader's `reloadData:animated:`.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.objc
CueTableReloader *reloader = [[CueTableReloader alloc] initWithTableView:tableView];

/* ... */

// Replace all calls to [tableView reloadData] with this.
[reloader reloadData:sections animated:YES];
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Limitations
This class works very well for insertions and deletions within the same section. It does its best when existing items reorder
relative to each other. Any travel from one section to another is treated as a delete+insert.

####Known Bugs
* Some complex transitions involving reordering can cause a non-animated reload. Pull requests welcome.

# License

Apache License version 2.0

# Authors

[Cue](http://www.cueup.com)


_Created as part of [Back On The Map](https://objectivechackathon.appspot.com)._
