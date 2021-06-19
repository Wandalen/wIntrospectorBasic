( function _Program_test_s()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( 'Tools' );
  require( '../l2_introspector/Include.s' );
  _.include( 'wTesting' );
}

const _global = _global_;
const _ = _global_.wTools;
const __ = _globals_.testing.wTools;
const fileProvider = __.fileProvider;
const path = fileProvider.path;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;
  self.suiteTempPath = path.tempOpen( path.join( __dirname, '../..' ), 'Routine' );
}

//

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, 'Routine' ) )
  path.tempClose( self.suiteTempPath );
}

// --
// test
// --

function writeBasic( test )
{
  let context = this;
  let a = test.assetFor( false );

  test.case = 'options : tempPath, entry, dirPath - default';
  var src =
  {
    tempPath : a.abs( '.' ),
    entry : testApp,
    namePostfix : '.js',
  };
  var got = _.program.make( src )
  test.identical( got.programPath, a.abs( '.' ) + '/testApp.js' );

  test.case = 'options : tempPath, entry, dirPath';
  var src =
  {
    tempPath : a.abs( '.' ),
    entry : testApp,
    namePostfix : '.js',
    dirPath : 'dir',
  };
  var got = _.program.make( src )
  test.identical( got.programPath, a.abs( '.' ) + '/dir/testApp.js' );

  /* */

  function testApp(){}
}

//

function writeOptionWithSubmodulesAndModuleIsIncluded( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );

  let start = __.process.starter
  ({
    outputCollecting : 1,
    outputPiping : 1,
    inputMirroring : 1,
    throwingExitCode : 0,
    mode : 'fork',
  });

  test.true( _.module.isIncluded( 'wTesting' ) );
  test.true( !_.module.isIncluded( 'abcdef123' ) );

  act({ entry : _programWithRequire });
  act({ entry : _programWithIncludeLower });
  act({ entry : _programWithIncludeUpper });

  return ready;

  /* */

  function act( env )
  {

    ready.then( () =>
    {
      test.case = `basic, ${__.entity.exportStringSolo( env )}`;

      let program = _.program.make
      ({
        entry : env.entry,
        withSubmodules : 1,
        tempPath : a.abs( '.' ),
      });

      console.log( _.strLinesNumber( program.entry.routineCode ) );

      return start
      ({
        execPath : program.programPath,
        currentPath : _.path.dir( program.programPath ),
      })
    })
    .then( ( op ) =>
    {
      var exp =
  `
  isIncluded( wLooker ) false
  isIncluded( wlooker ) false
  isIncluded( wLooker ) true
  isIncluded( wlooker ) true
  `
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

  }

  /* - */

  function _programWithRequire()
  {
    const _ = require( toolsPath );
    // let ModuleFileNative = require( 'module' );
    // console.log( `program1.globalPaths\n  ${ModuleFileNative.globalPaths.join( '\n  ' )}` );
    // console.log( `program1.paths\n  ${module.paths.join( '\n  ' )}` );
    console.log( 'isIncluded( wLooker )', _.module.isIncluded( 'wLooker' ) );
    console.log( 'isIncluded( wlooker )', _.module.isIncluded( 'wlooker' ) );
    require( 'wlooker' );
    console.log( 'isIncluded( wLooker )', _.module.isIncluded( 'wLooker' ) );
    console.log( 'isIncluded( wlooker )', _.module.isIncluded( 'wlooker' ) );
  }

  /* - */

  function _programWithIncludeLower()
  {
    const _ = require( toolsPath );
    console.log( 'isIncluded( wLooker )', _.module.isIncluded( 'wLooker' ) );
    console.log( 'isIncluded( wlooker )', _.module.isIncluded( 'wlooker' ) );
    _.include( 'wlooker' );
    console.log( 'isIncluded( wLooker )', _.module.isIncluded( 'wLooker' ) );
    console.log( 'isIncluded( wlooker )', _.module.isIncluded( 'wlooker' ) );
  }

  /* - */

  function _programWithIncludeUpper()
  {
    const _ = require( toolsPath );
    console.log( 'isIncluded( wLooker )', _.module.isIncluded( 'wLooker' ) );
    console.log( 'isIncluded( wlooker )', _.module.isIncluded( 'wlooker' ) );
    _.include( 'wlooker' );
    console.log( 'isIncluded( wLooker )', _.module.isIncluded( 'wLooker' ) );
    console.log( 'isIncluded( wlooker )', _.module.isIncluded( 'wlooker' ) );
  }

  /* - */

}

//

function writeStart( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );
  let program;

  act({});

  return ready;

  /* */

  function act( env )
  {

    ready.then( () =>
    {
      test.case = `basic, ${__.entity.exportStringSolo( env )}`;
      program = _.program.make( programRoutine1 );

      var exp = new Set
      ([
        'group', 'entry', 'files', 'programPath', 'start'
      ]);
      test.identical( new Set( _.props.keys( program ) ), exp );

      console.log( _.strLinesNumber( program.entry.routineCode ) );
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
Current path : ${_.path.nativize( _.path.dir( program.programPath ) )}
Program path : ${_.path.nativize( program.programPath )}
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

  }

  /* - */

  function programRoutine1()
  {
    const _ = require( toolsPath );
    console.log( `Current path : ${process.cwd()}` );
    console.log( `Program path : ${__filename}` );
  }

  /* - */

}

writeStart.description =
`
- field start has set properly current path
- field start has set properly exec path
`

//

function writeRoutineLocals( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );
  let program;

  programRoutine1.meta = {};
  programRoutine1.meta.locals =
  {
    a : 1,
  }

  act({});

  return ready;

  /* */

  function act( env )
  {

    ready.then( () =>
    {
      test.case = `basic, ${__.entity.exportStringSolo( env )}`;
      let locals = { b : 2 };
      program = _.program.make({ entry : programRoutine1, locals });
      console.log( _.strLinesNumber( program.entry.routineCode ) );
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
3
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

  }

  /* - */

  function programRoutine1()
  {
    console.log( a + b );
  }

  /* - */

}

writeRoutineLocals.description =
`
- routine locals are exported and usable
`

//

function writeLocalsConflict( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );
  let program;

  programRoutine1.meta = {};
  programRoutine1.meta.locals =
  {
    a : 1,
    b : 2,
  }

  actGood({});
  actThrowing({});

  return ready;

  /* */

  function actGood( env )
  {

    ready.then( () =>
    {
      test.case = `good, ${__.entity.exportStringSolo( env )}`;
      let locals = { b : 2, c : 3 };
      program = _.program.make({ entry : programRoutine1, locals });
      console.log( _.strLinesNumber( program.entry.routineCode ) );
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp = `6`;
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

  }

  /* */

  function actThrowing( env )
  {

    ready.then( () =>
    {
      test.case = `throwing, ${__.entity.exportStringSolo( env )}`;
      let locals = { b : 22, c : 3 };
      test.shouldThrowErrorSync
      (
        () => program = _.program.make({ entry : programRoutine1, locals }),
        ( err ) => test.identical( err.originalMessage, 'Duplication of local variable "b"' )
      )
      return null;
    });

  }

  /* - */

  function programRoutine1()
  {
    console.log( a + b + c );
  }

  /* - */

}

writeLocalsConflict.description =
`
- conflict of locals throw error, but not if value is same
`

//

function makeOptionRoutineCode( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );

  act({});

  return ready;

  /* - */

  function act( env )
  {

    ready.then( () =>
    {
      test.case = `basic, ${__.entity.exportStringSolo( env )}`;
      let routineCode =
`
function programRoutine1()
{
  console.log( 'programRoutine1' );
}
`
      let program1 = _.program.make({ routineCode, name : 'programRoutine1' })
      return program1.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

  }

  /* - */

}

makeOptionRoutineCode.description =
`
- making from option routineCode works
`

//

function makeSourceLocation( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );

  act({});

  return ready;

  /* - */

  function act( env )
  {

    /* */

    ready.then( () =>
    {
      test.case = `without fixes, ${__.entity.exportStringSolo( env )}`;
      var program1 = _.program.make({ entry : programRoutine1 });
      test.identical( _.strCount( _.str.lines.split( program1.entry.fullCode )[ 0 ], 'function programRoutine1()' ), 1 );
      console.log( _.strLinesNumber( program1.entry.fullCode ) );
      console.log( _.strLinesNumber( program1.entry.routineCode ) );
      return program1.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1 : ${op.execPath}:4:54
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

    /* */

    ready.then( () =>
    {
      test.case = `with fixes, ${__.entity.exportStringSolo( env )}`;
      var program1 = _.program.make({ entry : programRoutine1, ... codes( 'programRoutine1' ) });
      test.identical( _.strCount( _.str.lines.split( program1.entry.fullCode )[ 4 ], 'function programRoutine1()' ), 1 );
      console.log( _.strLinesNumber( program1.entry.fullCode ) );
      console.log( _.strLinesNumber( program1.entry.routineCode ) );
      return program1.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1 prefix code
programRoutine1 before start code
programRoutine1 : ${op.execPath}:8:54
programRoutine1 after start code
programRoutine1 postfix code
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

    /* */

  }

  /* - */

  function programRoutine1()
  {
    const _ = require( toolsPath );
    console.log( `programRoutine1 : ${_.introspector.location().filePathLineCol}` );
  }

  /* - */

  function code( name )
  {
    return `\nconsole.log( '${name} code' )\n`
  }

  /* - */

  function codes( name )
  {
    let result =
    {
      prefixCode : code( `${name} prefix` ),
      postfixCode : code( `${name} postfix` ),
      beforeStartCode : code( `${name} before start` ),
      afterStartCode : code( `${name} after start` ),
    }
    return result;
  }

  /* - */

}

makeSourceLocation.description =
`
- fixate source location
`

//

function makeSeveralTimes( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );

  act({});

  return ready;

  /* */

  function act( env )
  {

    ready.then( () =>
    {
      test.case = `basic, ${__.entity.exportStringSolo( env )}`;

      let program1 = _.program.make({ entry : programRoutine1, locals : { a : 1 } });
      let program2 = _.program.make({ entry : programRoutine1, locals : { a : 2 } });

      return _.Consequence.And( program1.start(), program2.start() );
    })
    .then( ( ops ) =>
    {
      var exp = '1';
      test.identical( ops[ 0 ].exitCode, 0 );
      test.equivalent( ops[ 0 ].output, exp );
      var exp = '2';
      test.identical( ops[ 1 ].exitCode, 0 );
      test.equivalent( ops[ 1 ].output, exp );
      return ops;
    });

  }

  /* - */

  function programRoutine1()
  {
    console.log( a );
  }

  /* - */

}

makeSeveralTimes.description =
`
- several writing works if tempPath is not specified
`

//

function makeSeveralRoutines( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );

  act({});

  return ready;

  /* */

  function act( env )
  {

    ready.then( () =>
    {
      test.case = `basic, ${__.entity.exportStringSolo( env )}`;
      let locals = { a : 1 };
      let files =
      {
        programRoutine1,
        programRoutine2,
        programRoutine3,
      }
      let program = _.program.make({ entry : programRoutine1, files, locals });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1 1
programRoutine2 1
programRoutine3 1
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

  }

  /* - */

  function programRoutine1()
  {
    console.log( `programRoutine1 ${a}` );
    require( './programRoutine2' );
  }

  /* - */

  function programRoutine2()
  {
    console.log( `programRoutine2 ${a}` );
    require( './programRoutine3' );
  }

  /* - */

  function programRoutine3()
  {
    console.log( `programRoutine3 ${a}` );
  }

  /* - */

}

makeSeveralRoutines.description =
`
- severa routines works, them all has local
`

//

function makeEntryAndFiles( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );

  act({ withEntry : 1 });
  act({ withEntry : 0 });

  return ready;

  /* - */

  function act( env )
  {

    /* */

    ready.then( () =>
    {
      test.case = `entry by name and files as routines, ${__.entity.exportStringSolo( env )}`;
      let entry = 'programRoutine1';
      let files =
      {
        programRoutine1,
        programRoutine2,
        programRoutine3,
      }
      let program = _.program.make({ files, entry });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1
programRoutine2
programRoutine3
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

    /* */

    ready.then( () =>
    {
      test.case = `entry by name and files as files, ${__.entity.exportStringSolo( env )}`;
      let entry = 'programRoutine1';
      let files =
      {
        programRoutine1 : { routine : programRoutine1 },
        programRoutine2 : { routine : programRoutine2 },
        programRoutine3 : { routine : programRoutine3 },
      }
      let program = _.program.make({ files, entry });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1
programRoutine2
programRoutine3
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

    /* */

    ready.then( () =>
    {
      test.case = `entry by routine and files as routines, ${__.entity.exportStringSolo( env )}`;
      let entry = programRoutine1;
      let files =
      {
        programRoutine2,
        programRoutine3,
      }
      if( env.withEntry )
      files.programRoutine1 = programRoutine1;
      let program = _.program.make({ files, entry });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1
programRoutine2
programRoutine3
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

    /* */

    ready.then( () =>
    {
      test.case = `entry by routine and files as files, ${__.entity.exportStringSolo( env )}`;
      let entry = programRoutine1;
      let files =
      {
        programRoutine2 : { routine : programRoutine2 },
        programRoutine3 : { routine : programRoutine3 },
      }
      if( env.withEntry )
      files.programRoutine1 = { routine : programRoutine1 };
      let program = _.program.make({ files, entry });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1
programRoutine2
programRoutine3
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

    /* */

    ready.then( () =>
    {
      test.case = `entry by file and files as routines, ${__.entity.exportStringSolo( env )}`;
      let entry = { routine : programRoutine1 };
      let files =
      {
        programRoutine2,
        programRoutine3,
      }
      if( env.withEntry )
      files.programRoutine1 = programRoutine1;
      let program = _.program.make({ files, entry });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1
programRoutine2
programRoutine3
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

    /* */

    ready.then( () =>
    {
      test.case = `entry by file and files as files, ${__.entity.exportStringSolo( env )}`;
      let entry = { routine : programRoutine1 };
      let files =
      {
        programRoutine2 : { routine : programRoutine2 },
        programRoutine3 : { routine : programRoutine3 },
      }
      if( env.withEntry )
      files.programRoutine1 = entry;
      let program = _.program.make({ files, entry });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1
programRoutine2
programRoutine3
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

    /* */

  }

  /* - */

  function programRoutine1()
  {
    console.log( `programRoutine1` );
    require( './programRoutine2' );
  }

  /* - */

  function programRoutine2()
  {
    console.log( `programRoutine2` );
    require( './programRoutine3' );
  }

  /* - */

  function programRoutine3()
  {
    console.log( `programRoutine3` );
  }

  /* - */

}

makeEntryAndFiles.description =
`
- severa routines works, them all has local
`

//

function makeEntryAndFilesLocals( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );

  act({});

  return ready;

  /* - */

  function act( env )
  {

    /* */

    ready.then( () =>
    {
      test.case = `no entry in files, ${__.entity.exportStringSolo( env )}`;
      let locals = { a : 1 };
      let entry = { routine : programRoutine1, locals : { b : 1 } };
      let files =
      {
        programRoutine2 : { routine : programRoutine2, locals : { b : 2 } },
        programRoutine3 : { routine : programRoutine3, locals : { b : 3 } },
      }
      let program = _.program.make({ files, locals, entry });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1 2
programRoutine2 3
programRoutine3 4
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

    /* */

    ready.then( () =>
    {
      test.case = `entry in files, ${__.entity.exportStringSolo( env )}`;
      let locals = { a : 1 };
      let entry = { routine : programRoutine1, locals : { b : 1 } };
      let files =
      {
        programRoutine1 : entry,
        programRoutine2 : { routine : programRoutine2, locals : { b : 2 } },
        programRoutine3 : { routine : programRoutine3, locals : { b : 3 } },
      }
      let program = _.program.make({ files, locals, entry });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1 2
programRoutine2 3
programRoutine3 4
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

  }

  /* - */

  function programRoutine1()
  {
    console.log( `programRoutine1 ${a+b}` );
    require( './programRoutine2' );
  }

  /* - */

  function programRoutine2()
  {
    console.log( `programRoutine2 ${a+b}` );
    require( './programRoutine3' );
  }

  /* - */

  function programRoutine3()
  {
    console.log( `programRoutine3 ${a+b}` );
  }

  /* - */

}

makeEntryAndFilesLocals.description =
`
- severa routines works
- locals are inherited and appended by individual locals
`

//

function makeEntryAndFilesCode( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );

  act({});

  return ready;

  /* */

  function act( env )
  {

    ready.then( () =>
    {
      test.case = `basic, ${__.entity.exportStringSolo( env )}`;
      let locals = { a : 1 };
      let entry = { routine : programRoutine1, locals : { b : 1 }, ... codes( 'programRoutine1' ) };
      let files =
      {
        programRoutine1 : entry,
        programRoutine2 : { routine : programRoutine2, locals : { b : 2 }, ... codes( 'programRoutine2' ) },
      }
      let program = _.program.make({ files, locals, entry, ... codes( 'group' ) });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
group prefix code
programRoutine1 prefix code
group before start code
programRoutine1 before start code
programRoutine1 2
group prefix code
programRoutine2 prefix code
group before start code
programRoutine2 before start code
programRoutine2 3
programRoutine2 after start code
group after start code
programRoutine2 postfix code
group postfix code
programRoutine1 after start code
group after start code
programRoutine1 postfix code
group postfix code
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

  }

  /* - */

  function programRoutine1()
  {
    console.log( `programRoutine1 ${a+b}` );
    require( './programRoutine2' );
  }

  /* - */

  function programRoutine2()
  {
    console.log( `programRoutine2 ${a+b}` );
  }

  /* - */

  function code( name )
  {
    return `\nconsole.log( '${name} code' )\n`
  }

  /* - */

  function codes( name )
  {
    let result =
    {
      prefixCode : code( `${name} prefix` ),
      postfixCode : code( `${name} postfix` ),
      beforeStartCode : code( `${name} before start` ),
      afterStartCode : code( `${name} after start` ),
    }
    return result;
  }

  /* - */

}

makeEntryAndFilesCode.description =
`
- group options *code are inherited
- all options *code mixed in right order
`

//

function makeEntryAndFilesCodeLocals( test )
{
  let context = this;
  let a = test.assetFor( false );
  let ready = _.take( null );

  act({});

  return ready;

  /* - */

  function act( env )
  {

    /* */

    ready.then( () =>
    {
      test.case = `group locals, ${__.entity.exportStringSolo( env )}`;
      let locals = { a : 1, b : 2, c : 3 };
      let entry = { routine : programRoutine1, codeLocals : { b : '2' } };
      let files =
      {
        programRoutine1 : entry,
        programRoutine2 : { routine : programRoutine2, codeLocals : { c : '3' } },
      }
      let program = _.program.make({ files, locals, entry });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1 a:number
programRoutine1 b:undefined
programRoutine1 c:number
programRoutine2 a:number
programRoutine2 b:number
programRoutine2 c:undefined
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

    /* */

    ready.then( () =>
    {
      test.case = `file locals, ${__.entity.exportStringSolo( env )}`;
      let locals = { a : 1, b : 2, c : 3 };
      let entry = { routine : programRoutine1, locals, codeLocals : { b : '2' } };
      let files =
      {
        programRoutine1 : entry,
        programRoutine2 : { routine : programRoutine2, locals, codeLocals : { c : '3' } },
      }
      let program = _.program.make({ files, entry });
      return program.start();
    })
    .then( ( op ) =>
    {
      var exp =
`
programRoutine1 a:number
programRoutine1 b:undefined
programRoutine1 c:number
programRoutine2 a:number
programRoutine2 b:number
programRoutine2 c:undefined
`
      test.identical( op.exitCode, 0 );
      test.equivalent( op.output, exp );
      return op;
    });

    /* */

    ready.then( () =>
    {
      if( !Config.debug )
      return;
      test.shouldThrowErrorSync
      (
        () => _.program.make({ entry : programRoutine1, codeLocals : { d : 4 } }),
        ( err ) => test.identical( err.originalMessage, 'Routine "make" does not expect options: "codeLocals"' ),
      );
      return null;
    });

    /* */

  }

  /* - */

  function programRoutine1()
  {
    console.log( `programRoutine1 a:${typeof a}` );
    console.log( `programRoutine1 b:${typeof b}` );
    console.log( `programRoutine1 c:${typeof c}` );
    require( './programRoutine2' );
  }

  /* - */

  function programRoutine2()
  {
    console.log( `programRoutine2 a:${typeof a}` );
    console.log( `programRoutine2 b:${typeof b}` );
    console.log( `programRoutine2 c:${typeof c}` );
  }

  /* - */

}

makeEntryAndFilesCodeLocals.description =
`
- option::codeLocals influence on formation of locals
- adding local into option::codeLocals removes such local from code of a program file
`

// --
// declare
// --

const Proto =
{

  name : 'Tools.introspector.Program',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    suiteTempPath : null,
  },

  tests :
  {

    writeBasic,
    writeOptionWithSubmodulesAndModuleIsIncluded,
    writeStart,
    writeRoutineLocals,
    writeLocalsConflict,

    makeOptionRoutineCode,
    makeSourceLocation,
    makeSeveralTimes,
    makeSeveralRoutines,
    makeEntryAndFiles,
    makeEntryAndFilesLocals,
    makeEntryAndFilesCode,
    makeEntryAndFilesCodeLocals,

  },

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
