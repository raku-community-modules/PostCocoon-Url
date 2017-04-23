use v6;



unit module PostCocoon::Utils::Url;

sub url-encode (Str $data) is export {
  my $start = 0;
  my $encoded-data = $data;

  for $data ~~ m:c:g:i/<-[a .. z 0 .. 9 \- \. _]>/ -> $match {
    my $current-start = $start + $match.from;
    my $current-end = $start + $match.to;
    my $current-match = ~$match;

    $current-match = $current-match.encode("utf-8")>>.base(16).map({ "%" ~ (($_.chars % 2) > 0 ?? "0" !! "") ~ $_ }).join();

    $start += $current-match.chars - (~$match).chars;
    $encoded-data =
      $encoded-data.substr(0, $current-start) ~
      $current-match ~
      $encoded-data.substr($current-end);
  }

  return $encoded-data;
}

sub url-decode (Str $data) is export {
  my $start = 0;
  my $decoded-data = $data.encode("utf-8");

  for $data ~~ m:c:g:i/\%(<[a .. f 0 .. 9]> ** 2)/ -> $match {
    my $current-start = $start + $match.from;
    my $current-end = $start + $match.to;

    $start += 1 - (~$match).chars;
    $decoded-data = Blob.new(|$decoded-data[0..($current-start - 1)], (~$match[0]).parse-base(16), |$decoded-data[$current-end..*]);
  }

  return $decoded-data.decode("utf-8");
}

multi sub build-query-string (Hash $hash) is export {
  my @query-items;
  for $hash.kv -> $key, $value {
    if ($value eq True) {
      @query-items.push: url-encode($key);
    } elsif ($value ~~ List) {
      for $value.kv -> $k, $v {
        @query-items.push: url-encode($key) ~ "=" ~ url-encode($v);
      }
    } else {
      @query-items.push: url-encode($key) ~ "=" ~ url-encode($value);
    }
  }

  return @query-items.join("&");
}

multi sub build-query-string (*%hash) is export {
  build-query-string(%hash);
}

sub parse-query-string(Str $query-string) is export {
  my $items = $query-string.split("&");
  my $result = {};

  for $items.kv -> $k, $v {
    my ($key, $value) = $v.split("=", 2);
    $key = url-decode $key;

    if defined $value {
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
    } else {
      $result{$key} = $value;
    }
  }

  return $result;
}
