
let _ = require( 'wroutinebasic' );

/* call routine with context and arguments */

var context =
{
  b : 10
}
var routine = function( a )
{
  return a + this.b;
}
var args = [ 1 ];
var result = _.routineCall( context, routine, args );
console.log( result ); //11

/* call routine with passing only known options */

var routine = function( o )
{
  return o;
}
routine.defaults =
{
  a : null
}
var options =
{
  a : 1,
  b : 2,
  c : 3
};
var result = _.routineTolerantCall( this, routine, options );
console.log( result );// { a : 1 }





