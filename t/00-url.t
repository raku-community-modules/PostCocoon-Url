use v6;
use PostCocoon::Utils::Url;
use Test;

plan 13;
ok "%00" eq url-encode("\0"), "Encode null-char";
ok "%F0%9F%91%8C" eq url-encode("👌"), "Encode emoji";
ok url-decode(url-encode("\0")) eq "\0", "Encode and decode null-char";
ok "👌" eq url-decode(url-encode("👌")), "Encode and decode emoji";
ok "help%20mij" eq url-encode("help mij"), "Encode space";
ok "help mij" eq url-decode("help%20mij"), "Decode space";
ok "help=nee" eq build-query-string(help => "nee"), "Build simple query string";
ok "help" eq build-query-string(help => True), "build simple query string without value";
ok "help=nee\&help=ja" eq build-query-string(help => <nee ja>), "Build simple query string with duplicate keys";
ok "%F0%9F%91%8C=%F0%9F%91%8C" eq build-query-string({ "👌" => "👌" }), "Build query with emoji key";
ok { help => <nee ja> } eq parse-query-string("help=nee\&help=ja"), "Parse simple query string with duplicate keys";
ok { help => True } eq parse-query-string("help"), "Parse simple query string without value";
ok { "👌" => "👌" } eq parse-query-string("%F0%9F%91%8C=%F0%9F%91%8C"), "Parse emoji query string";
