use 5.008;

package constant::private;

our $VERSION = '0.02';

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

0.02

=head1 DESCRIPTION

B<Warning:> This module is B<deprecated>. Don't use it. Look at 
L<constant::lexical> instead.

=head1 AUTHOR & COPYRIGHT

Copyright (C) Father Chrysostomos (sprout at, um, cpan dot org)

This program is free software; you may redistribute or modify it (or both)
under the same terms as perl.

=head1 SEE ALSO

L<constant::lexical>

=cut
