| auto |

Metacello new
  githubUser: 'badetitou' project: 'AutoReneraku' commitish: 'v1.0.10' path: 'src';
  baseline: 'AutoReneraku';
  onConflictUseIncoming;
  load.

auto := (Smalltalk classNamed: 'AutoReneraku') new.
auto prepareAutoReneraku.
auto run.

Smalltalk snapshot: false andQuit: true
