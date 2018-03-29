#7: Предположим, при выполнении скрипта из предыдущего пункта (замена «abc» на «cba») система выдаёт ошибку «Out of memory». Необходимо решить ту же задачу, с учётом этой проблемы.
use strict;
use warnings;

use Tie::File;

my $file = shift @ARGV;

print "\tReplacing abc => cba in $file..\n\n\tProceed..\n";

tie my @lines, "Tie::File", $file or die $!; #, memory => 20_000_000
s/abc/cba/g for @lines;

print "\tDone!\n";
# Этот вариант значительно медленнее в связи с особенностями работы Tie::File