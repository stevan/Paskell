#!perl

use v5.36;


package Foo {
    use v5.36;
    use overload (
        '<<' => sub ($self, @others) {  }
        '-' => sub { }
    );
}
