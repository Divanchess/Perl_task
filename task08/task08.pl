#8: Предположим, предыдущую активность мы хотим выполнять регулярно (раз в минуту). Файлы приходят во входящую директорию, результирующие должны сохраняться в отдельной, оригиналы должны сохраняться. Модифицируйте скрипт в соответствии с вышеозначенным.
use strict;
use warnings;

# Для обработки нажатых клавиш:
use Term::ReadKey;
our $key;
use File::Spec;

# ОС-независимый file path separator
our $sep = File::Spec->catfile('', '');
# Директория входных файлов:
our $in_dir = shift @ARGV;
# Директория для сохранения результирующих файлов:
our $out_dir = shift @ARGV;
# Расширение результирующего файла
our $backup_extension = "_modified";
# Интервал повторения скрипта (в секундах)
our $interval = 60;



# Создадим директорию для выходных файлов, если её нет
if (!(-e $out_dir and -d $out_dir)) {
	print "Result folder $out_dir does not exists, creating..\n";
	mkdir $out_dir, 0755 or warn "Cannot make result folder: $!\n";
}

# Исполнять каждую 1 минуту
print "== Press any key to exit: == \n";
print "\tNow working...\n\n";
while ( 1 ) {
	&working_process();
	exit if (defined ($key = ReadKey($interval)));
	#TODO: write_log_file;
}

# Обработчик
sub working_process {
	opendir my $in_fh, $in_dir or die "Cannot open $in_dir: $!\n";
	opendir my $out_fh, $out_dir or die "Cannot open $out_dir: $!\n";
	
	my @list_in = &read_dir($in_fh);
	my @list_out = &read_dir($out_fh);
	print "In input  dir:\n\t @list_in\n";
	print "In output dir:\n\t @list_out\n";
	s/$backup_extension//g for @list_out;
	my %diff;
	@diff{ @list_out }= ();
	my @files_to_edit = grep !exists($diff{$_}), @list_in;
	@files_to_edit > 0 ? print "Files to edit:\n\t @files_to_edit\n===========\n\n" : print "No files to edit\n===========\n\n";
	
	foreach my $file (@files_to_edit) {
		my $input_file = $in_dir.$sep.$file;
		my $output_file = $out_dir.$sep.$file.$backup_extension;
		&process_single_file($input_file, $output_file);
	}
	
	closedir($in_fh);
	closedir($out_fh);
}

# Получение списка файлов директорий
sub read_dir {
	my $dir_fh = shift;
	my @dots = grep { (!/^\./)} readdir($dir_fh);
	rewinddir $dir_fh;
	@dots;
}
# Изменение и запись измененного файла
sub process_single_file {
	my ($in, $out) = @_;
	my ($input, $output);
	unless (open($input, "<", $in)) {
		print STDERR "Can't open $in for read: $!\n";
		return;
	}
	unless (open($output, ">", $out)) {
		print STDERR "Can't open $out for write: $!\n";
		return;
	}
	while (<$input>) {
		$_ =~ s/abc/cba/g;
		print $output $_;
	}
	close($input);
	close($output);
}
