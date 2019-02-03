(function _RoutineFundamentals_s_() {

'use strict';

/**
 * Collection of routines to generate functions, manage execution of such and analyze them.
  @module Tools/base/RoutineFundamentals
*/

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

}

let Self = _global_.wTools;
let _global = _global_;
let _ = _global_.wTools;

let _ArraySlice = Array.prototype.slice;
let _FunctionBind = Function.prototype.bind;
let _ObjectToString = Object.prototype.toString;
let _ObjectHasOwnProperty = Object.hasOwnProperty;
let _arraySlice = _.longSlice;

// --
// routine
// --

// function jsonParse( o )
// {
//   let result;

//   if( _.strIs( o ) )
//   o = { src : o }
//   _.routineOptions( jsonParse, o );
//   _.assert( arguments.length === 1 );

//   debugger; /* xxx: implement via GDF */

//   try
//   {
//     result = JSON.parse( o.src );
//   }
//   catch( err )
//   {
//     let src = o.src;
//     let position = /at position (\d+)/.exec( err.message );
//     if( position )
//     position = Number( position[ 1 ] );
//     let first = 0;
//     if( !isNaN( position ) )
//     {
//       let nearest = _.strLinesNearest( src, position );
//       first = _.strLinesCount( src.substring( 0, nearest.spans[ 0 ] ) );
//       src = nearest.splits.join( '' );
//     }
//     let err2 = _.err( 'Error parsing JSON\n', err, '\n', _.strLinesNumber( src, first ) );
//     throw err2;
//   }

//   return result;
// }

function jsonParse( o )
{
  let result;

  if( _.strIs( o ) )
  o = { src : o }
  _.routineOptions( jsonParse, o );
  _.assert( arguments.length === 1 );

  let selected = _.Gdf.Select({ in : 'string', out : 'structure', ext : 'json' });
  _.assert( selected.length === 1 );
  let jsonParser = selected[ 0 ];

  result = jsonParser.encode({ data : o.src });

  return result.data;
}

jsonParse.defaults =
{
  src : null,
}

//

function routineSourceGet( o )
{
  if( _.routineIs( o ) )
  o = { routine : o };

  _.routineOptions( routineSourceGet,o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.routineIs( o.routine ) );

  let result = o.routine.toSource ? o.routine.toSource() : o.routine.toString();

  function unwrap( code )
  {

    let reg1 = /^\s*function\s*\w*\s*\([^\)]*\)\s*\{/;
    let reg2 = /\}\s*$/;

    let before = reg1.exec( code );
    let after = reg2.exec( code );

    if( before && after )
    {
      code = code.replace( reg1,'' );
      code = code.replace( reg2,'' );
    }

    return [ before[ 0 ], code, after[ 0 ] ];
  }

  if( !o.withWrap )
  result = unwrap( result )[ 1 ];

  if( o.usingInline && o.routine.inlines )
  {
    // debugger;
    let prefix = '\n';
    for( let i in o.routine.inlines )
    {
      let inline = o.routine.inlines[ i ];
      prefix += '  let ' + i + ' = ' + _.toJs( inline, o.toJsOptions || Object.create( null ) ) + ';\n';
    }
    // debugger;
    let splits = unwrap( result );
    // debugger;
    splits[ 1 ] = prefix + '\n' + splits[ 1 ];
    result = splits.join( '' );
  }

  return result;
}

routineSourceGet.defaults =
{
  routine : null,
  wrap : 1,
  withWrap : 1,
  usingInline : 1,
  toJsOptions : null,
}

//

function routineMake( o )
{
  let result;

  if( _.strIs( o ) )
  o = { code : o };

  _.routineOptions( routineMake,o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.objectIs( o.externals ) || o.externals === null );
  _.assert( !!_realGlobal_ );

  /* prefix */

  let prefix = '\n';

  if( o.usingStrict )
  prefix += `'use strict';\n`;
  if( o.debug )
  prefix += 'debugger;\n';
  if( o.filePath )
  prefix += '// ' + o.filePath + '\n';

  if( o.externals )
  {
    if( !_realGlobal_.__wTools__externals__ )
    _realGlobal_.__wTools__externals__ = [];
    _realGlobal_.__wTools__externals__.push( o.externals );
    prefix += '\n';
    for( let e in o.externals )
    prefix += 'let ' + e + ' = ' + '_realGlobal_.__wTools__externals__[ ' + String( _realGlobal_.__wTools__externals__.length-1 ) + ' ].' + e + ';\n';
    prefix += '\n';
  }

  /* */

  let code;
  try
  {

    if( o.prependingReturn )
    try
    {
      code = prefix + 'return ' + o.code.trimLeft();
      result = make( code );
    }
    catch( err )
    {
      if( o.fallingBack )
      {
        code = prefix + o.code;
        result = make( code );
      }
      else throw err;
    }
    else
    {
      code = prefix + o.code;
      result = make( code );
    }

  }
  catch( err )
  {

    // console.error( 'Cant parse the routine :' );
    // console.error( code );
    err = _.err( 'Cant parse the routine\n', _.strLinesNumber( '\n' + code ), '\n', err );

    if( _global.document )
    {
      let e = document.createElement( 'script' );
      e.type = 'text/javascript';
      e.src = 'data:text/javascript;charset=utf-8,' + escape( o.code );
      document.head.appendChild( e );
    }
    else if( _global.Blob && _global.Worker )
    {
      let worker = _.makeWorker( code )
    }
    else
    {

      if( !Esprima && !_global.esprima )
      try
      {
        Esprima = require( 'esprima' );
      }
      catch( err )
      {
      }

      if( Esprima || _global.esprima )
      {
        let Esp = Esprima || _global.esprima;
        try
        {
          let parsed = Esp.parse( '(function(){\n' + code + '\n})();' );
        }
        catch( err2 )
        {
          debugger;
          throw _._err
          ({
            args : [ err , err2 ],
            level : 1,
            sourceCode : code,
          });
        }
      }
    }

    throw _.err( err, '\n', 'More information about error is comming asynchronously..' );
    return null;
  }

  return result;

  /* */

  function make( code )
  {
    try
    {
      if( o.name )
      code = 'return function ' + o.name + '()\n{\n' + code + '\n}';
      let result = new Function( code );
      if( o.name )
      result = result();
      return result;
    }
    catch( err )
    {
      debugger;
      throw _.err( err );
    }
  }

}

routineMake.defaults =
{
  debug : 0,
  code : null,
  filePath : null,
  // prependingReturn : 1,
  prependingReturn : 0,
  fallingBack : 1,
  usingStrict : 0,
  externals : null,
  name : null,
}

//

function routineExec( o )
{
  let result = Object.create( null );

  if( _.strIs( o ) )
  o = { code : o };
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.routineOptions( routineExec,o );

  o.routine = routineMake
  ({
    code : o.code,
    debug : o.debug,
    filePath : o.filePath,
    prependingReturn : o.prependingReturn,
    externals : o.externals,
  });

  /* */

  try
  {
    if( o.context )
    o.result = o.routine.apply( o.context );
    else
    o.result = o.routine.call( _global );
  }
  catch( err )
  {
    debugger;
    throw _._err
    ({
      args : [ err ],
      level : 1,
      sourceCode : o.routine.toString(),
      location : { path : o.filePath },
    });
  }

  return o;
}

var defaults = routineExec.defaults = Object.create( routineMake.defaults );

defaults.context = null;

//

function exec( o )
{
  _.assert( arguments.length === 1, 'Expects single argument' );
  if( _.strIs( o ) )
  o = { code : o };
  routineExec( o );
  return o.result;
}

var defaults = exec.defaults = Object.create( routineExec.defaults );

//

function execInWorker( o )
{
  let result;

  if( _.strIs( o ) )
  o = { code : o };
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.routineOptions( execInWorker,o );

  let blob = new Blob( [ o.code ], { type : 'text/javascript' } );
  let worker = new Worker( URL.createObjectURL( blob ) );

  throw _.err( 'not implemented' );

}

execInWorker.defaults =
{
  code : null,
}

//

function makeWorker( o )
{
  let result;

  if( _.strIs( o ) )
  o = { code : o };
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.routineOptions( makeWorker,o );

  let blob = new Blob( [ o.code ], { type : 'text/javascript' } );
  let worker = new Worker( URL.createObjectURL( blob ) );

  return worker;
}

makeWorker.defaults =
{
  code : null,
}

//

// function execAsyn( routine,onEnd,context )
// {
//   _.assert( arguments.length >= 3,'execAsyn :','Expects 3 arguments or more' );
//
//   let args = longSlice( arguments,3 ); throw _.err( 'not tested' );
//
//   _.timeOut( 0,function()
//   {
//
//     routine.apply( context,args );
//     onEnd();
//
//   });
//
// }

//

function execStages( stages,o )
{
  o = o || Object.create( null );

  _.routineOptionsPreservingUndefines( execStages,o );

  o.stages = stages;

  Object.preventExtensions( o );

  /* validation */

  _.assert( _.objectIs( stages ) || _.longIs( stages ),'Expects array or object ( stages ), but got',_.strType( stages ) );

  for( let s in stages )
  {

    let routine = stages[ s ];

    if( o.onRoutine )
    routine = o.onRoutine( routine );

    // _.assert( routine || routine === null,'execStages :','#'+s,'stage is not defined' );
    _.assert( _.routineIs( routine ) || routine === null, () => 'stage' + '#'+s + ' does not have routine to execute' );

  }

  /*  let */

  let ready = _.timeOut( 1 );
  let keys = Object.keys( stages );
  let s = 0;

  _.assert( arguments.length === 1 || arguments.length === 2 );

  /* begin */

  if( o.onBegin )
  ready.finally( o.onBegin );

  /* end */

  function handleEnd()
  {

    ready.finally( function( err,data )
    {

      if( err )
      throw _.errLogOnce( err );
      else
      return data;

    });

    if( o.onEnd )
    ready.finally( o.onEnd );

  }

  /* staging */

  function handleStage()
  {

    let stage = stages[ keys[ s ] ];
    let iteration = Object.create( null );

    iteration.index = s;
    iteration.key = keys[ s ];

    s += 1;

    if( stage === null )
    return handleStage();

    if( !stage )
    return handleEnd();

    /* arguments */

    iteration.stage = stage;
    if( o.onRoutine )
    iteration.routine = o.onRoutine( stage );
    else
    iteration.routine = stage;
    iteration.routine = _.routineJoin( o.context, iteration.routine, o.args );

    function routineCall()
    {
      let ret = iteration.routine();
      return ret;
    }

    /* exec */

    if( o.onEachRoutine )
    {
      ready.ifNoErrorThen( _.routineSeal( o.context, o.onEachRoutine, [ iteration.stage, iteration, o ] ) );
    }

    if( !o.manual )
    ready.ifNoErrorThen( routineCall );

    ready.timeOut( o.delay );

    handleStage();

  }

  /* */

  handleStage();

  return ready;
}

execStages.defaults =
{
  delay : 1,

  args : undefined,
  context : undefined,

  manual : false,

  onEachRoutine : null,
  onBegin : null,
  onEnd : null,
  onRoutine : null,
}

// --
//
// --

function routineNew( routine,name,usingExtendtype )
{
  _.assert( _.routineIs( routine ),'creating routine from string is not implemented' );

  if( usingExtendtype === undefined ) usingExtendtype = true;
  if( name === undefined ) name = '_noname_';

  let f = new Function( 'let _' + name + ' = arguments[ 0 ];\nreturn function ' + name + ' ()\n{\n  return ' + '_' + name + '(this, arguments) \n};' );
  let result = f( Function.prototype.apply.bind( routine ) );

  result._name = name;

  if( usingExtendtype )
  result.prototype = routine.prototype;

  return result;
}

//

function routineInfo( routine )
{

  _.assert( _.routineIs( routine ) );
  _.assert( arguments.length === 1, 'Expects single argument' );

  let result = _routineInfo
  ({
    routine : routine,
    tab : '',
  });

  return result;
}

//

function _routineInfo( o )
{
  let result = '';
  let assets = _.mapOnly( o.routine, _routineAssets );

  result += o.routine.name || 'noname';
  result += '\n';
  result += _.toStr( assets,{ levels : 2, tab : o.tab, prependTab : 1, wrap : 0 });
  result += '\n----------------\n';

  o.tab += '  ';

  for( let i in o.routine.inline )
  {
    result += o.tab + i + ' : ';
    let opt = _.mapExtend( null,o );
    o.routine = o.routine.inline[ i ];
    result += _routineInfo( o );
  }

  return result;
}

//

function routineCollectAssets( dst,routine )
{

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.routineIs( routine ) );

  return _routineCollectAssets( dst,routine,[] );
}

//

function _routineCollectAssets( dst,routine,visited )
{

  _.assert( _.routineIs( routine ) );
  _.assert( visited.indexOf( routine ) === -1 );
  visited.push( routine );

  if( routine.debugCollect )
  debugger;

  for( let a in _routineAssets )
  {

    if( !routine[ a ] )
    continue;

    dst[ a ] = dst[ a ] || {};
    _.assertMapHasNone( dst[ a ],routine[ a ] );
    debugger;
    dst[ a ] = _.mapsFlatten
    ({
      maps : [ dst[ a ],routine[ a ] ],
      assertingUniqueness : 1,
    });

  }

  if( dst.inline )
  for( let i in dst.inline )
  {

    if( visited.indexOf( dst.inline[ i ] ) === -1 )
    _routineCollectAssets( dst,dst.inline[ i ],visited );

  }

}
//

_global_._routineIsolate = [];
function routineIsolate( o )
{

  if( _.routineIs( o ) )
  o = { routine : o };
  _.assert( o.routine );
  _.assertMapHasOnly( o,routineIsolate.defaults );

  let name = o.name || o.routine.name;
  _.assert( _.strIs( name ) && name.length );

  _.routineCollectAssets( o,o.routine );

  //

  let parsed;

  if( o.inline || o.routine.inline )
  {

    parsed = _.routineParse
    ({
      routine : o.routine,
      inline : o.inline,
    });

  }
  else
  {

    parsed = { source : o.routine.toString() };

  }

  //

  if( o.routine.debugIsolate )
  debugger;

/*
  if( parsed.source.indexOf( 'doesAcceptZero' ) !== -1 )
  debugger;

  if( parsed.source.indexOf( 'doesAcceptZero' ) !== -1 )
  console.log( _.routineInfo( o.routine ) );

  if( parsed.source.indexOf( 'doesAcceptZero' ) !== -1 )
  _.routineCollectAssets( o,o.routine );

  if( parsed.source.indexOf( 'doesAcceptZero' ) !== -1 )
  debugger;
*/
  //

  let sconstant = '';
  if( o.constant )
  for( let s in o.constant )
  {
    sconstant += 'const ' + s + ' = ' + _.toStr( o.constant[ s ],{ levels : 99, escaping : 1 } ) + ';\n';
  }

  //

  let sexternal = '';
  if( o.external )
  {

    let descriptor = {};
    _routineIsolate.push( descriptor );
    descriptor.external = o.external;

    for( let s in o.external )
    {
      sexternal += 'const ' + s + ' = ' + '_routineIsolate[ ' + ( _routineIsolate.length-1 ) + ' ].external.' + s + '' + ';\n';
    }

  }

  //

  let source =
  sconstant + '\n' +
  sexternal + '\n' +
  ( o.debug ? 'debugger;\n' : '' ) +
  'return ( ' + parsed.source + ' );';

  //debugger;

  let result = new Function
  (
    o.args || [],
    source
  )();

  result.inline = o.inline;
  result.external = o.external;
  result.constant = o.constant;

  return result;
}

routineIsolate.defaults =
{
  routine : null,
  constant : null,
  external : null,
  inline : null,
  debug : 0,
  name : null,
}

//

function routineParse( o )
{
  if( _.routineIs( o ) )
  o = { routine : o };
  _.assert( o.routine );

  if( o.routine.debugParse )
  debugger;

  let source = o.routine.toString();
  let result = {};
  result.source = source;

  //

  function parse()
  {

    let r = /function\s+(\w*)\s*\(([^\)]*)\)(\s*{[^]*})$/;

    let parsed = r.exec( source );

    result.name = parsed[ 1 ];
    result.args = _.strSplitNonPreserving
    ({
      src : parsed[ 2 ],
      delimeter : ',',
      preservingDelimeters : 0,
    });
    result.body = parsed[ 3 ];

    result.reproduceSource = function()
    {
      return 'function ' + result.name + '( ' + result.args.join( ', ' ) + ' )\n' + result.body;
    }

    return result;
  }

  //

  if( o.routine.inline )
  {
    o.inline = o.inline || {};
    _.assertMapHasNone( o.inline,o.routine.inline );
    o.inline = _.mapsFlatten
    ({
      maps : [ o.inline,o.routine.inline ],
      assertingUniqueness : 1,
    });

  }

  //

  if( !o.inline || !Object.keys( o.inline ).length )
  return parse();

  //

  let inlined = 0;

  //

  function inlineFull( ins,sub )
  {

    let regexp = new RegExp( '(((let\\s+)?(\\w+)\\s*=\\s*)?|(\\W))(' + ins + ')\\s*\\.call\\s*\\(([^)]*)\\)','gm' );
    let rreturn = /return(\s+([^;}]+))?([;}]?)/mg;
    result.source = result.source.replace( regexp,function( original )
    {

      _.assert( sub.name );

      /* let */

      let r = '';
      let variableName = arguments[ 4 ];
      let body = sub.body;

      /* args */

      let args = _.strSplitNonPreserving
      ({
        src : arguments[ 7 ],
        delimeter : ',',
        preservingDelimeters : 0,
      });

      _.assert( args.length - 1 === sub.args.length );

      //debugger;
      let renamedArgs = _.strJoin([ '_' + sub.name + '_', sub.args, '_' ]);
      /*let renamedArgs = _.strStick( sub.args.slice(),'_' + sub.name + '_', '_' );*/
      body = _.strReplaceWords( body, sub.args, renamedArgs );

      for( let a = 0 ; a < renamedArgs.length ; a++ )
      {
        r += '  let ' + renamedArgs[ a ] + ' = ' + args[ a+1 ] + ';';
      }

      /* return */

      if( variableName )
      r += 'let ' + variableName + ';\n';

      body = body.replace( rreturn,function()
      {
        debugger;
        throw _.err( 'not tested' );

        let rep = '{ ';
        rep += variableName;
        rep += ' = ';
        rep += _.strStrip( arguments[ 2 ] || '' ) ? arguments[ 2 ] : 'undefined';
        rep += arguments[ 3 ];
        rep += ' }';
        return rep;
      });

      /* body */

      r += body;

      r = '\n/* _inlineFull_' + ins + '_ */\n{\n' + r + '\n}\n/* _inlineFull_' + ins + '_ */\n';

      /* validation */

      if( Config.debug )
      if( r.indexOf( 'return' ) !== -1 )
      {
        debugger;
        throw _.err( 'not expected' );
      }

      inlined += 1;

      return r;
    });

  }

  //

  function inlineCall( ins,sub )
  {

    let regexp = new RegExp( '(\\W)(' + ins + ')\\s*\\.','gm' );
    result.source = result.source.replace( regexp,function( a,b,c,d,e )
    {
      inlined += 1;
      return b + '/* _inlineCall_' + ins + '_ */' + '( ' + sub.source + ' ).' + '/* _inlineCall_' + ins + '_ */';
    });

  }

  //

  function inlineRegular( ins,sub )
  {

    let regexp = new RegExp( '(\\W)(' + ins + ')(\\W)','gm' );
    result.source = result.source.replace( regexp,function( a,b,c,d,e )
    {
      inlined += 1;
      return b + '/* _inlineRegular_' + ins + '_ */( ' + sub.source + ' )/* _inlineRegular_' + ins + '_ */' + d;
    });

  }

  //

  function inline( ins,sub )
  {

    inlined = 0;

    if( !_.routineIs( sub ) )
    throw _.err( 'not tested' );

/*
    if( _.routineIs( sub ) )
    {
      sub = _.routineParse( sub );
    }
    else
    {
      let sub = { source : sub };
      throw _.err( 'not tested' );
    }
    */

    sub = _.routineParse( sub );

    let regexp = new RegExp( 'function\\s+' + ins + '\\s*\\(','gm' );
    sub.source = sub.source.replace( regexp,'function _' + ins + '_(' );

    /**/

    let returnCount = _.strCount( sub.source,'return' );
    if( returnCount === 0 && sub.body )
    {

      inlineFull( ins,sub );

    }

    inlineCall( ins,sub );
    inlineRegular( ins,sub );

    /**/

    return inlined;
  }

  //

  function inlines()
  {
    let r = 0;

    for( let i in o.inline )
    {
      r += inline( i,o.inline[ i ] );
    }

    return r;
  }

  //

  if( !inlines() )
  return parse();

  if( !inlines() )
  return parse();

  debugger;
  while( inlines() );
  debugger;

  return parse();
}

// let

let _routineAssets =
{
  inline : 'inline',
  external : 'external',
  constant : 'constant',
}

// --
// declare
// --

let Extend =
{

  //

  jsonParse,

  routineSourceGet,

  routineMake,
  routineExec,

  exec,

  execInWorker,
  makeWorker,

  execStages,

  //

  routineNew,
  routineInfo,

  routineCollectAssets,
  _routineCollectAssets,
  routineIsolate,
  routineParse,

  _routineAssets,

  //

}

_.mapExtend( Self, Extend );

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
