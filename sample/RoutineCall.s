
let _ = require( 'wintrospectorbasic' );

/* call routine with context and arguments */

var context =
{
  b : 10
}
function routine( a )
{
  return a + this.b;
}
var args = [ 1 ];
var result = _.routineCall( context, routine, args );
console.log( result ); //11

/* call routine with passing only known options */

function routine2 ( o )
{
  return o;
}
routine2.defaults =
{
  a : null
}
var options =
{
  a : 1,
  b : 2,
  c : 3
};
var result = _.routineTolerantCall( this, routine2, options );
console.log( result );// { a : 1 }
