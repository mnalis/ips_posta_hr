#!/usr/bin/perl -wT
# Matija Nalis <mnalis-perl@voyager.hr> 2010-11-18, GPLv3+
# prints any changes to packages status

use strict;

my $DEBUG=1;
my $SPOOL_DIR='/var/local/ips_posta_hr';
my $AGENT_ID='check_ips/0.1 ';


#
# no user serviceable parts below
#

use HTML::TableExtract qw(tree);
use LWP::UserAgent;
use Data::Dumper qw(Dumper);

my $ua = LWP::UserAgent->new;
$ua->agent($AGENT_ID);

# parses HTML file on disk
sub parse_raw_html($)
{
         my ($TRACKID) = @_;
         
 my $rawfile = "${SPOOL_DIR}/$TRACKID.raw";
 my $te = HTML::TableExtract->new( attribs => { width => '95%' } );	# match table with this specific attributes
 $te->parse_file($rawfile);
 my $table = $te->first_table_found;
 my $table_tree = $table->tree;
# $table_tree->cell(4,4)->replace_content('Golden Goose');
 my $table_html = $table_tree->as_HTML;
 my $table_text = $table_tree->as_text;
 my $document_tree = $te->tree;
 my $document_html = $document_tree->as_HTML;

 my $g = $table->row(0);
 print "xxxX:" . Dumper ($g);
# print "table has " . $table->rows() . " rows\n";
}

# gets raw HTML for package, and calls parse_raw_html() to parse it
sub request_package_status($)
{
         my ($TRACKID) = @_;
         
         $DEBUG && print "Requesting package with tracking# $TRACKID\n";
         my $rawfile = "${SPOOL_DIR}/$TRACKID.raw";
         open RAW, '>', $rawfile or die "can't write to $rawfile: $!";
         
         # Create a request
         my $req = HTTP::Request->new(GET => "http://ips.posta.hr/IPSWeb_item_events.asp?itemid=$TRACKID");

         # Pass request to the user agent and get a response back
         my $res = $ua->request($req);

         # Check the outcome of the response
         if ($res->is_success) {
             print "CONTENT: " . $res->content if $DEBUG > 2;
             print RAW $res->content;
             close RAW;
             parse_raw_html($TRACKID);
         }
         else {
             print "HTTP REQUEST FOR TRACKING# $TRACKID failed with ", $res->status_line, "\n";
         }
}


############### MAIN loop ################
 

request_package_status ('RB116484508HK');
#request_package_status ('RT073116092HK');
#request_package_status ('RT071604146HK');
