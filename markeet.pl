#!/usr/bin/perl -w

# Works in conjunction with Twittov (http://www.yaymukund.com/twittov/) to tweet
# its mashings, possibly via cron.

use strict;
use HTML::Entities;
use Net::Twitter::Lite;

################################################################################
# configuration
my $twitter_user = 'username';
my $twittov_path = '/path/to/twittov/bin/'; # twittov parent directory
my $python_path  = '/usr/local/bin/python';
my $consumer_key        = '0000000000000000000000';
my $consumer_secret     = '000000000000000000000000000000000000000000';
my $access_token        = '00000000000000000000000000000000000000000000000000';
my $access_token_secret = '0000000000000000000000000000000000000000000';
################################################################################

my $tweet;
my $attempts = 0;
my $max_attempts = 25;

# go to the directory where twittov lives, so that cached tweets are handy
chdir $twittov_path;

GENERATE:

# keep this madness in check
$attempts++;
($attempts >= $max_attempts) and die "Failed to generate a suitable twittov in $attempts attempts\n";

# get a new tweetov compilation!
$tweet = `$python_path twittov.py -r 12 -l 3 $twitter_user`;

################################################################################
# quality control
$tweet = decode_entities($tweet);
$tweet =~ s/Dug: //; # the prefix to my blog tweets
$tweet =~ s/"//g; # quotes probably won't be matched- kill 'em all
$tweet =~ s/,$//; # kill trailing commas
$tweet =~ s/@[_A-Za-z0-9]+/[redacted]/g; # kill nonsense mentions
$tweet =~ s/#([\w]+)/$1/g; # felt bad about polluting hashtags
$tweet =~ s/http:\/\/[-._a-zA-Z0-9\/\?&=]+//g; # lose all links
$tweet =~ s/RT //g; # lose retweets (they are a lie, anyway)

# can't be longer than 140 characters
(length($tweet) > 140) and goto GENERATE;
################################################################################

# if we've gotten to this point, we have a suitable tweet! Yay!

# Tweet it.
my $twitter = Net::Twitter::Lite->new(
	consumer_key        => $consumer_key,
	consumer_secret     => $consumer_secret,
	access_token        => $access_token,
	access_token_secret => $access_token_secret,
  legacy_lists_api    => 0
);
$twitter->update("$tweet");

print "Twote:\n$tweet\n";
