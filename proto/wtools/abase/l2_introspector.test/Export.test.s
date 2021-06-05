( function _Introspector_test_s()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( 'Tools' );
  require( '../l2_introspector/Include.s' );
  _.include( 'wTesting' );
  // _.include( 'wFiles' );
  // _.include( 'wConsequence' );
}

const _global = _global_;
const _ = _global_.wTools;
const __ = _globals_.testing.wTools;
const fileProvider = __.fileProvider;
const path = fileProvider.path;

// --
// context
// --

// function onSuiteBegin()
// {
//   let self = this;
//   self.suiteTempPath = path.tempOpen( path.join( __dirname, '../..' ), 'Routine' );
// }
//
// //
//
// function onSuiteEnd()
// {
//   let self = this;
//   _.assert( _.strHas( self.suiteTempPath, 'Routine' ) )
//   path.tempClose( self.suiteTempPath );
// }

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

    let code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    let code2 = code.dstNode.exportString();
    let code3 =
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

    let code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    let code2 = code.dstNode.exportString();
    let code3 =
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
    let code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    let code2 = code.dstNode.exportString();
    console.log( _.strLinesNumber( code2 ) );

    let code3 =
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

    let code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    let code2 = code.dstNode.exportString();
    let code3 =
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

    let code = _.introspector.selectAndExportString( { routine1 }, env.dstNamespace, 'routine1' );
    let code2 = code.dstNode.exportString();
    let code3 =
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

function exportSet( test )
{

  act({ dstNamespace : 'namespace' });
  act({ dstNamespace : null });

  function act( env )
  {
    test.case = `${__.entity.exportStringSolo( env )}`;

    let set = _.set.from([ 1, 2, 3 ])
    let code = _.introspector.selectAndExportString( { set }, env.dstNamespace, 'set' );
    let code2 = code.dstNode.exportString();
    console.log( code2 );
    let code3 =
    `
    'use strict';
    const _ = _global_.wTools;
    let namespace = Object.create( null );
    ${code2}
    if( namespace.set )
    return namespace.set.has( 3 );
    else
    return set.has( 3 );
    `

    var got = _.routineExec( code3 );
    test.identical( got.result, true );

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
    let code = _.introspector.elementsExportNode({ srcContainer : src });
    let code2 = code.dstNode.exportString();
    console.log( _.strLinesNumber( code2 ) );
    let code3 =
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

    let code = _.introspector.selectAndExportString( { r1 }, null, 'r1' );
    let code2 = code.dstNode.exportString();
    console.log( _.strLinesNumber( code.dstNode.exportString() ) );
    let code3 =
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

    let code = _.introspector.selectAndExportString( { r1 }, env.dstNamespace, 'r1' );
    console.log( _.strLinesNumber( code.dstNode.exportString() ) );

    let code2 = code.dstNode.exportString();
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

    let code3 =
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

// //
//
// function selectAndExportString( test )
// {
//
//   /* */
//
//   test.case = 'simple routine';
//   function testRoutine1( src )
//   {
//     return src;
//   }
//   var got = _.introspector.selectAndExportString( { routine1 : testRoutine1 }, env.dstNamespace, 'routine1' );
//   var exp =
// `namespace.routine1 = function testRoutine1( src )
//   {
//     return src;
//   }
//
// //
// `;
//   test.identical( got.dstNode.exportString(), exp );
//
//   /* */
//
//   test.case = 'united routine';
//   function testRoutine2_head( routine, args )
//   {
//     let o = args[ 0 ];
//     _.routine.options( routine, o );
//     return o;
//   }
//   function testRoutine2_body( o )
//   {
//     return o.src;
//   }
//   testRoutine2_body.defaults =
//   {
//     src : null
//   };
//   var testRoutine2 = _.routine.unite( testRoutine2_head, testRoutine2_body );
//   var got = _.introspector.selectAndExportString( { routine1 : testRoutine2 }, 'namespace', 'routine1' );
//   var exp =
// `namespace.routine1 = ( function() {
//
//   const _testRoutine2_head = function testRoutine2_head( routine, args )
//     {
//       let o = args[ 0 ];
//       _.routine.options( routine, o );
//       return o;
//     }
//
//   const _testRoutine2_body = function testRoutine2_body( o )
//     {
//       return o.src;
//     }
//   _testRoutine2_body.defaults = { "src" : null }
//
//   const _testRoutine2_ = _.routine.unite
//   ({
//     head : _testRoutine2_head,
//     body : _testRoutine2_body,
//   });
//
//   return _testRoutine2_;
// })();
// namespace.routine1.defaults =
// { "src" : null }
//
// //
// `;
//   test.identical( got.dstNode.exportString(), exp );
//
//   /* - */
//
//   test.case = 'routine with only head';
//   function testRoutine3_head( routine, args )
//   {
//     let o = args[ 0 ];
//     _.routine.options( routine, o );
//     return o;
//   }
//   function testRoutine3()
//   {
//     let o = testRoutine3.head( testRoutine3, arguments );
//     return o.src;
//   }
//   testRoutine3.head = testRoutine3_head;
//   testRoutine3.defaults =
//   {
//     src : null,
//   };
//   var got = _.introspector.selectAndExportString( { routine1 : testRoutine3 }, 'namespace', 'routine1' );
//   var exp =
// `namespace.routine1 = ( function() {
//
//   const _testRoutine3_head = function testRoutine3_head( routine, args )
//     {
//       let o = args[ 0 ];
//       _.routine.options( routine, o );
//       return o;
//     }
//
//   const _testRoutine3_ = function testRoutine3()
//     {
//       let o = testRoutine3.head( testRoutine3, arguments );
//       return o.src;
//     }
//   _testRoutine3_.head = function testRoutine3_head( routine, args )
//       {
//         let o = args[ 0 ];
//         _.routine.options( routine, o );
//         return o;
//       }
//     _testRoutine3_.defaults = { "src" : null }
//   ;
// _testRoutine3_.head = _testRoutine3_head;
//   return _testRoutine3_;
// })();
// namespace.routine1.defaults =
// { "src" : null }
//
// //
// `;
//   test.identical( got.dstNode.exportString(), exp );
//
//   /* - */
//
//   test.case = 'routine with only body';
//   function testRoutine4_body( o )
//   {
//     return o.src;
//   }
//   function testRoutine4( ... args )
//   {
//     let o = args[ 0 ];
//     _.routine.options( testRoutine4, o );
//     return testRoutine4.body( o );
//   }
//   testRoutine4.body = testRoutine4_body;
//   testRoutine4.defaults =
//   {
//     src : null
//   };
//   var got = _.introspector.selectAndExportString( { routine1 : testRoutine4 }, 'namespace', 'routine1' );
//   var exp =
// `namespace.routine1 = ( function() {
//
//   const _testRoutine4_body = function testRoutine4_body( o )
//     {
//       return o.src;
//     }
//
//   const _testRoutine4_ = _.routine.unite
//   ({
//     body : _testRoutine4_body,
//   });
//
//   return _testRoutine4_;
// })();
// namespace.routine1.defaults =
// { "src" : null }
//
// //
// `;
//   test.identical( got.dstNode.exportString(), exp );
//
//   /* - */
//
//   test.case = 'set to export';
//   var set = _.setFrom([ 1, 2, 3 ])
//   var got = _.introspector.selectAndExportString( { set }, 'namespace', 'set' );
//   var exp =
// `namespace.set = new Set([ 1, 2, 3 ]);
//
// //
// `;
//   test.identical( got.dstNode.exportString(), exp );
//
//   /* - */
//
// }

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
    /* qqq : implement more test routine for united routine */
    exportSet,
    exportMapLocalityLocal,
    exportLocalsSimple,
    exportLocalsDuplication,
    // selectAndExportString,

  },

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
