#9: Необходимо записать строку в EBCDIC. Как это сделать?
use strict;
use warnings;

use Encode;

# Запишем результат сюда
my $file = "test.ebcdic";

print "\tEncode string to EBCDIC => to file $file\n\n";

open(my $f, ">:encoding(cp37)", $file);
print $f "Hello World!\n";
close $f;

print "\tDone!\n";