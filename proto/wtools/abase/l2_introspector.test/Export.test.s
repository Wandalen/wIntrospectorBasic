( function _Introspector_test_s()
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
// test
// --

function exportRoutine( test )
{

  act({ dstNamespace : 'namespace' });
  act({ dstNamespace : null });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    var code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    var code2 = code.dstNode.exportString();
    var code3 =
    `
    'use strict';
    let namespace = Object.create( null );
    ${code2}
    if( namespace.routine1 )
    return namespace.routine1( 3 );
    else
    return routine1( 3 );
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, 3 );

  }

  function routine1( src )
  {
    return src;
  }

}

exportRoutine.description =
`
  Exports regular routine and executes it.
`

//

function exportRoutineDefaults( test )
{

  routine1.defaults =
  {
    factor1 : 1,
    factor2 : 2,
  }

  act({ dstNamespace : 'namespace' });
  act({ dstNamespace : null });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    var exported = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    var exp = [];
    if( env.dstNamespace === null )
    exp = [ 'routine1' ];
    test.identical( _.props.keys( exported.dstNode.locals ), exp );
    var code2 = exported.dstNode.exportString();
    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( null );
    ${code2}
    if( namespace.routine1 )
    return namespace.routine1();
    else
    return routine1();
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, 3 );

  }

  function routine1( o )
  {
    o = _.routine.options( routine1, o || null );
    return o.factor1 + o.factor2;
  }

}

exportRoutineDefaults.description =
`
  defaults of a routine is also exported
`

//

function exportUnitedRoutine( test )
{

  routine1_body.defaults =
  {
    src : null
  }

  act({ dstNamespace : 'namespace' });
  act({ dstNamespace : null });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    let routine1 = _.routine.unite( routine1_head, routine1_body );
    var code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    var code2 = code.dstNode.exportString();
    console.log( _.strLinesNumber( code2 ) );

    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( null );
    ${code2}
    if( namespace.routine1 )
    return namespace.routine1({ src : 3 });
    else
    return routine1({ src : 3 });
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, 3 );

  }

  function routine1_head( routine, args )
  {
    let o = args[ 0 ];
    _.routine.options( routine, o );
    return o;
  }

  function routine1_body( o )
  {
    return o.src;
  }

}

exportUnitedRoutine.description =
`
  Exports united routine and executes it.
`

//

function exportRoutineWithHeadOnly( test )
{

  routine1.head = testRoutineHead;
  routine1.defaults =
  {
    src : null
  }

  act({ dstNamespace : 'namespace' });
  act({ dstNamespace : null });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    var code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    var code2 = code.dstNode.exportString();
    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( null );
    ${code2}
    if( namespace.routine1 )
    return namespace.routine1({ src : 3 });
    else
    return routine1({ src : 3 });
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, 3 );

  }

  function testRoutineHead( routine, args )
  {
    let o = args[ 0 ];
    _.routine.options( routine, o );
    return o;
  }

  function routine1()
  {
    let o = routine1.head( routine1, arguments );
    return o.src;
  }

}

//

function exportRoutineWithBodyOnly( test )
{

  routine1.body = testRoutineBody;
  routine1.defaults = routine1.body.defaults =
  {
    src : null
  }

  act({ dstNamespace : 'namespace' });
  act({ dstNamespace : null });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    var code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    var code2 = code.dstNode.exportString();
    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( null );
    ${code2}
    if( namespace.routine1 )
    return namespace.routine1({ src : 3 });
    else
    return routine1({ src : 3 });
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, 3 );

  }

  function testRoutineBody( o )
  {
    return o.src;
  }
  function routine1( ... args )
  {
    let o = args[ 0 ];
    _.routine.options( routine1, o );
    return routine1.body( o );
  }

}

//

function exportRoutineWithFunctor( test )
{
  var routine1 = _.entity.lengthOf;

  act({ dstNamespace : 'namespace' });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    var code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    var code2 = code.dstNode.exportString();
    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( _.entity );
    debugger
    ${code2}
    return namespace.routine1([ 1 ]);
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, 1 );

  }

}

//

function exportRoutineComposed( test )
{

  var routine1 = _.routine.s.compose( [ _routine0, _routine1 ] );

  act({ dstNamespace : 'namespace' });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    var code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    var code2 = code.dstNode.exportString();
    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( _.entity );
    debugger
    ${code2}
    return namespace.routine1( 1 );
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, [ 2, 3 ] );

  }

  function _routine0( src )
  {
    return src + 1;
  }

  function _routine1( src )
  {
    return src + 2;
  }

}

//

function exportRoutineComposedComplex( test )
{
  function _routineWithDefaults( o )
  {
    if( _.number.is( o ) )
    o = { src : o };
    o = _.routine.options_( _routineWithDefaults, o );
    return o.src + 1;
  }
  _routineWithDefaults.defaults =
  {
    src : null
  }

  /* */

  function _routineUnited_head( routine, args )
  {
    let o = args[ 0 ];
    if( _.number.is( o ) )
    o = { src : o };
    _.routine.options_( routine, o );
    return o;
  }
  function _routineUnited_body( o )
  {
    return o.src + 2;
  }
  _routineUnited_body.defaults =
  {
    src : null
  }

  let _routineUnited = _.routine.unite( _routineUnited_head, _routineUnited_body );

  /* */

  var routine1 = _.routine.s.compose( [ _routineWithDefaults, _routineUnited ] );

  act({ dstNamespace : 'namespace' });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    var code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    var code2 = code.dstNode.exportString();
    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( _.entity );
    debugger
    ${code2}
    return namespace.routine1( 1 );
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, [ 2, 3 ] );

  }

}

//

function exportUnitedRoutineWithMultipleHeads( test )
{
  function _routineUnited_head1( routine, args )
  {
    let o = args[ 0 ];
    if( _.number.is( o ) )
    o = { src : o };
    return o;
  }

  function _routineUnited_head2( routine, args )
  {
    let o = args[ 0 ];
    _.routine.options_( routine, o );
    return o;
  }

  function _routineUnited_body( o )
  {
    o.src += 1;
    return o;
  }

  _routineUnited_body.defaults =
  {
    src : null
  }

  let head =
  [
    _routineUnited_head1,
    _routineUnited_head2,
  ]

  let routine1 = _.routine.unite( head, _routineUnited_body );

  /* - */

  act({ dstNamespace : 'namespace' });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    var code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    var code2 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( _.entity );
    ${code.dstNode.exportString()}
    return namespace.routine1( 1 );
    `

    var got = _.routineExec( code2 );
    test.identical( got.result, { src : 2 } );

    /* */

    test.case = `${__.entity.exportStringSolo( env )} throwing`;

    var code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    var code2 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( _.entity );
    ${code.dstNode.exportString()}
    return namespace.routine1({ dst : 1 });
    `

    test.shouldThrowErrorSync( () => _.routineExec( code2 ), ( err ) =>
    {
      test.true( _.strHas( err, 'does not expect options: "dst"' ) )
    });
  }
}

//

function exportSet( test )
{

  act({ dstNamespace : 'namespace' });
  act({ dstNamespace : null });

  function act( env )
  {

    /* */

    test.case = `basic, ${__.entity.exportStringSolo( env )}`;
    var element = _.set.from([ 1, 2, 3 ])
    var code = _.introspector.selectAndExportString( { element }, env.dstNamespace, 'element' );
    var code2 = code.dstNode.exportString();
    var exp =
`
namespace.element = new Set([ 1, 2, 3 ]);
//
`
    if( env.dstNamespace === null )
    exp =
`
var element = new Set([ 1, 2, 3 ]);
//
`
    test.equivalent( code2, exp );
    console.log( code2 );
    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( null );
    ${code2}
    if( namespace.element )
    return namespace.element.has( 3 );
    else
    return element.has( 3 );
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, true );

    /* */

  }

}

//

function exportArray( test )
{

  act({ dstNamespace : 'namespace' });
  act({ dstNamespace : null });

  function act( env )
  {

    /* */

    test.case = `basic, ${__.entity.exportStringSolo( env )}`;
    var element = [ 1, 2, 3 ];
    var code = _.introspector.selectAndExportString( { element }, env.dstNamespace, 'element' );
    var code2 = code.dstNode.exportString();
    var exp =
`
namespace.element = [ 1, 2, 3 ];
//
`
    if( env.dstNamespace === null )
    exp =
`
var element = [ 1, 2, 3 ];
//
`
    test.equivalent( code2, exp );
    console.log( code2 );
    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( null );
    ${code2}
    if( namespace.element )
    return namespace.element.includes( 3 );
    else
    return element.includes( 3 );
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, true );

    /* */

  }

}

//

function exportComplex( test )
{

  act({ dstNamespace : 'namespace' });
  act({ dstNamespace : null });

  function act( env )
  {

    /* */

    test.case = `2 levels, ${__.entity.exportStringSolo( env )}`;
    var element = [ _.set.from([ 'a', 'b' ]), [ 1, 2 ], { a : 1, b : 2 }, new HashMap([ [ 'a', 1 ], [ 'b', 2 ] ]) ]
    var code = _.introspector.selectAndExportString( { element }, env.dstNamespace, 'element' );
    var code2 = code.dstNode.exportString();
    var exp =
`
xxx
`
    if( env.dstNamespace === null )
    exp =
`
xxx
`
    test.equivalent( code2, exp );
    console.log( code2 );
    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( null );
    ${code2}
    if( namespace.element )
    return namespace.element[ 0 ].has( 'a' );
    else
    return element[ 0 ].has( 'a' );
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, true );

    /* */

  }

}

//

function exportMapLocalityLocal( test )
{

  act({ dstNamespace : 'namespace' });
  act({ dstNamespace : null });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    let src =
    {
      r1,
      f1 : 1,
      f2 : 10,
    }
    var code = _.introspector.elementsExportNode({ srcContainer : src });
    var code2 = code.dstNode.exportString();
    console.log( _.strLinesNumber( code2 ) );
    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    debugger;
    ${code2}
    return r1();
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, 13 );

  }

  function r1()
  {
    return f1 + f2 + 2;
  }

}

//

function exportLocalsSimple( test )
{

  act({ dstNamespace : 'namespace' });
  act({ dstNamespace : null });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    r1.meta = {};
    r1.meta.locals = {};
    r1.meta.locals.r2 = r2;
    r1.meta.locals.r3 = r3;
    r1.meta.locals.factor = 13;

    var code = _.introspector.selectAndExportString( { r1 }, null, 'r1' );
    var code2 = code.dstNode.exportString();
    console.log( _.strLinesNumber( code.dstNode.exportString() ) );
    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    ${code2}
    return r1();
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, 18 );

  }

  function r1()
  {
    return r2() + r3() + factor;
  }

  function r2()
  {
    return 2;
  }

  function r3()
  {
    return 3;
  }

}

//

function exportLocalsDuplication( test )
{

  act({ dstNamespace : 'namespace' });
  // act({ dstNamespace : null });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    r1.meta = {};
    r1.meta.locals = {};
    r1.meta.locals.r2 = r2;
    r1.meta.locals.r3 = r3;

    r2.meta = {};
    r2.meta.locals = {};
    r2.meta.locals.r4 = r4;

    r3.meta = {};
    r3.meta.locals = {};
    r3.meta.locals.r4 = r4;

    var code = _.introspector.selectAndExportString( { r1 }, env.dstNamespace, 'r1' );
    console.log( _.strLinesNumber( code.dstNode.exportString() ) );

    var code2 = code.dstNode.exportString();
    test.identical( _.strCount( code2, 'function r1' ), 1 );
    test.identical( _.strCount( code2, 'function r2' ), 1 );
    test.identical( _.strCount( code2, 'function r3' ), 1 );
    test.identical( _.strCount( code2, 'function r4' ), 1 );

    var exp =
    `
var r4 = function r4()
{
  return 4;
}

//

var r2 = function r2()
{
  return r4();
}

//

var r3 = function r3()
{
  return r4();
}

//

${ env.dstNamespace ? 'namespace.r1 = function r1()' : 'var r1 = function r1()' }
{
  return r2() + r3();
}

//

`
    test.equivalent( code2, exp );

    var code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    const namespace = Object.create( null );
    ${code2}
    if( namespace.r1 )
    return namespace.r1();
    else
    return r1();
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, 8 );

  }

  function r1()
  {
    return r2() + r3();
  }

  function r2()
  {
    return r4();
  }

  function r3()
  {
    return r4();
  }

  function r4()
  {
    return 4;
  }

}

// --
// declare
// --

const Proto =
{

  name : 'Tools.introspector.Export',
  silencing : 1,

  tests :
  {

    exportRoutine,
    exportRoutineDefaults,
    exportUnitedRoutine,
    exportRoutineWithHeadOnly,
    exportRoutineWithBodyOnly,
    exportRoutineWithFunctor,
    exportRoutineComposed,
    exportRoutineComposedComplex,
    exportUnitedRoutineWithMultipleHeads,
    /* qqq : implement more test routine for united routine */
    exportSet,
    exportArray,
    // exportComplex, /* qqq : xxx : implement */
    exportMapLocalityLocal,
    exportLocalsSimple,
    exportLocalsDuplication,

  },

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
