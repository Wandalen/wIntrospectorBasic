( function _Introspector_test_s()
{

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../wtools/Tools.s' );

  require( '../l2/Introspector.s' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wConsequence' );

}

let _global = _global_;
let _ = _global_.wTools;
let fileProvider = _globals_.testing.wTools.fileProvider;
let path = fileProvider.path;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;
  self.suiteTempPath = path.tempOpen( path.join( __dirname, '../..' ), 'Routine' );

}

function onSuiteEnd()
{
  let self = this;
  _.assert( _.strHas( self.suiteTempPath, 'Routine' ) )
  path.tempClose( self.suiteTempPath );
}

//

function testFunction1( x, y )
{
  return x + y
}

function testFunction2( x, y )
{
  return this;
}

function testFunction3( x, y )
{
  return x + y + this.k;
}

function testFunction4( x, y )
{
  return this;
}

function contextConstructor3()
{
  this.k = 15
}

var context3 = new contextConstructor3();

// --
// test
// --

function routineCall( test )
{
  let self = this;

  function routine( src )
  {
    return src;
  }

  function routine2()
  {
    return this.a;
  }

  function routine3( src )
  {
    return this.a + src;
  }

  /* */

  test.case = 'routine only';
  var got = _.routineCall( routine );
  test.identical( got, undefined );

  test.case = 'bound routine';
  var got = _.routineCall( routine.bind( this, 1 ) );
  test.identical( got, 1 );

  test.case = 'routine with context';
  var context = { a : 1 };
  var got = _.routineCall( context, routine2 );
  test.identical( got, 1 );

  test.case = 'routine with context and args';
  var context = { a : 1 };
  var got = _.routineCall( context, routine3, [ 1 ] );
  test.identical( got, 2 );

  /* */

  if( !Config.debug )
  return;

  test.case = 'no args';
  test.shouldThrowErrorSync( () => _.routineCall() );
  test.case = 'Expects routine as single arg';
  test.shouldThrowErrorSync( () => _.routineCall( {} ) );
  test.case = 'Expects context as first arg';
  test.shouldThrowErrorSync( () => _.routineCall( routine, {} ) );
  test.case = 'Expects arguments in array';
  test.shouldThrowErrorSync( () => _.routineCall( {}, routine, 1 ) );

}

//

function routineTolerantCall( test )
{
  let self = this;

  function routine( o )
  {
    return o.a + o.b * this.k;
  }

  routine.defaults =
  {
    a : null,
    b : null
  }

  function routine2( o )
  {
    return o;
  }

  routine2.defaults =
  {
    a : null,
    b : null
  }

  /* */

  test.case = 'routine with context and options';
  var context = { k : 0.5 };
  var got = _.routineTolerantCall( context, routine, { a : 1, b : 2 } );
  test.identical( got, 2 );

  test.case = 'routine gets only known options';
  var got = _.routineTolerantCall( this, routine2, { a : 1, b : 2, c : 2 } );
  test.identical( got, { a : 1, b : 2 } );

  /* */

  if( !Config.debug )
  return;

  test.case = 'no args';
  test.shouldThrowErrorSync( () => _.routineTolerantCall() );
  test.case = 'Expects routine as single arg';
  test.shouldThrowErrorSync( () => _.routineTolerantCall( {} ) );
  test.case = 'Expects context as first arg';
  test.shouldThrowErrorSync( () => _.routineTolerantCall( routine, {} ) );
  test.case = 'Expects options map as last arg';
  test.shouldThrowErrorSync( () => _.routineTolerantCall( {}, routine, 1 ) );
  test.case = 'routine without defaults';
  test.shouldThrowErrorSync( () => _.routineTolerantCall( {}, function a(){}, { a : 1 } ) );

}

//

function routinesCall( test )
{
  let self = this;

  var value1 = 'result1';
  var value2 = 4;
  var value3 = 5;

  function function1()
  {
    return value1;
  }

  function function2()
  {
    return value2;
  }

  function function3()
  {
    return value3;
  }

  function function5( x, y )
  {
    return x + y * this.k;
  }

  var function4 = testFunction3
  var function6 = testFunction4;

  var expected1 = [ value1 ];
  var expected2 = [ value2 + value3 + context3.k ];
  var expected3 = [ value1, value2, value3 ];
  var expected4 =
  [
    value2 + value3 + context3.k,
    value2 + value3 * context3.k,
    context3
  ];

  test.case = 'call single function without arguments and context';
  var got = _.routinesCall( function1 );
  test.identical( got, expected1 );

  test.case = 'call single function with context and arguments';
  var got = _.routinesCall( context3, testFunction3, [ value2, value3 ] );
  test.identical( got, expected2 );

  test.case = 'call functions without context and arguments';
  var got = _.routinesCall( [ function1, function2, function3 ] );
  test.identical( got, expected3 );

  test.case = 'call functions with context and arguments';
  var got = _.routinesCall( context3, [ function4, function5, function6 ], [ value2, value3 ] );
  test.identical( got, expected4 );

  if( !Config.debug )
  return;

  test.case = 'missed argument';
  test.shouldThrowErrorOfAnyKind( function()
  {
    _.routinesCall();
  });

  test.case = 'extra argument';
  test.shouldThrowErrorOfAnyKind( function()
  {
    _.routinesCall(
      context3,
      [ function1, function2, function3 ],
      [ function4, function5, function6 ],
      [ value2, value3 ]
    );
  });

  test.case = 'passed non callable object';
  test.shouldThrowErrorOfAnyKind( function()
  {
    _.routinesCall( null );
  });

  test.case = 'passed arguments as primitive value (no wrapped into array)';
  test.shouldThrowErrorOfAnyKind( function()
  {
    _.routinesCall( context3, testFunction3, value2 )
  });

}

//

function routineMake( test )
{
  let self = this;

  test.case = 'trivial';
  var src = 'return 1 + 1';
  var got = _.routineMake( src );
  test.identical( got(), 2 );

  test.case = 'with name';
  var src = 'return 1 + 1';
  var got = _.routineMake({ code : src, name : 'trivial' });
  test.identical( got.name, 'trivial')
  test.identical( got(), 2 );

  test.case = 'with return';
  var src = '1 + 1';
  var got = _.routineMake({ code : src, prependingReturn : 1 });
  test.identical( got(), 2 );

  test.case = 'with externals';
  var src = 'return a + b';
  var got = _.routineMake({ code : src, externals : { a : 1, b : 1 } });
  test.identical( got(), 2 );

  test.case = 'debugger, strict, filePath in code';
  var src = 'return 1 + 1';
  var got = _.routineMake
  ({
    code : src,
    filePath : '/source.js',
    usingStrict : 1,
    debug : 1
  });
  var source = got.toString();
  test.true( _.strHas( source, '// /source.js' ) );
  test.true( _.strHas( source, 'use strict' ) );
  test.true( _.strHas( source, 'debugger' ) );
  test.identical( got(), 2 );
}

//

function exec( test )
{
  var self = this;

  test.case = 'trivial';
  var src = 'return 1 + 1';
  var got = _.exec( src );
  test.identical( got, 2 );

  test.case = 'with context';
  var src = 'return this.a + this.b';
  var got = _.exec({ code : src, context : { a : 1, b : 1 } });
  test.identical( got, 2 );

  test.case = 'with return';
  var src = '1 + 1';
  var got = _.exec({ code : src, prependingReturn : 1 });
  test.identical( got, 2 );

  test.case = 'with externals';
  var src = 'return a + b';
  var got = _.exec({ code : src, externals : { a : 1, b : 1 } });
  test.identical( got, 2 );

  test.case = 'with externals + context';
  var src = 'return this.a + a + this.b + b';
  var got = _.exec
  ({
    code : src,
    externals : { a : 1, b : 1 },
    context : { a : 1, b : 1 }
  });
  test.identical( got, 4 );
}

//

function writeBasic( test )
{
  let context = this;
  let a = test.assetFor( false );

  test.case = 'options : tempPath, routine, dirPath - default';
  var src =
  {
    tempPath : a.abs( '.' ),
    routine : testApp
  }
  var got = _.program.write( src )
  test.identical( got.programPath, a.abs( '.' ) + '/testApp.js' );

  test.case = 'options : tempPath, routine, dirPath';
  var src =
  {
    tempPath : a.abs( '.' ),
    routine : testApp,
    dirPath : 'dir'
  }
  var got = _.program.write( src )
  test.identical( got.programPath, a.abs( '.' ) + '/dir/testApp.js' );

  /* - */

  function testApp(){}
}

//

function exportRoutine( test )
{

  function testRoutine( src )
  {
    return src;
  }

  let code = _.introspector.elementExportString( { testRoutine }, 'space', 'testRoutine' );

  code =
  `
  let space = Object.create( null );
  ${code}
  return space.testRoutine( 123 );
  `

  var got = _.routineExec( code );
  test.identical( got.result, 123 );
}

exportRoutine.description =
`
  Exports regular routine and executes it.
`

//

function exportUnitedRoutine( test )
{

  function testRoutine_head( routine, args )
  {
    let o = args[ 0 ];
    _.routineOptions( routine, o );
    return o;
  }

  function testRoutine_body( o )
  {
    return o.src;
  }

  testRoutine_body.defaults =
  {
    src : null
  }

  let testRoutine = _.routine.uniteCloning_( testRoutine_head, testRoutine_body );

  let code = _.introspector.elementExportString( { testRoutine }, 'space', 'testRoutine' );

  code =
  `
  let _ = wTools;
  let space = Object.create( null );
  ${code}
  return space.testRoutine({ src : 123 });
  `

  var got = _.routineExec( code );
  test.identical( got.result, 123 );
}

exportUnitedRoutine.description =
`
  Exports united routine and executes it.
`

//

function exportRoutineWithHeadOnly( test )
{
  function testRoutineHead( routine, args )
  {
    let o = args[ 0 ];
    _.routineOptions( routine, o );
    return o;
  }

  function testRoutine()
  {
    let o = testRoutine.head( testRoutine, arguments );
    return o.src;
  }

  testRoutine.head = testRoutineHead;
  testRoutine.defaults =
  {
    src : null
  }

  let code = _.introspector.elementExportString( { testRoutine }, 'space', 'testRoutine' );

  code =
  `
  let _ = wTools;
  let space = Object.create( null );
  ${code}
  return space.testRoutine({ src : 123 });
  `

  var got = _.routineExec( code );
  test.identical( got.result, 123 );
}

//

//

function exportRoutineWithBodyOnly( test )
{
  function testRoutineBody( o )
  {
    return o.src;
  }
  function testRoutine( ... args )
  {
    let o = args[ 0 ];
    _.routineOptions( testRoutine, o );
    return testRoutine.body( o );
  }

  testRoutine.body = testRoutineBody;
  testRoutine.defaults =
  {
    src : null
  }

  let code = _.introspector.elementExportString( { testRoutine }, 'space', 'testRoutine' );

  code =
  `
  let _ = wTools;
  let space = Object.create( null );
  ${code}
  return space.testRoutine({ src : 123 });
  `

  var got = _.routineExec( code );
  test.identical( got.result, 123 );
}

//

function exportSet( test )
{
  let set = _.setFrom([ 1, 2, 3 ])

  let code = _.introspector.elementExportString( { set }, 'space', 'set' );

  code =
  `
  let _ = wTools;
  let space = Object.create( null );
  ${code}
  return space.set.has( 3 );
  `

  var got = _.routineExec( code );
  test.identical( got.result, true );
}

//

function elementExportString( test )
{
  test.case = 'simple routine';
  function testRoutine1( src )
  {
    return src;
  }
  var got = _.introspector.elementExportString( { testRoutine : testRoutine1 }, 'space', 'testRoutine' );
  var exp =
`space.testRoutine = function testRoutine1( src )
    {
      return src;
    };

//
`;
  test.identical( got, exp );

  /* */

  test.case = 'united routine';
  function testRoutine2_head( routine, args )
  {
    let o = args[ 0 ];
    _.routineOptions( routine, o );
    return o;
  }
  function testRoutine2_body( o )
  {
    return o.src;
  }
  testRoutine2_body.defaults =
  {
    src : null
  };
  var testRoutine2 = _.routine.uniteCloning_( testRoutine2_head, testRoutine2_body );
  var got = _.introspector.elementExportString( { testRoutine : testRoutine2 }, 'space', 'testRoutine' );
  var exp =
`
    var _testRoutine2_head = function testRoutine2_head( routine, args )
      {
        let o = args[ 0 ];
        _.routineOptions( routine, o );
        return o;
      }

    //


    var _testRoutine2_body = function testRoutine2_body( o )
      {
        return o.src;
      }

    //

  _testRoutine2_body.defaults = { "src" : null }
    ;
  space.testRoutine = _.routine.uniteCloning_( _testRoutine2_head, _testRoutine2_body );
  space.testRoutine.defaults =
  { "src" : null };

//
`;
  test.equivalent( got, exp );

  /* - */

  test.case = 'routine with only head';
  function testRoutine3_head( routine, args )
  {
    let o = args[ 0 ];
    _.routineOptions( routine, o );
    return o;
  }
  function testRoutine3()
  {
    let o = testRoutine3.head( testRoutine3, arguments );
    return o.src;
  }
  testRoutine3.head = testRoutine3_head;
  testRoutine3.defaults =
  {
    src : null,
  };
  var got = _.introspector.elementExportString( { testRoutine : testRoutine3 }, 'space', 'testRoutine' );
  var exp =
`
  function testRoutine3_head( routine, args )
      {
        let o = args[ 0 ];
        _.routineOptions( routine, o );
        return o;
      }

    //


  space.testRoutine = function testRoutine3()
    {
      let o = testRoutine3.head( testRoutine3, arguments );
      return o.src;
    }
  space.testRoutine.head = testRoutine3_head;
  space.testRoutine.defaults =
  { "src" : null };

//
`;
  test.equivalent( got, exp );

  /* - */

  test.case = 'routine with only body';
  function testRoutine4_body( o )
  {
    return o.src;
  }
  function testRoutine4( ... args )
  {
    let o = args[ 0 ];
    _.routineOptions( testRoutine4, o );
    return testRoutine4.body( o );
  }
  testRoutine4.body = testRoutine4_body;
  testRoutine4.defaults =
  {
    src : null
  };
  var got = _.introspector.elementExportString( { testRoutine : testRoutine4 }, 'space', 'testRoutine' );
  var exp =
`
  function testRoutine4_body( o )
      {
        return o.src;
      }

    //


  space.testRoutine = function testRoutine4( ... args )
    {
      let o = args[ 0 ];
      _.routineOptions( testRoutine4, o );
      return testRoutine4.body( o );
    }
  space.testRoutine.body = testRoutine4_body;
  space.testRoutine.defaults =
  { "src" : null };

//
`;
  test.equivalent( got, exp );

  /* - */

  test.case = 'set to export';
  var set = _.setFrom([ 1, 2, 3 ])
  var got = _.introspector.elementExportString( { set }, 'space', 'set' );
  var exp =
`space.set = new Set([ 1, 2, 3 ]);

//
`;
  test.identical( got, exp );
}

// --
// declare
// --

let Self =
{

  name : 'Tools.l3.IntrospectorBasic',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    suiteTempPath : null,
  },

  tests :
  {

    routineCall,
    routineTolerantCall,

    routinesCall,

    routineMake,
    exec,

    writeBasic,

    exportRoutine,
    exportUnitedRoutine,
    exportRoutineWithHeadOnly,
    exportRoutineWithBodyOnly,
    exportSet,

    elementExportString,

  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
