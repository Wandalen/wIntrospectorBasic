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

  test.case = 'options : tempPath, routine, dirPath - default';
  var src =
  {
    tempPath : a.abs( '.' ),
    routine : testApp,
    namePostfix : '.js',
  };
  var got = _.program.make( src )
  test.identical( got.programPath, a.abs( '.' ) + '/testApp.js' );

  test.case = 'options : tempPath, routine, dirPath';
  var src =
  {
    tempPath : a.abs( '.' ),
    routine : testApp,
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

  act({ routine : _programWithRequire });
  act({ routine : _programWithIncludeLower });
  act({ routine : _programWithIncludeUpper });

  return ready;

  /* */

  function act( env )
  {

    ready.then( () =>
    {
      test.case = `basic, ${__.entity.exportStringSolo( env )}`;

      let program = _.program.make
      ({
        routine : env.routine,
        withSubmodules : 1,
        tempPath : a.abs( '.' ),
      });

      console.log( _.strLinesNumber( program.sourceCode ) );

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
        'routine',
        'name',
        'prefixCode',
        'sourceCode',
        'postfixCode',
        'locals',
        'withSubmodules',
        'moduleFile',
        'programPath',
        'tempPath',
        'dirPath',
        'namePrefix',
        'namePostfix',
        'rewriting',
        'logger',
        '_locals',
        'tempObject',
        'start'
      ]);
      test.identical( new Set( _.props.keys( program ) ), exp );

      console.log( _.strLinesNumber( program.sourceCode ) );
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
      program = _.program.make({ routine : programRoutine1, locals });
      console.log( _.strLinesNumber( program.sourceCode ) );
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
      program = _.program.make({ routine : programRoutine1, locals });
      console.log( _.strLinesNumber( program.sourceCode ) );
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
        () => program = _.program.make({ routine : programRoutine1, locals }),
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

      let program1 = _.program.make({ routine : programRoutine1, locals : { a : 1 } });
      let program2 = _.program.make({ routine : programRoutine1, locals : { a : 2 } });

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

      let routines =
      {
        programRoutine1,
        programRoutine2,
        programRoutine3,
      }
      let program = _.program.make({ routine : programRoutine1, routines, locals : { a : 1 } });

      return program.start();
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
    console.log( `programRoutine1 ${a}` );
  }

  /* - */

  function programRoutine2()
  {
    console.log( `programRoutine2 ${a}` );
  }

  /* - */

  function programRoutine3()
  {
    console.log( `programRoutine3 ${a}` );
  }

  /* - */

}

makeSeveralTimes.description =
`
- several writing works if tempPath is not specified
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
    makeSeveralTimes,
    // makeSeveralRoutines, /* xxx2 : switch on */

  },

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
