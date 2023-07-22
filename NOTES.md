
# type definitions

```
type SYMBOL => CHECK;
type SYMBOL => CHECK => %PARAMS;
```

# type aliases

```
type SYMBOL => SYMBOL;
type SYMBOL => SYMBOL => %ARGS;
```

# type tuples

```
type SYMBOL => [ SYMBOL, ... ];
type SYMBOL => [ SYMBOL, [ SYMBOL, ... ], ... ];

```

# tuples with constructors

```
datatype [CONSTRUCTOR => SYMBOL] => ( SYMBOL, ... );
```

# tuple typeclasses

```
typeclass[SYMBOL] => {

    # accessor ...
    method NAME => SYMBOL;

    # method ... (DIY args checking)
    method NAME => CODE;
}
```

# tagged unions

```
datatype SYMBOL => (
    case CONSTRUCTOR => ( SYMBOL, ... );
    case CONSTRUCTOR => ( SYMBOL, ... );
);

```

# tagged union typeclasses

```
typeclass[SYMBOL] => {

# symbol accessors and destructuring accessors

    # common accessor for all variants
    method NAME => SYMBOL;

    # accessor for each variant
    method NAME => {
        CONSTRUCTOR => SYMBOL,
        CONSTRUCTOR => SYMBOL,
    };

    # destructuring accessor for each variant
    method NAME => {
        CONSTRUCTOR => CODE,
        CONSTRUCTOR => CODE,
    };

    # mixed destructuring accessor or accessor for each variant
    method NAME => {
        CONSTRUCTOR => SYMBOL,
        CONSTRUCTOR => CODE,
    };

# methods

    # method for all variants (DIY args checking)
    method NAME => CODE;

    # method for each variant w/ args checking
    method NAME => [ SYMBOL, ... ] => {
        CONSTRUCTOR => CODE,
        CONSTRUCTOR => CODE,
    };

}

```



















