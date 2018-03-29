#11: Реализовать ежедневную загрузку данных из конфигурационного csv-файла в mysql db. Загрузка должна выполняться посредством полной замены данных в таблице БД. Загрузка файла может быть признана успешной, только если ни в одной из записей файла не найдено ошибок.

## Предположим у нас входной файл содержит 3 колонки: title, url, target (см. файл input.csv)
## и таблица links в БД имеет такую же структуру
use warnings;

use DBI;
use Encode;
use Text::CSV_XS;
 
# Параметры подключения к MySQL (phpmyadmin: http://www.phpmyadmin.co )
my $host = "sql11.freemysqlhosting.net";
my $database = "sql11229506";
my $username = "sql11229506";
my $password = "qvkXnan9T5";
my $dsn = "DBI:mysql:database=$database:host=$host";
# Рабочая таблица
my $table = "links";
# Входной csv файл 
my $file = shift @ARGV;

print "\tRunning..\n\n";

# Подключимся к MySQL
my %attr = (PrintError=>0, RaiseError=>1);
my $dbh = DBI->connect($dsn,$username,$password, \%attr);

# Если еще нет таблицы - создадим, если есть - очистим
if (!check_table_exists($dbh, $table)) {
	my $sql = "CREATE TABLE $table (
	   link_id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
	   title varchar(255),
	   url varchar(255),
	   target varchar(45)
	 ) ENGINE=InnoDB;";
	$dbh->do($sql);
	print "\tTable created successfully!\n";
} else {
	my $sql = "TRUNCATE TABLE $table;";
	$dbh->do($sql);
	print "\tTable truncated successfully!\n";
}

# Подготовим запрос с параметрами
my $sth = $dbh->prepare("INSERT INTO links (title,url,target) VALUES (?, ?, ?);");

# Откроем и прочитаем csv файл
open(my $data, '<:encoding(utf8)', $file) or die "Could not open '$file' $!\n";
my $csv = Text::CSV_XS->new({
	'binary' => 1,
	'auto_diag' => 1,
	'sep_char' => ","
});

# Заполним таблицу данными, пройдя построчно csv файл, кроме 1ой строки
print "\tWriting data in table '$table'...\n";
while (my $row = $csv->getline( $data )) {
	$sth->execute( @$row ) unless $. == 1;
}
if (not $csv->eof) {
	$csv->error_diag();
}
close $data;
print "\tDone!\n";
$dbh->disconnect();

# Проверка существует ли таблица
sub check_table_exists {
    my ($dbh,$table_name) = @_;

    my $sth = $dbh->table_info(undef, undef, $table_name, 'TABLE');

    $sth->execute;
    my @info = $sth->fetchrow_array;

    my $exists = scalar @info;
    return $exists;
}
