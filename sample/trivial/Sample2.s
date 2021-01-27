
let _ = require( 'wintrospectorbasic' );

function sum(){ return a + b }

var result = _.program.preform
({
  name : 'sum',
  routine : sum,
  // locals : { a : 1, b : 2 }
});

console.log( result.sourceCode );
/*
logs
`
function sum(){ return a + b }

var a = 1;
var b = 2;

sum();
`
*/
