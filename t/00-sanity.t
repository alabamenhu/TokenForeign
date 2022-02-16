use Test;

grammar Foo {
    token TOP { <foo>+  }
    token foo { <alpha> }
}

class FooActions {
    method TOP ($/) { make $<foo>».made }
    method foo ($/) { make "*$/*"       }
}

grammar Bar {
    use Token::Foreign;
    token TOP {
        [
        | <bar>
        | <foreign: Foo, FooActions>
        ]+
    }
    token bar { <digit> }
}

class BarActions {
    method TOP ($/) { make $<foreign>».made }
}

# Some simple tests 
my $match = Bar.parse: '1aa222bbbb', :actions(BarActions);
is $match<foreign>.head.Str, 'aa';
is $match<foreign>.tail.Str, 'bbbb';
is $match.made.head.Numeric, 2;
is $match.made.tail.Numeric, 4;
is $match.made.head.head, '*a*';
is $match.made.tail.tail, '*b*';

done-testing;