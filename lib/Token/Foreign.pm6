unit role Foreign;

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
