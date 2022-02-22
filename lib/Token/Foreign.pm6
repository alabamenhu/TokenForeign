unit module TokenForeign;

sub grammar-name        { ... }
sub parse-extended-args { ... }

role Extended {
    method parse (
        Str() $str, :$actions, :$args = \(), :$rule = 'TOP',
        :ext-actions(%*TOKEN-FOREIGN-ACTIONS), *%opts
    ) { callsame }
    method subparse (
        Str() $str, :$actions, :$args = \(), :$rule = 'TOP',
        :ext-actions(%*TOKEN-FOREIGN-ACTIONS), *%opts
    ) { callsame }
    method parsefile (
        Str() $str, :$actions, :$args = \(), :$rule = 'TOP',
        :ext-actions(%*TOKEN-FOREIGN-ACTIONS), *%opts
    ) { callsame }
}

role Foreign is export {
    #| A method enabling the calling of one grammar from within another
    method foreign (
        $grammar,      #= The external grammar to be called
        $actions?,     #= The actions class associated with the grammar
       :$args = \(),   #= Any arguments to pass to the external grammar
       :$rule = 'TOP', #= The rule to call (defaults to 'TOP')
       *%opts          #= Options to passthrough
    ) is export {      #  exporting a my-scoped token still manages to attach it

        # This works because the requirement of calling a method in a grammar parse
        # is that it returns a match object.  It turns out, they aren't very picky
        # WHERE the match came from (even .orig can be different!).
        # Bonus points in that methods mean `<foo=.foreign>` is valid and maintains the
        # match tree (regular tokens will toss out match objects with .syntax)
        $grammar.subparse:
            self.orig,
            :pos(self.to),
            :$actions,
            :$args,
            :$rule,
            |%opts
    }
}

multi sub ext-grammar ($name, $grammar, $actions?, :$rule = 'TOP', :$args = \(), *%opts) is export {
    my \caller = CALLER::<$?CLASS>;
    die 'Can only call ext-grammar in the main block of a grammar'
        unless caller ~~ Grammar;
    caller.^add_method:
        $name,
        my method {
            $grammar.subparse:
                self.orig,
                :$actions,
                :pos(self.to),
                :$args,
                :$rule,
                |%opts
        }
}

multi sub trait_mod:<is> (Mu \base-grammar, :$extended!) is export {
    die 'Trait ‘extended’ only available on grammars'
        unless base-grammar.HOW.^name ~~ /Grammar/;

    # Unfortunately, we can't grab as a $extended as a capture -- at
    # least not without requiring users to use ugly syntax so we torture
    # the implementor here and manually process in parse-extended-args
    my %extended        = parse-extended-args $extended;
    my $name            = %extended<name>;
    my $grammar         = %extended<grammar>;
    my $default-actions = %extended<actions>;
    my $default-args    = %extended<args>;
    my $default-rule    = %extended<rule>;
    my %default-opts    = %extended<opts>;

    # If no name, autogenerate
    $name = grammar-name $grammar.^name
        without $name;

    # Add the extended role to set ext-actions if necessary
    base-grammar.^add_role(Extended)
        unless base-grammar ~~ Extended;

    # Add a method matching the name
    note "Making grammar {$grammar.^name} accessible via <$name> in grammar {base-grammar.^name}";
    base-grammar.^add_method:
        $name,
        my method ( :$args, :$actions, :$rule, *%opts ) {
            $grammar.subparse:
                self.orig,
                :pos(self.to),
                :actions($actions                       !=== Any ?? $actions
                      !! %*TOKEN-FOREIGN-ACTIONS{$name} !=== Any ?? %*TOKEN-FOREIGN-ACTIONS{$name}
                      !! $default-actions),
                :args($args // $default-args),
                :rule($rule // $default-rule),
               |%default-opts,
               |%opts
        }
}

sub grammar-name(Str $name) {
        my @parts = $name.split('::');

        # The format is akin to "Foo::Grammar"
        return @parts[* - 2].lc
            if @parts > 1
            && @parts.tail.lc eq 'grammar';

        # The format is likely akin to "Foo"
        # "FooGrammar", "Foo-Grammar", "Foo::BarGrammar"
        @parts.tail.lc ~~ / (.*?) <before <[-_]>? grammar> /;
        return ~$0
}

sub parse-extended-args ($extended) {
    my $name;
    my $grammar;
    my $actions;
    my $rule = 'TOP';
    my $args = \();
    my %opts;

    if $extended ~~ Grammar {
        $grammar = $extended;
    } elsif $extended ~~ List {
        for @$extended -> $arg {
            if $arg.isa: Pair {
                given $arg.key {
                    when 'rule' { $rule = $arg.value}
                    when 'name' { $name = $arg.value}
                    when 'args' { $args = $arg.value}
                    default     { %opts.push: $arg  }
                }
            } elsif $grammar ~~ Grammar {
                # check for second positional
                die 'Only one actions class is allowed for trait ‘extended’' if $actions;
                $actions = $arg;
            } else {
                die 'Must pass a grammar as the first positional argument to trait ‘extended’'
                    unless $arg ~~ Grammar;
                $grammar = $arg;
            }
        }
    } else {
        die 'Need to pass a grammar to trait ‘extended’';
    }
    return %(:$name, :$grammar, :$actions, :$rule, :$args, :%opts)
}