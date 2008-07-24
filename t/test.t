#!perl -w

use Test::More tests => 11;

{
	{
		use constant::private CAKE => 3.14;
		is CAKE, 3.14, 'within a constant\'s scope';
	}
	use constant::private { _foo => 1, _bar => 2 };
	use constant::private _baz => 3,4,5;

	is_deeply [_foo, _bar], [1,2],
		'within the scope of constants created with a hash';
	is_deeply [_baz], [3,4,5], 'within a list constant\'s scope';

	is CAKE, "CAKE", 'outside a constant\'s scope';
}
is_deeply [_foo, _bar], [_foo=>_bar=>],
	'outside the scope of constants created with a hash';
is_deeply [_baz], ["_baz"], 'outside a list constant\'s scope';

use constant thing => 34;
sub thang { 78 }
{
	use constant::private thing => 45;
	use constant::private thang => 79;
	is thing, 45, 'overridden constant';
	is thang, 79, 'overridden sub';
	BEGIN { @thing = 1 }
}
is thang, 78, 'overridden sub restored';
is thing, 34, 'overridden constant restored';
is ${'thing'}[0], 1,'and other glot slobs untouched';
