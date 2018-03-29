#7: Предположим, при выполнении скрипта из предыдущего пункта (замена «abc» на «cba») система выдаёт ошибку «Out of memory». Необходимо решить ту же задачу, с учётом этой проблемы.
use strict;
use warnings;

# Имя входного файла:
my $file = shift @ARGV;

print "\tReplacing abc => cba in $file..\n\n\tProceed..\n";
# Сохраним исходный файл в резервную копию
rename($file, $file.".bak");
print "\tCreated backup file $file.bak.\n";

open (my $in_fh, "<", $file.".bak") or die $!;
open (my $out_fh, ">", $file) or die $!;

while (<$in_fh>) {
	$_ =~ s/abc/cba/g;
	print $out_fh $_;
}

close($in_fh);
close($out_fh);
print "\tDone!\n";

# Удалим резервную копию исходного файла
# unlink $file.".bak";

## ИЛИ короткая запись для запуска из командной строки с аргументом имени файла:    task07_v1.pl abc.txt
#	$^I = ".bak";
#	while (<>) {
#		s/abc/cba/g;
#		print;
#	}
#  ТО ЖЕ в одну строку:
#  perl -pi.bak -e "s/abc/cba/g" abc.txt