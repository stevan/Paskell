package Paskell::Type::TaggedUnion;
use v5.36;

use parent 'Paskell::Type';
use slots (
    cases => sub {},
);

sub cases ($self) { $self->{cases} }

1;

__END__

=pod

=cut
