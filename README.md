# TokenForeign
A Raku module that provides a token allowing easy access to external grammars

This module was developed as a response to Mike Clark's article [“Multiple Co-operating Grammars in Raku”](http://clarkema.org/lab/2022/2022-02-09-raku-multiple-grammars/).
In it, he discusses his approach to calling one grammar from another.  While the approaches make sense to those familiar with grammars (and feels downright obvious when you see how it works), the process is admittedly less intuitive at first.
Nonetheless, people do [want to mix grammars](https://www.reddit.com/r/rakulang/comments/sex4qa/comment/humrie1/?utm_source=share&utm_medium=web2x&context=3), and this could be a powerful feature for Raku.

This module aims to make the process dirt simple, and expands on his approach.  To use:

```raku
grammar Foo {
    use Token::Foreign;
    
    token foo {
        ...
        <foreign: BarGrammar, BarActions>
        ...
    }
}
```

You will not have detailed access to the matches, but the AST will be fully intact and integrated into the main grammar.
In the above, in `foo`'s action method, you'd access it with `$<foreign>.made`.

If all you want is the match tree, but you are NOT interested in the actions class, this module is not necessary.  You can simply use

```raku
    token foo { ... <BarGrammar::TOP> ... }
```

If techniques to allow a full match tree and the actions classes, this module will be updated.

If you are curious how the module works, I have fully documented the code.
###Version history

 * **v0.1.0** 
   * First release

### License and Copyright

Copyright © 2022 Matthew Stephen Stuckwisch.  Licensed under the Artistic License 2.0. 
That said, just integrate the code/technique directly if it better suites your project and you wish to avoid dependencies.