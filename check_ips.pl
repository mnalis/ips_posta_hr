#!/usr/bin/perl -wT
# Matija Nalis <mnalis-perl@voyager.hr> 2010-11-18, GPLv3+
# prints any changes to packages status

use strict;

my $DEBUG=0;
my $SPOOL_DIR='/var/local/ips_posta_hr';
my $AGENT_ID='check_ips/0.1 ';

$ENV{'PATH'}='/usr/local/bin:/usr/bin:/bin';


#
# no user serviceable parts below
#

use HTML::TableExtract;
use LWP::UserAgent;
use Data::Dumper qw(Dumper);

my $ua = LWP::UserAgent->new;
$ua->agent($AGENT_ID);

# parses HTML file on disk
sub parse_raw_html($)
{
         my ($TRACKID) = @_;
         
         my $rawfile = "${SPOOL_DIR}/$TRACKID.raw";
         my $parsedfile = "${SPOOL_DIR}/$TRACKID.txt";
         my $newfile = "${parsedfile}.new";
         my $te = HTML::TableExtract->new( headers => [ 'Local Date and Time', 'Country', 'Location', 'Event Type', 'Extra Information' ] );	# match table with this specific headers
         $te->parse_file($rawfile);
         my $table = $te->first_table_found;

         $DEBUG && print "Table  found at ", join(',', $table->coords), ":\n";
         open TXT, '>', $newfile or die "can't create $newfile: $!";
         foreach my $row ($table->rows) {
                no warnings;
                my $line = join(',', @$row);
                use warnings;
                $DEBUG && print "    x $line\n";
                print TXT "$line\n" or die "can't write to $newfile: $!";
         }
         close (TXT) or die "can't write-close $newfile: $!";

         my $diff = undef;
         if (-r $parsedfile) {
                $DEBUG && print "Found $parsedfile, diff to $newfile\n";
                $diff = `diff $parsedfile $newfile | egrep '^[<>]'`;
         } else {
                $DEBUG && print "No $parsedfile, diff /dev/null to $newfile\n";
                $diff = `diff /dev/null $newfile | egrep '^[<>]'`;
         }
         if ($diff) {
                print "\n*** Changes found for tracked package# $TRACKID\n";
                print "$diff";
#                rename $newfile, $parsedfile or die "can't rename $newfile to $parsedfile: $!";
         }
                                                           
}

# gets raw HTML for package, and calls parse_raw_html() to parse it
sub request_package_status($)
{
         my ($TRACKID) = @_;
         
         $DEBUG && print "\nRequesting package with tracking# $TRACKID\n";
         my $rawfile = "${SPOOL_DIR}/$TRACKID.raw";
         my $tmpfile = "${rawfile}.tmp";
         open RAW, '>', $tmpfile or die "can't write to $tmpfile: $!";
         
         # Create a request
         my $req = HTTP::Request->new(GET => "http://ips.posta.hr/IPSWeb_item_events.asp?itemid=$TRACKID");

         # Pass request to the user agent and get a response back
         my $res = $ua->request($req);

         # Check the outcome of the response
         if ($res->is_success) {
             print "CONTENT: " . $res->content if $DEBUG > 2;
             print RAW $res->content;
             close RAW;
             rename $tmpfile, $rawfile or die "can't rename $tmpfile to $rawfile: $!";
             parse_raw_html($TRACKID);
         }
         else {
             print "HTTP REQUEST FOR TRACKING# $TRACKID failed with ", $res->status_line, "\n";
         }
}


############### MAIN loop ################
 

request_package_status ('RB116484508HK');
request_package_status ('RT073116092HK');
#request_package_status ('RT071604146HK');
