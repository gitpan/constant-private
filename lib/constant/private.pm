use 5.008;

package constant::private;

our $VERSION = '0.01';

no constant();
use Sub::Delete;

sub import {
	$^H |= 0x20000; # magic incantation to make %^H work before 5.10
	shift;
	my @const = @_ == 1 && ref $_[0] eq 'HASH' ? keys %{$_[0]} : $_[0];
	my $stashname = caller()."::"; my $stash = \%$stashname;
	push @{$^H{+__PACKAGE__} ||= bless[]}, map {
		my $fqname = "$stashname$_"; my $ref;
		if(exists $$stash{$_} && defined $$stash{$_}) {
			$ref = ref $$stash{$_} eq 'SCALAR'
				? $$stash{$_}
				: *$fqname{CODE};
			delete_sub($fqname);
		}
		[$fqname, $stashname, $_, $ref]
	} @const;
	unshift @_, 'constant';
	goto &{can constant 'import'}
}

sub DESTROY { for(@{+shift}) {
	delete_sub(my $fqname = $$_[0]);
	next unless defined (my $ref = $$_[-1]);
	ref $ref eq 'SCALAR' or *$fqname = $ref, next;
	my $stash = \%{$$_[1]}; my $subname = $$_[2];
	if(exists $$stash{$subname} &&defined $$stash{$subname}) {
		my $val = $$ref;
		*$fqname = sub(){$val}
	} else { $$stash{$subname} = $ref }
}}

1;

__END__

=head1 NAME

constant::private - Perl pragma to declare private compile-time constants

=head1 VERSION

0.01 (beta)

=head1 SYNOPSIS

  use constant::private DEBUG => 0;
  {
          use constant::private PI => 4 * atan2 1, 1;
          use constant::private DEBUG => 1;

          print "Pi equals ", PI, "...\n" if DEBUG;
  }
  print "just testing...\n" if DEBUG; # prints nothing
                                        (DEBUG is 0 again)
  use constant::private \%hash_of_constants;
  use constant::private WEEKDAYS => @weekdays; # list

  use constant 1.03 ();
  use constant::private { PIE        => 4 * atan2(1,1),
                          CHEESECAKE => 3 * atan2(1,1),
                         };

=head1 DESCRIPTION

This module creates compile-time constants in the manner of
L<constant.pm|constant>, but makes them local to the enclosing scope.

=head1 WHY?

I sometimes use these for objects that are blessed arrays, which are
faster than hashes. I use constants instead of keys, but I don't want them
exposed as methods, so this is where private constants come in handy.

=head1 PREREQUISITES

This module requires L<perl> 5.8.0 or later and L<Sub::Delete>, which you 
can
get from the CPAN.

If you want to create multiple constants in a single C<use> statement, you
will need C<constant> version 1.03 or higher.

=head1 BUGS

These constants are no longer available at run time, so they won't work
in a string C<eval> (unless, of course, the C<use> statement itself is 
inside the
C<eval>).

These constants actually are accessible to other scopes during
compile-time, as in the following example:

  sub foo { print "Debugging is on\n" if &{'DEBUG'} }
  {
          use constant::private DEBUG => 1;
          BEGIN { foo }
  }

If you switch to another package within a constant's scope, it (the 
constant) will
apparently disappear.

I may be able to solve these three issues if/when perl introduces lexical
subs.

If you find any other bugs, please report them to the author via e-mail.

=head1 ACKNOWLEDGEMENTS

The idea of using C<%^H> was stolen from L<namespace::clean>.

=head1 AUTHOR & COPYRIGHT

Copyright (C) Father Chrysostomos (sprout at, um, cpan dot org)

This program is free software; you may redistribute or modify it (or both)
under the same terms as perl.

=head1 SEE ALSO

L<constant>, L<Sub::Delete>, L<namespace::clean>

=cut
