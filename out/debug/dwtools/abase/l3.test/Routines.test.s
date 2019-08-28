( function _Routines_test_s( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wConsequence' );

  require( '../l3/RoutineBasic.s' );

}

var _global = _global_;
var _ = _global_.wTools;

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

  let routine = function( o )
  {
    return o.a + o.b * this.k;
  }

  routine.defaults =
  {
    a : null,
    b : null
  }

  let routine2 = function( o )
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
  var context = { k : .5 };
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

  function function5(x, y)
  {
    return x + y * this.k;
  }

  var function4 = testFunction3
  var function6 = testFunction4;

  var expected1 = [ value1 ],
    expected2 = [ value2 + value3 + context3.k ],
    expected3 = [ value1, value2, value3 ],
    expected4 =
    [
      value2 + value3 + context3.k,
      value2 + value3 * context3.k,
      context3
    ];

  test.case = 'call single function without arguments and context';
  var got = _.routinesCall( function1 );
  test.identical( got, expected1 );

  test.case = 'call single function with context and arguments';
  var got = _.routinesCall( context3, testFunction3, [value2, value3] );
  test.identical( got, expected2 );

  test.case = 'call functions without context and arguments';
  var got = _.routinesCall( [ function1, function2, function3 ] );
  test.identical( got, expected3 );

  test.case = 'call functions with context and arguments';
  var got = _.routinesCall( context3, [ function4, function5, function6 ], [value2, value3] );
  test.identical( got, expected4 );

  if( !Config.debug )
  return;

  test.case = 'missed argument';
  test.shouldThrowError( function()
  {
    _.routinesCall();
  });

  test.case = 'extra argument';
  test.shouldThrowError( function()
  {
    _.routinesCall(
      context3,
      [ function1, function2, function3 ],
      [ function4, function5, function6 ],
      [value2, value3]
    );
  });

  test.case = 'passed non callable object';
  test.shouldThrowError( function()
  {
    _.routinesCall( null );
  });

  test.case = 'passed arguments as primitive value (no wrapped into array)';
  test.shouldThrowError( function()
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
  test.is( _.strHas( source, '// /source.js' ) );
  test.is( _.strHas( source, 'use strict' ) );
  test.is( _.strHas( source, 'debugger' ) );
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

function execStages( test )
{
  let self = this;

  test.case = 'trivial';

  var src1Result;
  var src2Result;

  function src1( o )
  {
    src1Result = o.a;
    return o.a;
  }

  function src2( o )
  {
    src2Result = o.b;
    return o.b;
  }

  var o = { a : 1, b : 2 };
  var got = _.execStages( [ src1, src2 ], { args : [ o ] });

  return got.thenKeep( ( got ) =>
  {
    test.identical( src1Result, 1 );
    test.identical( src2Result, 2 );
    return got;
  })
}

// --
// declare
// --

var Self =
{

  name : 'Tools/base/l3/RoutineBasic',
  silencing : 1,

  context :
  {
  },

  tests :
  {
    routineCall,
    routineTolerantCall,

    routinesCall,

    routineMake,
    exec,

    execStages
  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
