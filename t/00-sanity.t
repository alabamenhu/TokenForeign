use Test;
use Token::Foreign;

grammar FooGrammar {
    token TOP { <foo>+  }
    token foo { <alpha> }
}
grammar BazGrammar {
    token TOP { <foo>+  }
    token foo { <alpha> }
}

class FooActions {
    method TOP ($/) { make $<foo>».made }
    method foo ($/) { make "*$/*"       }
}

grammar Bar
    is extended(FooGrammar, FooActions, :rule<foo>)
    #is extended(BazGrammar)
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
    method TOP ($/) { make $<foreign>».made }
}
say Bar.^find_method('foo');

# Some simple tests
my $match = Bar.parse: '1aa222bbbb', :actions(BarActions);
say $match;
is $match<foo>.head.Str, 'aa';
is $match<foo>.head<foo>.head.Str, 'a';
is $match<foo>.tail.Str, 'bbbb';
is $match<foo>.tail<foo>.tail.Str, 'b';
#is $match.made.head.Numeric, 2;
#is $match.made.tail.Numeric, 4;
#is $match.made.head.head, '*a*';
#is $match.made.tail.tail, '*b*';

done-testing;