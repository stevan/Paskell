package Paskell::Type::Tuple;
use v5.36;

use parent 'Paskell::Type';
use slots (
    definition  => sub {},
    constructor => sub {},
);

sub definition ($self) { $self->{definition}->@* }

sub has_constructor ($self) { !! $self->{constructor} }
sub constructor     ($self) {    $self->{constructor} }

1;

__END__

=pod

=cut
