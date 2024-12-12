[![Actions Status](https://github.com/raku-community-modules/PostCocoon-Url/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/PostCocoon-Url/actions) [![Actions Status](https://github.com/raku-community-modules/PostCocoon-Url/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/PostCocoon-Url/actions) [![Actions Status](https://github.com/raku-community-modules/PostCocoon-Url/actions/workflows/windows.yml/badge.svg)](https://github.com/raku-community-modules/PostCocoon-Url/actions)

NAME
====

PostCocoon::Url - Some simple but useful URL utils

SYNOPSIS
========

```raku
use PostCocoon::Url;

say url-encode("👌");           # %F0%9F%91%8C
say url-decode("%F0%9F%91%8C"); # 👌
```

DESCRIPTION
===========

A collection of functions that can be used for URL parsing, building and changing.

Also provides an loose URL tokenizer

### sub url-encode

```raku
sub url-encode(
    Str:D $data
) returns Str:D
```

Transforms a string into a percent encoded string

### sub url-decode

```raku
sub url-decode(
    Str:D $data
) returns Str:D
```

Transforms a percent encoded string into a plain string

### multi sub build-query-string

```raku
multi sub build-query-string(
    Hash:D $hash
) returns Str:D
```

Build a query string from a Hash

### multi sub build-query-string

```raku
multi sub build-query-string(
    *%hash
) returns Str:D
```

Build a query string from the named arguments

### sub parse-query-string

```raku
sub parse-query-string(
    Str:D $query-string
) returns Hash
```

Parse a query string

class PostCocoon::Url::URL-Parser
---------------------------------

Loose URL parser that doesn't follow RFC3986 not completely

### sub is-valid-url

```raku
sub is-valid-url(
    Str $uri
) returns Bool
```

Check if something is a valid URL according to the parser

### sub parse-url

```raku
sub parse-url(
    Str $uri
) returns Hash
```

Return a hash with all items of the URL

### multi sub build-url

```raku
multi sub build-url(
    Hash:D $hash
) returns Str:D
```

Build a URL from a given hash, this function does no error checking at all, it may result in an invalid URL

### multi sub build-url

```raku
multi sub build-url(
    *%hash
) returns Str
```

Build an url from given named parameters, this function does no error checking at all, it may result in an invalid url

AUTHOR
======

eater

COPYRIGHT AND LICENSE
=====================

Copyright 2017 eater

Copyright 2024 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

