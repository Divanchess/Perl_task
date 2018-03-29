# 10: Написать скрипт для архивирования (zip’ования) файлов старше недели и заливки их на фтп.
use strict;
use warnings;

use Net::FTP;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use POSIX qw(strftime);
use File::Spec;

# Параметры FTP соединения
my ($ftp, $host, $user, $pass, $ftp_dir);
$host = "demo.wftpserver.com";
$user = "demo-user";
$pass = "demo-user";
$ftp_dir = "upload";
# ОС-независимый file path separator
our $sep = File::Spec->catfile('', '');
# Директории:
my ($files_dir, $arch_dir, $arch_done, $files_done);
# Директория обработки файлов:
$files_dir = shift @ARGV;
# Директория для архивов:
$arch_dir = $files_dir.$sep."archives";
# Директория загруженных на FTP архивов
$arch_done = $arch_dir.$sep."done";
# Директория обработанных файлов
$files_done = $files_dir.$sep."done";
# Файлы старше скольки дней с момента модификации подлежат архивированию
my $days = 7;
# Название архива:
my $time = strftime "%m%d%Y%H%M%S", localtime;
my $arch_name = $time.".zip";
my $arch_full_name = $arch_dir.$sep.$arch_name;

# Создадим директории если нет
mkdir $arch_dir, 0755 if (!(-e $arch_dir and -d $arch_dir));
mkdir $arch_done, 0755 if (!(-e $arch_done and -d $arch_done));
mkdir $files_done, 0755 if (!(-e $files_done and -d $files_done));

# Откроем директорию с файлами
opendir my $dir_fh, $files_dir or die "Cannot open $files_dir: $!\n";

# Создадим объект архива
my $zip = Archive::Zip->new();
# Добавим файлы в архив
my @to_zip;
while (readdir $dir_fh) {
    next if (/^\./);
	our $file = $_;
	our $file_path = $files_dir.$sep.$file;
	if (( -M $file_path > $days ) && ( -f $file_path ||  -l $file_path ) && ( -r $file_path )) {
		my $file_member = $zip->addFile( $file_path, $file ) ;
		push @to_zip, $file;
	}
}
# Если у нас есть элементы для архивирования
if (@to_zip > 0) {
	# Сохраним файл архива
	unless ( $zip->writeToFileNamed($arch_full_name) == AZ_OK ) {
	   die "Archive couldn't be saved. write error";
	}

	# Переместим обработанные файлы
	rename($files_dir.$sep.$_, $files_done.$sep.$_) for @to_zip;

	# Загрузим на FTP и переместим в папку с обработанными архивами
	$ftp = Net::FTP->new($host, Debug => 0);
	$ftp->login($user, $pass) || die $ftp->message;
	$ftp->cwd($ftp_dir);
	$ftp->binary();
	$ftp->put($arch_full_name) || die $ftp->message;
	$ftp->quit;
	
	# Переместим обработанный архив
	rename($arch_full_name, $arch_done.$sep.$arch_name);
	print "\tDone! Archive $arch_done$sep$arch_name moved to FTP.\t".$ftp->message."\n\n\tFTP credentials:\n\t\t host: $host\n\t\t user: $user\n\t\t password: $pass\n";
} else {
	print "\tNothing to archive. Closing..\n";
}