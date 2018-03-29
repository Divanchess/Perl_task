#6: Заменить все вхождения ‘abc’ на ‘cba’ в текстовом файле.
# Вариант с чтением файла в массив в память
use strict;
use warnings;

# Имя входного файла
my $file = shift @ARGV;

print "\tReplacing abc => cba in $file..\n\n\tProceed..\n";
open (my $in_fh, "<", $file) or die $!;
my @lines = <$in_fh>;
close($in_fh);

open (my $out_fh, ">", $file) or die $!;
foreach my $line (@lines) {
	$line =~ s/abc/cba/g;
	print $out_fh $line;
}

close($out_fh);
print "\tDone!\n";