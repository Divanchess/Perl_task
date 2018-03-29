#5: У нас есть массив с дублирующимися элементами. Получите массив без дубликатов.
use strict;
use warnings;

my @array = qw(one two three two three two four);

# Вариант1. Вычислим, пройдя по списку в цикле и получив хэш, где ключи - и будут нужные нам уникальные значения. (порядок в получившемся списке будет соответствовать прохождению в цикле по исходному массиву)
sub variant1 {
	my @unique = ();
	my %seen   = ();
	foreach my $elem ( @_ ) {
		next if $seen{ $elem }++;
		push @unique, $elem;
	}
	@unique;
}
# Вариант2. Можно просто записать в хэш все значения списка, используя map - исходная сортировка массива не соблюдается.
sub variant2 {
	my %hash = map {$_, 1} @_;
	my @unique = keys %hash;
}

my @var1_filtered = &variant1(@array);
my @var2_filtered = &variant2(@array);

print "Variant 1:\t @var1_filtered\n";
print "Variant 2:\t @var2_filtered\n";