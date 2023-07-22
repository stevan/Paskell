#!perl

use v5.36;

use Test::More;
use Test::Differences;

use Data::Dumper;

use ok 'ELO::Types', qw[ :core :types ];


type *a => sub ($type) { !! lookup_type($type) };
type *b => sub ($type) { !! lookup_type($type) };

datatype [ FooBar => *FooBar ] => (
    *Str,
    { *Option => [ *Str ] },
);

FooBar( "Foo", Some[*Str]->("Bar") );

datatype { *Option => [ *a ] } => sub {
    case None => ();
    case Some => ( *a );
};

typeclass[ { *Option => [ *a ] } ] => sub {

    method get => {
        Some => *a,
        None => sub () { die 'Cannot call get on None' },
    };

    method get_or_else => [ *CodeRef ] => +{
        Some => sub ($o, $) { $o->get },
        None => sub ($, $f) { $f->() },
    };

    method or_else => [ *CodeRef ] => +{
        Some => sub ($o, $) { Some[*a]->($o->get) },
        None => sub ($, $f) { $f->() },
    };

    method is_defined => {
        Some => sub { 1 },
        None => sub { 0 },
    };

    method is_empty => {
        Some => sub { 0 },
        None => sub { 1 },
    };

    method map => [ *CodeRef ] => +{
        Some => sub ($o, $f) { Some[*a]->($f->($o->get)) },
        None => sub ($,   $) { None() },
    };

    method filter => [ *CodeRef ] => +{
        Some => sub ($o, $f) { $f->($o->get) ? Some($o->get) : None() },
        None => sub ($,   $) { None() },
    };

    method foreach => [ *CodeRef ] => +{
        Some => sub ($o, $f) { $f->($o->get) },
        None => sub ($,   $) { () },
    };

};

sub get ($req, $key) {
    exists $req->{ $key } ? Some[*Str]->( $req->{ $key } ) : None;
}

my $req = { name => 'Stevan' };

my $upper = request_param($req, 'name') #/ get value from hash
    ->map    (sub ($x) { $x =~ s/\s$//r }) #/ trim any trailing whitespace
    ->filter (sub ($x) { length $x != 0 }) #/ ignore if length == 0
    ->map    (sub ($x) { uc $x          }) #/ uppercase it
;

is($upper->get_or_else(''), 'STEVAN', '... got the result we expected');

=cut

done_testing;



