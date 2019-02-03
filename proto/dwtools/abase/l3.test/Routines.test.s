( function _Routines_test_s( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );

  require( '../l4/External.s' );

}

var _global = _global_;
var _ = _global_.wTools;

// --
// test
// --

// --
// declare
// --

var Self =
{

  name : 'Tools/base/l3/RoutineFundamentals',
  silencing : 1,

  context :
  {
  },

  tests :
  {
  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
