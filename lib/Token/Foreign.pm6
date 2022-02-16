unit module Foreign;

#| A token enabling the calling of one grammar from within another
my token foreign (
    $grammar,      #= The external grammar to be called
    $actions?,     #= The actions class associated with the grammar
   :$args = \(),   #= Any arguments to pass to the external grammar
   :$rule = 'TOP', #= The rule to call (defaults to 'TOP')
   *%opts          #= Options to passthrough
) is export {      #  exporting a my-scoped token still manages to attach it

    # Store foreign match
    :my $foreign;

    {
        # Parse the foreign language
        # 'subparse' prevents the implied ^ and $ tokens
        $foreign = $grammar.subparse:
            $/.orig,
            :pos($/.to),
            :$actions,   # this can be undefined without problem
            :$args,
            :$rule,
            |%opts;
    }

    # Die if the parse failed
    <?{ so $foreign }>

    # Advance the length of the foreign language
    . ** {$foreign.to - $/.to}

    # Pass through the AST
    { make $foreign.made }
}
