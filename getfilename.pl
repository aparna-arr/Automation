#!/usr/bin/env perl
use warnings;
use strict;

my ($file) = @ARGV;
die "usage: $0 </filename/with/path.file>\n" unless @ARGV;

my ($name) = $file =~ /(?:.*\/)*([^\.]+)(?:\..+)$/;

print $name;
