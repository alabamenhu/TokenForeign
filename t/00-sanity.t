use Test;
use Token::Foreign;

grammar FooGrammar {
    token TOP { <foo>+  }
    token foo { <alpha> }
}
grammar Baz::Grammar {
    token TOP { <foo>+  }
    token foo { <alpha> }
}

class FooActions {
    method TOP ($/) { make $<foo>».made }
    method foo ($/) { make "*$/*"       }
}
class BooActions {
    method TOP ($/) { make $<foo>».made }
    method foo ($/) { make "^$/^"       }
}

grammar Bar
    is extended(FooGrammar, FooActions)
    is extended(Baz::Grammar)
    {
    #ext-grammar 'foo', FooGrammar, FooActions;
    token TOP {
        [
        | <bar>
        | <foo>
        ]+
    }
    token bar { <digit> }
}
class BarActions {
    method TOP ($/) { make $<bar>».made }
}
class BarBarActions {
    method TOP ($/) { make $<foo>».made }
}

# Some simple tests
my $match = Bar.parse: '1aa222bbbb', :actions(BarBarActions);
is $match<foo>.head.Str, 'aa';
is $match<foo>.head<foo>.head.Str, 'a';
is $match<foo>.tail.Str, 'bbbb';
is $match<foo>.tail<foo>.tail.Str, 'b';
is $match.made.head.Numeric, 2;
is $match.made.tail.Numeric, 4;
is $match.made.head.head, '*a*';
is $match.made.tail.tail, '*b*';

done-testing;