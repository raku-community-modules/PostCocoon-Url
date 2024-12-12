=begin pod

=head1 NAME

PostCocoon::Url - Some simple but useful URL utils

=head1 SYNOPSIS

=begin code :lang<raku>

use PostCocoon::Url;

say url-encode("👌");           # %F0%9F%91%8C
say url-decode("%F0%9F%91%8C"); # 👌

=end code

=head1 DESCRIPTION

A collection of functions that can be used for URL parsing,
building and changing.

Also provides an loose URL tokenizer

=end pod

unit module PostCocoon::Url;

#| Transforms a string into a percent encoded string
sub url-encode(Str:D $data --> Str:D) is export {
    my $start = 0;
    my $encoded-data = $data;

    for $data ~~ m:c:g:i/<-[a .. z 0 .. 9 \- \. _]>/ -> $match {
        my $current-start = $start + $match.from;
        my $current-end = $start + $match.to;
        my $current-match = ~$match;

        $current-match = $current-match.encode("utf-8")>>.base(16).map({
            "%" ~ (($_.chars % 2) > 0 ?? "0" !! "") ~ $_
        }).join;

        $start += $current-match.chars - (~$match).chars;
        $encoded-data =
          $encoded-data.substr(0, $current-start) ~
          $current-match ~
          $encoded-data.substr($current-end);
    }

    $encoded-data
}

#| Transforms a percent encoded string into a plain string
sub url-decode(Str:D $data --> Str:D) is export {
    $data.subst( / [\%<.xdigit> ** 2]+ /, {
        utf8.new(|.comb(3).map(*.substr(1).parse-base(16))).decode
    }, :g)
}

#| Build a query string from a Hash
multi sub build-query-string(Hash:D $hash --> Str:D) is export {
    my @query-items;
    for $hash.kv -> $key, $value {
        if $value ~~ Bool && $value {
            @query-items.push: url-encode($key);
        }
        elsif $value ~~ List {
            for $value.kv -> $k, $v {
                @query-items.push: url-encode($key) ~ "=" ~ url-encode($v);
            }
        }
        else {
            @query-items.push: url-encode($key) ~ "=" ~ url-encode($value);
        }
    }

    @query-items.join("&")
}

#| Build a query string from the named arguments
multi sub build-query-string(*%hash --> Str:D) is export {
    build-query-string(%hash);
}

#| Parse a query string
sub parse-query-string(Str:D $query-string --> Hash) is export {
    my $items = $query-string.split("&");
    my $result = {};

    for $items.kv -> $k, $v {
        my ($key, $value) = $v.split("=", 2);
        $key = url-decode $key;

        with $value {
            $value = url-decode $value;
        }

        $value //= True;

        if defined $result{$key} {
            if $result{$key} ~~ Positional {
                $result{$key}.push: $value;
            } else {
                my $item = $result{$key};
                $result{$key} = ($item, $value);
            }
        }
        else {
            $result{$key} = $value;
        }
    }

    $result
}

#| Loose URL parser that doesn't follow RFC3986 not completely
grammar URL-Parser is export {
    token TOP {
        [<scheme> ':' ]?
        '//'?
        [ <auth> '@' ]?
        [ <host> <path> | <host> | <path> ]
        [ '?' <query-string> ]?
        [ '#' <fragment> ]?
    }

    token scheme       { <[ a..z ]> <[a..z 0..9 + \- .]>*          }
    token path         { '/' <-[ ? # ]>*                           }
    token auth         { <username> [ ':' <password> ]?            }
    token query-string { <-[ # ]>*                                 }
    token fragment     { <-[ \s ]>*                                }
    token username     { <-[ : @ ]>*                               }
    token password     { <-[ @ ]>*                                 }
    token host         { <hostname> [ ':' <port> ]?                }
    token hostname     { [ <-[ / : # ? \h ]>+ | \[ <-[ \] ]>+ \] ] }
    token port         { <[ 0..9 ]>+                               }
}

#| Check if something is a valid URL according to the parser
sub is-valid-url (Str $uri --> Bool) is export {
    URL-Parser.parse($uri) !~~ Nil
}

#| Return a hash with all items of the URL
sub parse-url (Str $uri --> Hash) is export {
    my $result = {};
    my $grammar = URL-Parser.parse($uri);
    if ($grammar ~~ Nil) {
          X::AdHoc.new(payload => "$uri is not an valid url").throw;
    }

    for <scheme fragment path query-string host auth> -> $key {
          if defined $grammar{$key} {
                  $result{$key} = ~$grammar{$key};
          }
    }

    with $grammar<host> {
          $result<hostname> [R//]= ~.<hostname>;
          $result<port> [R//]= ~.<port>;
    }

    with $grammar<auth> {
          $result<username> [R//]= ~.<username>;
          $result<password> [R//]= ~.<password>;
    }

    $result
}

#| Build a URL from a given hash, this function does no error
#| checking at all, it may result in an invalid URL
multi sub build-url (Hash:D $hash --> Str:D) is export {
    my $url = "";

    with $hash<scheme> {
        $url ~= $_ ~ '://';
    }

    with $hash<auth> {
        $url ~= $_ ~ "@";
    }
    orwith $hash<username> {
        $url ~= $_;
        with $hash<password> {
            $url ~= ":" ~ $_;
        }
        $url ~= "@";
    }

    with $hash<host> {
        $url ~= $_;
    }
    orwith $hash<hostname> {
        $url ~= $_;
        with $hash<port> {
            $url ~= ':' ~ $_;
        }
    }

    with $hash<path> {
        if .substr(0, 1) ne "/" {
            $url ~= "/";
        }

        $url ~= $_;
    }

    with $hash<query-string> {
        $url ~= '?' ~ $_;
    }

    with $hash<fragment> {
        $url ~= '#' ~ $_;
    }

    $url
}

#| Build an url from given named parameters,
#| this function does no error checking at all, it may result in an invalid url
multi sub build-url (*%hash --> Str) is export {
    build-url(%hash);
}

=begin pod

=head1 AUTHOR

eater

=head1 COPYRIGHT AND LICENSE

Copyright 2017 eater

Copyright 2024 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
