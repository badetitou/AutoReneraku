| auto |

Metacello new
  githubUser: 'badetitou' project: 'AutoReneraku' commitish: 'main' path: 'src';
  baseline: 'AutoReneraku';
  onConflictUseIncoming;
  load.

auto := (Smalltalk classNamed: 'AutoReneraku') new.
auto prepareAutoReneraku.
auto run.

Smalltalk snapshot: false andQuit: true