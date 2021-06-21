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

function groupPreformLocals_body( o )
{

  _.map.assertHasAll( o, groupPreformLocals_body.defaults );

  if( o.locals === null )
  {
    o.locals = Object.create( null );
    o.locals.toolsPath = _.path.nativize( _.module.toolsPathGet() );
  }

  if( o.withSubmodules )
  {
    o.locals.pathAmend_body = _.module.filePathAmend.body;
  }

  return o.locals;
}

groupPreformLocals_body.defaults =
{
  locals : null,
  withSubmodules : true,
}

let groupPreformLocals = _.routine.unite( null, groupPreformLocals_body );

//

function filePreform( o )
{

  _.routine.options( filePreform, o );
  _.assert( !o.routine || !o.routine.name || o.name === o.routine.name );
  _.assert( _.strDefined( o.name ), 'Program should have name' );
  _.assert( _.routineIs( o.routine ) || _.strIs( o.routineCode ), 'Expects either option::routine or option:routineCode' );

  o.codeLocals = o.codeLocals || Object.create( null );

  if( !o.routineCode )
  {
    if( _.routineIs( o.routine ) )
    {
      let r = _.introspector.elementExportNode({ element : o.routine, name : o.name, locals : o.codeLocals });
      o.routineCode = r.dstNode.exportString();
    }
    else
    {
      o.routineCode = o.routine;
    }
  }

  _.assert( _.str.is( o.routineCode ) );

  if( o.group.locals || o.locals )
  if( o.localsCode === undefined || o.localsCode === null )
  {
    o.localsCode = '';
    if( o.group.locals )
    {
      let exported = _.introspector.elementsExportNode({ srcContainer : o.group.locals, locals : o.codeLocals });
      o.localsCode += exported.dstNode.exportString();
    }
    if( o.locals )
    {
      let exported = _.introspector.elementsExportNode({ srcContainer : o.locals, locals : o.codeLocals });
      o.localsCode += exported.dstNode.exportString();
    }
  }

  if( !o.startCode )
  {

    if( o.group.withSubmodules )
    {
      let paths = _.module.filePathGet
      ({
        locally : 1,
        globally : 0,
        moduleFile : o.group.moduleFile,
      }).local;
      _.assert( paths.length > 0 );
      _.assert( _.arrayIs( paths ) );
      o.startCode +=
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

    o.startCode +=
`
${o.name}();
`
  }

  o.fullCode = '';
  add( o.group.prefixCode, 'group prefix code' );
  add( o.prefixCode, 'prefix code' );

  add( o.routineCode );
  add( o.localsCode, 'locals code' );
  add( o.group.beforeStartCode, 'group before start code' );
  add( o.beforeStartCode, 'before start code' );
  add( o.startCode, 'start code' );
  add( o.afterStartCode, 'after start code' );
  add( o.group.afterStartCode, 'group after start code' );

  add( o.postfixCode, 'postfix code' );
  add( o.group.postfixCode, 'group postfix code' );

  if( o.group.logger && o.group.logger.verbosity )
  {
    o.group.logger.log( o.programPath );
    if( o.group.logger.verbosity >= 2 )
    o.group.logger.log( _.strLinesNumber( o.routineCode ) );
  }

  return o;

  function add( code, name )
  {
    if( !code )
    return;
    if( name )
    o.fullCode += `\n/* -- ${name} -- */\n`;
    o.fullCode += code;
  }

}

filePreform.defaults =
{

  routine : null,
  name : null,
  prefixCode : '',
  routineCode : '',
  postfixCode : '',
  beforeStartCode : '',
  startCode : '',
  afterStartCode : '',

  group : null,
  locals : null,
  codeLocals : null,
  localsCode : null,

}

//

function groupPreform_body( o )
{

  _.map.assertHasAll( o, groupPreform_body.defaults );
  _.map.assertHasOnly( o, groupPreform_body.defaults );

  /* locals */

  _.program.groupPreformLocals.body.call( _.program, o );
  o.entry.codeLocals = o.entry.codeLocals || Object.create( null );

  /* files */

  o.files = o.files || Object.create( null );
  _.assert( _.aux.is( o.files ) );

  _.assert( _.aux.is( o.entry ) );
  if( !o.entry.name && o.entry.routine )
  o.entry.name = o.entry.routine.name;
  _.assert( !o.entry.routine || !o.entry.routine.name || o.entry.name === o.entry.routine.name );
  _.assert( _.strDefined( o.entry.name ), 'Program should have name' );

  _.assert( o.files[ o.entry.name ] === undefined || o.files[ o.entry.name ] === o.entry );
  o.files[ o.entry.name ] = o.entry.routine;

  o.files = o.files || Object.create( null );
  o.files[ o.entry.name ] = o.entry;

  for( let name in o.files )
  {
    if( name === o.entry.name )
    continue;
    let program = o.files[ name ];
    if( _.routine.is( program ) )
    {
      let routine = program;
      program = o.files[ name ] = _.map.extend( null, o.entry );
      program.routine = routine;
      program.name = name;
      delete program.codeLocals;
    }
    else
    {
      _.map.supplement( program, _.mapBut_( null, o.entry, [ 'codeLocals' ] ) );
      program.name = name;
    }
  }

  for( let name in o.files )
  {
    let file = o.files[ name ];
    _.assert( name === file.name );
    _.assert( !file.routine || !file.routine.name || file.name === file.routine.name );
    _.program.filePreform( o.files[ name ] );
  }

  return o;
}

groupPreform_body.defaults =
{
  entry : null,
  files : null,
  locals : null,
  withSubmodules : true,
  moduleFile : null,
  prefixCode : '',
  beforeStartCode : '',
  afterStartCode : '',
  postfixCode : '',
}

let groupPreform = _.routine.unite( null, groupPreform_body );

//

function preform_head( routine, args )
{
  let o = args[ 0 ];
  if( !_.mapIs( o ) )
  o = { entry : o }
  _.routine.options( routine, o );
  _.assert( args.length === 1 );
  _.assert( arguments.length === 2 );

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

  _.map.assertHasAll( o, preform_body.defaults );
  _.assert( o.group === null );
  _.assert( o.localsCode === undefined );
  _.assert
  (
    _.routine.is( o.entry ) || _.str.is( o.entry ) || _.aux.is( o.entry ) || o.entry === null,
    () => `Expects entry which is any of [ routine, string, aux, null ], but it is ${_.strType( o.entry )}`
  );
  _.assert( ( o.entry === null ) === ( _.strDefined( o.routineCode ) ) );

  o.group = Object.create( null );
  o.group.files = o.files;
  o.group.locals = o.locals;
  o.group.withSubmodules = o.withSubmodules;
  o.group.moduleFile = o.moduleFile;
  o.group.files = o.files;
  o.group.prefixCode = o.prefixCode;
  o.group.postfixCode = o.postfixCode;
  o.group.beforeStartCode = o.beforeStartCode;
  o.group.afterStartCode = o.afterStartCode;
  delete o.files;
  delete o.locals;
  delete o.withSubmodules;
  delete o.moduleFile;
  delete o.prefixCode;
  delete o.postfixCode;
  delete o.beforeStartCode;
  delete o.afterStartCode;

  if( _.strDefined( o.routineCode ) )
  entryFromRoutineCode();
  if( _.str.is( o.entry ) )
  entryFromStr();
  else if( _.routine.is( o.entry ) )
  entryFromRoutine();
  else
  entryFromAux();

  o.group.entry.name = o.group.entry.name || o.name;
  o.group.entry.routineCode = o.group.entry.routineCode || o.routineCode;
  o.group.entry.startCode = o.group.entry.startCode || o.startCode;
  o.group.entry.group = o.group;
  delete o.name;
  delete o.routineCode;
  delete o.startCode;

  _.program.groupPreform.body.call( _.program, o.group );
  o.files = o.group.files;

  return o;

  /* */

  function entryFromFiles( name )
  {
    if( o.group.files )
    {
      let entry2 = o.group.files[ name ];
      if( entry2 )
      {
        if( _.aux.is( entry2 ) )
        {
          _.assert( entry2.name === undefined || entry2.name === name );
          entry2.name = name;
          return entry2;
        }
        else
        {
          _.assert( _.routine.is( entry2 ) );
          let entry = Object.create( null );
          entry.routine = entry2;
          entry.name = name;
          o.group.files[ name ] = entry;
          return entry
        }
      }
    }
  }

  /* */

  function entryFromRoutineCode()
  {
    let entry;

    _.assert( o.entry === null );
    _.assert( _.strDefined( o.routineCode ) );
    _.assert( _.strDefined( o.name ) );

    if( o.group.files )
    {
      entry = entryFromFiles( o.name );
    }

    if( !entry )
    {
      entry = Object.create( null );
      entry.name = o.name;
    }

    entry.routineCode = o.routineCode;
    o.entry = o.group.entry = entry;
  }

  /* */

  function entryFromStr()
  {
    let name = o.entry;
    _.assert( _.aux.is( o.group.files ), 'If entry is specified as a name of a file then option::files should also be provided' );
    _.assert( !!o.group.files[ name ], () => `No file "${name}"` );
    let entry = o.group.files[ name ];
    if( _.aux.is( entry ) )
    {
      _.assert( name === entry.name || !entry.name );
      entry.name = name;
    }
    else
    {
      _.assert( _.routine.is( entry ) );
      entry = { name, routine : entry }
    }
    o.group.files[ o.entry ] = o.group.entry = o.entry = entry;
  }

  /* */

  function entryFromRoutine()
  {
    let entry;
    let routine = o.entry;
    let name = o.name || o.entry.name;
    _.assert( _.strDefined( name ) );
    if( o.group.files )
    {
      let entry2 = entryFromFiles( name );
      if( entry2 )
      {
        _.assert( !entry2.routine || entry2.routine === routine );
        entry2.routine = routine;
        entry = o.entry = o.group.entry = entry2;
      }
    }
    if( !entry )
    {
      entry = o.entry = o.group.entry = Object.create( null );
      entry.routine = routine;
      entry.name = name;
      if( o.group.files )
      o.group.files[ name ] = entry;
    }
  }

  /* */

  function entryFromAux()
  {
    _.assert( _.aux.is( o.entry ) );
    let entry = o.group.entry = o.entry;
    let name = o.name || o.entry.name || o.entry.routine.name;
    _.assert( _.strDefined( name ) );

    if( o.group.files )
    {
      let entry2 = o.group.files[ name ];
      if( entry2 )
      {
        if( _.aux.is( entry2 ) )
        {
          _.assert( entry2 === entry );
        }
        else
        {
          _.assert( _.routine.is( o.group.files[ name ] ) );
          _.assert( o.group.files[ name ] === entry.routine );
        }
      }
      o.group.files[ name ] = entry;
    }
  }

  /* */

}

preform_body.defaults =
{
  ... _.mapBut_( null, filePreform.defaults, [ 'group', 'codeLocals', 'localsCode', 'routine' ] ),
  entry : null,
  files : null,
  group : null,
  locals : null,
  withSubmodules : true,
  moduleFile : null,
}

let preform = _.routine.unite( preform_head, preform_body );

//

function fileWrite( o )
{

  _.routine.options( fileWrite, o );

  if( o.programPath === null )
  {
    if( !o.group.tempPath )
    {
      o.group.tempObject = _.program._tempOpen();
      o.group.tempPath = o.group.tempObject.tempPath;
    }
    _.assert( _.strIs( o.group.tempPath ), 'Expects temp path {- o.tempPath -}' );
    _.assert( _.strIs( o.group.dirPath ), 'Expects dir path {- o.dirPath -}' );
    o.programPath = _.path.join( o.group.tempPath, o.group.dirPath, o.group.namePrefix + o.name + o.group.namePostfix );
  }

  if( !o.group.rewriting )
  _.sure( !_.fileProvider.fileExists( o.programPath ), `Prgoram ${o.programPath} already exists!` );

  o.start = _.process.starter
  ({
    execPath : o.programPath,
    currentPath : _.path.dir( o.programPath ),
    outputCollecting : 1,
    outputPiping : 1,
    inputMirroring : 1,
    throwingExitCode : 1,
    logger : o.group.logger,
    mode : 'fork',
  });

  _.fileProvider.fileWrite( o.programPath, o.fullCode );

  return o;
}

fileWrite.defaults =
{
  ... filePreform.defaults,
  fullCode : null,
  programPath : null,
}

//

function groupWrite_body( o )
{

  _.map.assertHasAll( o, groupWrite_body.defaults );
  _.map.assertHasOnly( o, groupWrite_body.defaults );

  for( let name in o.files )
  {
    let program = o.files[ name ];
    if( program.programPath === undefined )
    program.programPath = null;
    _.program.fileWrite( program );
  }

  return o;
}

groupWrite_body.defaults =
{
  ... groupPreform.defaults,
  tempPath : null,
  dirPath : '.',
  namePrefix : '',
  namePostfix : '',
  rewriting : 0,
  logger : 0,
  entry : null,
  files : null,
}

let groupWrite = _.routine.unite( null, groupWrite_body );

//

function write_body( o )
{

  _.map.assertHasAll( o, write_body.defaults );
  _.map.assertHasOnly( o, write_body.defaults );

  o.group.tempPath = o.tempPath;
  o.group.dirPath = o.dirPath;
  o.group.namePrefix = o.namePrefix;
  o.group.namePostfix = o.namePostfix;
  o.group.rewriting = o.rewriting;
  o.group.logger = o.logger;
  delete o.tempPath;
  delete o.dirPath;
  delete o.namePrefix;
  delete o.namePostfix;
  delete o.rewriting;
  delete o.logger;

  o.group.entry.programPath = o.programPath;
  delete o.programPath;

  _.program.groupWrite.body.call( _.program, o.group );

  o.programPath = o.group.entry.programPath;
  o.start = o.group.entry.start;

  return o;
}

write_body.defaults =
{
  group : null,

  tempPath : null,
  dirPath : '.',
  namePrefix : '',
  namePostfix : '',
  rewriting : 0,
  logger : 0,
  programPath : null,
  entry : null,
  files : null,
}

let write = _.routine.unite( preform_head, write_body );

//

function make_body( o )
{

  _.map.assertHasAll( o, make_body.defaults );
  _.map.assertHasOnly( o, make_body.defaults );

  this.preform.body.call( this, o );
  this.write.body.call( this, o );

  return o;
}

make_body.defaults =
{
  ... preform_body.defaults,
  ... write_body.defaults,
}

let make = _.routine.unite( preform_head, make_body );

//

function _tempOpen()
{
  return _.fileProvider.tempOpen( ... arguments );
}

// --
// program extension
// --

let ProgramExtension =
{

  groupPreformLocals,
  filePreform,
  groupPreform,
  preform,
  fileWrite,
  groupWrite,
  write,
  make,

  _tempOpen,

}

Object.assign( _.program, ProgramExtension );

})();
