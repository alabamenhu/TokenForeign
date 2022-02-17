# TokenForeign
A Raku module that provides a token allowing easy access to external grammars

This module was developed as a response to Mike Clark's article [“Multiple Co-operating Grammars in Raku”](http://clarkema.org/lab/2022/2022-02-09-raku-multiple-grammars/).
In it, he discusses his approach to calling one grammar from another.  While the approaches make sense to those familiar with grammars (and feels downright obvious when you see how it works), the process is admittedly less intuitive at first.
Nonetheless, people do [want to mix grammars](https://www.reddit.com/r/rakulang/comments/sex4qa/comment/humrie1/?utm_source=share&utm_medium=web2x&context=3), and this could be a powerful feature for Raku.

This module originally expanded on Mike's approach, but that had a limitation: the match tree wasn't preserved (only the AST via `make`/`made`).
After reviewing [Daniel Sockwell's thoughts](https://www.codesections.com/blog/grammatical-actions/) and trying to see if I could mimic his technique without multiple levels of inheritance/composition, I stumbled across a better technique.
The result?  An absolutely dirt simple way to integrate multiple grammars.

To use:

```raku
use Token::Foreign;

# OPTION A: token added via mixin
grammar Foo does Foreign {
    token foo  { ... <foreign:     BarGrammar, BarActions> ... }
    token foo2 { ... <bar=foreign: BarGrammar, BarActions> ... }
}

# OPTION B: imperative addition via sub call 
grammar Foo {
    add-foreign: 'bar', BarGrammar, BarActions;
    token foo { ... <bar> ... }
}

# OPTION C: trait with autonaming 
grammar Foo is extended(BarGrammar, BarActions) {
    token foo { ... <bar> ... }
}

```

Each method has its advantages and disadvantages.  Option A is extremely versatile, but a bit clunkier.
Option B is a bit less clunky since it provides a named token.  Option C is probably the cleanest. 
It will automatically geneate the token name by removed the word "Grammar" from the grammar class name as well as any trailing hyphen/underscore (`Perl6Grammar` would become `perl6`, `HTML-Grammar` would become `html`).

Both Options B and C require *compile time* knowledge of the external grammars.  With Option A, you could integrate grammars that are not known until runtime.

If you are curious how the module works, I have fully documented the code.

###Version history

 * **v0.3.0** 
   * Access via subs and traits (requires compile time knowledge)
 * **v0.2.0** 
   * Full match tree is provided
   * Requires mixing in a role
 * **v0.1.0** 
   * First release

### License and Copyright

Copyright © 2022 Matthew Stephen Stuckwisch.  Licensed under the Artistic License 2.0. 
That said, just integrate the code/technique directly if it better suites your project and you wish to avoid dependencies.