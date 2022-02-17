unit module TokenForeign;

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
        # WHERE the match came from (at least, I'm guessing, so long as the .orig
        # is the same).
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

multi sub trait_mod:<is> (Mu \grammar, :$extended!) is export {
    die 'Trait ‘extended’ only available on grammars'
        unless grammar.HOW.^name ~~ /Grammar/;

    my $name;
    my $grammar;
    my $actions;
    my $rule = 'TOP';
    my $args = \();
    my %opts;

    if $extended ~~ Grammar {
        $grammar = $extended;
    } elsif $extended ~~ List {
        # Unfortunately, we can't grab as a capture -- at least not without ugly syntax
        # so we torture the implementor here and manually process
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

    without $name {
        $grammar.^name ~~ / (.*?) <before :i <[-_]>? grammar> /;
        $name = $0.lc
    }

    say "Making grammar {$grammar.^name} accessible via <$name> in grammar {grammar.^name}";
    grammar.^add_method:
        $name,
        my method {
            $grammar.subparse:
                self.orig,
                :$actions,
                :pos(self.to),
                :$args,
               #:$rule,
               #|%opts
        }
}