package Paskell::Type::Tuple::Constructor;
use v5.36;

use parent 'Paskell::Type';
use slots (
    constructor => sub {},
    definition  => sub {},
);

sub definition ($self) { $self->definition->@* }

1;

__END__

=pod

=cut
