( function _Program_s_()
{

'use strict';

/**
 * Collection of cross-platform routines to generate functions.
  @namespace Tools.program
  @extends Tools
  @module Tools/base/IntrospectorBasic
*/

const _global = _global_;
const _ = _global_.wTools;
_.program = _.program || Object.create( null );

// --
// program
// --

/* xxx : work on _.program.* to
  - implement er
  - make possible to make single call,
  - expose start method

var programPath = a.program({ routine : mainSingleBefore, locals : env }).programPath;
a.program({ routine : single1, locals : env });
a.program({ routine : single2, locals : env });

*/

function preformLocals_body( o )
{

  _.map.assertHasAll( o, preformLocals_body.defaults );

  if( o.locals === null )
  {
    o.locals = Object.create( null );
    o.locals.toolsPath = _.path.nativize( _.module.toolsPathGet() );
  }

  if( o.withSubmodules )
  {
    o.locals.pathAmend_body = _.module.filePathAmend.body;
    // o.postfixCode += '\n' + _.module.filePathAmend.body.toString() + '\n';
  }

  return o.locals;
}

preformLocals_body.defaults =
{
  locals : null,
  withSubmodules : true,
}

let preformLocals = _.routine.unite( null, preformLocals_body );

//

function preform_head( routine, args )
{
  let o = args[ 0 ];
  if( !_.mapIs( o ) )
  o = { routine : o }
  _.routine.options( routine, o );
  _.assert( args.length === 1 );
  _.assert( arguments.length === 2 );
  _.assert( _.routineIs( o.routine ) || _.strIs( o.sourceCode ), 'Expects either option::routine or option:sourceCode' );

  if( o.logger !== undefined )
  o.logger = _.logger.maybe( o.logger );

  if( o.moduleFile === null )
  {
    let moduleFile = _.module.fileNativeWith( 2 );
    if( moduleFile )
    o.moduleFile = moduleFile;
  }

  return o;
}

//

function preform_body( o )
{

  if( !o.name )
  o.name = o.routine.name;

  _.map.assertHasAll( o, preform_body.defaults );
  _.assert( !o.routine || !o.routine.name || o.name === o.routine.name );
  _.assert( _.strDefined( o.name ), 'Program should have name' );

  _.program.preformLocals.body.call( _.program, o );

  o._locals = o._locals || Object.create( null );

  if( o.sourceCode === null )
  {
    if( _.routineIs( o.routine ) )
    o.sourceCode = _.introspector.elementExportNode({ element : o.routine, name : o.name, locals : o._locals }).dstNode.exportString();
    else
    o.sourceCode = o.routine;
  }

  _.assert( _.str.is( o.sourceCode ) );

  if( o.postfixCode === null )
  o.postfixCode = '';

  if( o.locals )
  o.postfixCode += _.introspector.elementsExportNode({ srcContainer : o.locals, locals : o._locals }).dstNode.exportString();

  if( o.withSubmodules )
  {
    let paths = _.module.filePathGet
    ({
      locally : 1,
      globally : 0,
      moduleFile : o.moduleFile,
    }).local;
    _.assert( paths.length > 0 );
    _.assert( _.arrayIs( paths ) );
    o.postfixCode +=
`
  pathAmend_body
  ({
    moduleFile : module,
    paths : ${_.entity.exportJs( paths )},
    permanent : 0,
    globally : 0,
    locally : 1,
    recursive : 2,
    amending : 'prepend',
  });
`;
  }

  o.postfixCode +=
`
${o.name}();
`

  return o;
}

preform_body.defaults =
{
  routine : null,
  name : null,
  prefixCode : null,
  sourceCode : null,
  postfixCode : null,
  locals : null,
  withSubmodules : true,
  moduleFile : null,
}

let preform = _.routine.unite( preform_head, preform_body );

//

function write_body( o )
{

  _.map.assertHasAll( o, write_body.defaults );

  // let o2 = this.preform.body.call( this, _.mapOnly_( null, o, this.preform.body.defaults ) ); /* xxx : remove mapOnly */
  // _.props.extend( o, o2 );

  if( o.programPath === null )
  {
    if( !o.tempPath )
    {
      o.tempObject = _.program._tempDirOpen();
      o.tempPath = o.tempObject.tempPath;
    }
    _.assert( _.strIs( o.tempPath ), 'Expects temp path {- o.tempPath -}' );
    _.assert( _.strIs( o.dirPath ), 'Expects dir path {- o.dirPath -}' );
    o.programPath = _.path.join( o.tempPath, o.dirPath, o.namePrefix + o.name + o.namePostfix );
  }

  if( !o.rewriting )
  _.sure( !_.fileProvider.fileExists( o.programPath ), `Prgoram ${o.programPath} already exists!` );

  o.start = _.process.starter
  ({
    execPath : o.programPath,
    currentPath : _.path.dir( o.programPath ),
    outputCollecting : 1,
    outputPiping : 1,
    inputMirroring : 1,
    throwingExitCode : 1,
    logger : o.logger,
    mode : 'fork',
  });

  let code = ( o.prefixCode ? o.prefixCode + '\n//\n' : '' ) + o.sourceCode + ( o.postfixCode ? '\n//\n' + o.postfixCode : '' );

  if( o.logger && o.logger.verbosity )
  {
    // o.logger = o.logger || logger;
    o.logger.log( o.programPath );
    if( o.logger.verbosity >= 2 )
    o.logger.log( _.strLinesNumber( o.sourceCode ) );
  }

  _.fileProvider.fileWrite( o.programPath, code );

  return o;
}

write_body.defaults =
{
  ... preform_body.defaults,
  programPath : null,
  tempPath : null,
  dirPath : '.',
  namePrefix : '',
  namePostfix : '',
  rewriting : 0,
  logger : 0,
}

let write = _.routine.unite( preform_head, write_body );

//

function make_body( o )
{

  _.map.assertHasAll( o, make_body.defaults );

  // let o2 = this.preform.body.call( this, _.mapOnly_( null, o, this.preform.body.defaults ) ); /* xxx : remove mapOnly */
  // _.props.extend( o, o2 );

  this.preform.body.call( this, o ); /* xxx : remove mapOnly */
  this.write.body.call( this, o );

  return o;
}

make_body.defaults =
{
  ... write_body.defaults,
}

let make = _.routine.unite( preform_head, make_body );

//

function _tempDirOpen()
{
  return _.fileProvider.tempOpen( ... arguments );
}

// --
// program extension
// --

let ProgramExtension =
{

  preformLocals,
  preform,
  write,
  make,

  _tempDirOpen,

}

Object.assign( _.program, ProgramExtension );

})();
