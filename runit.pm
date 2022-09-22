#!/usr/bin/perl
use warnings;
use strict;
use Debian::Debhelper::Dh_Lib;

# dh_runit installs scripts as provided by source package.  It would
# be nice to maintainers to allow them to not worry about executable
# bit.
insert_before('dh_fixperms', 'dh_runit');

1;
