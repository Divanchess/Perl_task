#4: Создать массив (например, из названий месяцев года). Вывести элементы массива через запятую.
use strict;
use warnings;

my @a = qw( January   February  March
      April     May       June
      July      August    September
      October   November  December );
$, = "," ;
print @a;

# более короткий, но чуть более ресурсоемкий вариант:
# print join( ',', @a );