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

grammar Foo does Foreign {
    token foo {
        ...
        <foreign: BarGrammar, BarActions>
        ...
    }
}
```

If you don't want the name `foreign` littering your actions code, there are two ways around it. 
Option one is to rename the token inline: `<newname=.foreign: BarGrammar>`. 
The second option is create a *method* with the name you'd prefer. 
This second option has the advantage that you won't need to constantly reinclude the name of the grammar:

```raku
grammar Foo does Foreign {
    method bar { self.foreign: BarGrammar, BarActions }
    token foo {
        ...
        <bar>
        ...
    }
}
```

If you are curious how the module works, I have fully documented the code.

###Version history

 * **v0.2.0** 
   * Full match tree is provided
   * Requires mixing in a role
 * **v0.1.0** 
   * First release

### License and Copyright

Copyright © 2022 Matthew Stephen Stuckwisch.  Licensed under the Artistic License 2.0. 
That said, just integrate the code/technique directly if it better suites your project and you wish to avoid dependencies.