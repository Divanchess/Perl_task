#12: Напишите программу для вычисления факториала.
# для запуска используйте: 		10.pl <число>
# n! = n * ( n - 1 )!
sub factorial {
	my $n=shift;
	return 1 unless $n;
	return $n*factorial($n-1);
}

print factorial(shift @ARGV), "\n";