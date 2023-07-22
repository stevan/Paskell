#!perl

use v5.36;
no warnings 'once';

use Test::More;
use Test::Differences;

use Data::Dumper;
use BEGIN::Lift;
use Devel::Hook;
use PadWalker qw[ peek_my set_closed_over ];

=pod

Experiment for an alternate syntax for matching messages.

Something like this:

```
  # make sure this is know at compile time ...
  use protocol *FooBar::PROTOCOL => ( *Foo, *Bar );

  sub FooBar ($this, $msg) {
      receive [ *FooBar::PROTOCOL ] => {
          *Foo => sub { 'BAR' },
          *Bar => sub { 'FOO' },
      };
  }
```

It needs much more refinement, but the idea here is
that we can do a couple things at compile time, such as:

- capture the set of handlers at compile time
    - this prevents the re-compilation that happens if
      you do not assign the handlers to a `state` variable
    - these values are actually accessible earlier than
      normal, whereas with a `state` or `my` variable they
      are not available until the first call to the sub.
- check that all events in a protocol are implemented
  at compile time
    - If we specify the protocol to use, and that is resolvable
      at compile time, we can verify that all events are
      accounted for in the `receive` block
    - this does mean we have to know the protocol at compile
      time, but that can be worked with.

See Also:

https://metacpan.org/release/STEVAN/BEGIN-Lift-0.07/source/Lift.xs

- this above code could be re-worked to handle our needs explictly
  and maybe return a more sensible OP than the NULLLIST one.


=cut


BEGIN {
    my ($pkg, $method) = ('main', 'where');

    my $receivers = {};
    my $cv; $cv = eval q[
        sub {

            my $pad = peek_my(1);
            warn Dumper $pad;

            foreach my $sub ( values %$receivers ) {
                set_closed_over( $sub, $pad );
            }

            $receivers;
        }
    ];
    if ( $@ ) {
        die "Got error: $@";
    }

    warn "CV: $cv\n";

    {
        no strict 'refs';
        die "Cannot install the lifted keyword ($method) into package ($pkg) when that typeglob (\*${pkg}::${method}) already exists"
            if exists ${"${pkg}::"}{$method};
        *{"${pkg}::${method}"} = $cv;
    }

    my $keyword_handler = sub {
        #warn "HELLO FROM BEGIN";
        warn Dumper \@_;

        my $protocol  = $_[0];
           $receivers = $_[1];
        {
            no strict 'refs';
            my $p = *{$protocol}{SCALAR};
            #warn Dumper $p;
            foreach my $e ( @$$p ) {
                #warn "checking for $e";
                die "You must supply a handler for $e"
                    unless exists $receivers->{ $e }
            }

            warn "receivers: $receivers";
        }
    };

    Sub::Name::subname( "${pkg}::${method}", $keyword_handler );

    BEGIN::Lift::Util::install_keyword_handler(
        $cv, sub { $keyword_handler->( $_[0] ? $_[0]->() : () ) }
    );

    Devel::Hook->unshift_UNITCHECK_hook(sub {
        #warn "REMOVING KEYWORD";
        no strict 'refs';
        delete ${"${pkg}::"}{$method};
    });
}

BEGIN {
    *FooBar   = \[ *Foo, *Bar ];
    *BazGorch = \[ *Baz, *Gorch ];
};

sub match ($msg, $table) {
    warn "Calling: " .(caller(1))[3];
    warn Dumper $msg;
    warn Dumper $table;
    warn "table: $table";

    $table->{ $msg }->();
}

sub FooBar ($msg, $x) {

    match $msg, where *FooBar => {
        *Foo => sub { "FOO ($x)" },
        *Bar => sub { "BAR ($x)" },
    };
}

#sub BazGorch ($msg, $x) {
#    match $msg, where *BazGorch => {
#        *Baz   => sub { "BAZ ($x)" },
#        *Gorch => sub { "GORCH ($x)" },
#    };
#}

is( FooBar( *Foo, 10 ), 'FOO (10)', '... got the expected result');
is( FooBar( *Bar, 20 ), 'BAR (20)', '... got the expected result');
#is( BazGorch( *Baz, 300 ), 'BAZ (300)', '... got the expected result');
#is( BazGorch( *Gorch, 202 ), 'GORCH (20)', '... got the expected result');


done_testing;

1;

__END__
