grammar cymling ;

file_: form * EOF;

form: literal
    | record
    | vector
    ;

forms: form* ;

pair: symbol '=' form;

record: '(' pair* ')' ;

vector: '[' forms ']' ;

fun_block: '{' forms '}' ;

literal
    : string_
    | number
    | character
    | null_
    | BOOLEAN
    | keyword
    | symbol
    | param_name
    ;

string_: STRING;
hex_: HEX;
bin_: BIN;
bign: BIGN;
number
    : FLOAT
    | hex_
    | bin_
    | bign
    | LONG
    ;

character
    : named_char
    | u_hex_quad
    | any_char
    ;
named_char: CHAR_NAMED ;
any_char: CHAR_ANY ;
u_hex_quad: CHAR_U ;

null_: NULL;

keyword: macro_keyword | simple_keyword;
simple_keyword: '%' symbol;
macro_keyword: '%' '%' symbol;

symbol: ns_symbol | simple_sym;
simple_sym: SYMBOL;
ns_symbol: NS_SYMBOL;

param_name: PARAM_NAME;

// Lexers
//--------------------------------------------------------------------

STRING : '"' ( ~'"' | '\\' '"' )* '"' ;

// FIXME: Doesn't deal with arbitrary read radixes, BigNums
FLOAT
    : '-'? [0-9]+ FLOAT_TAIL
    | '-'? 'Infinity'
    | '-'? 'NaN'
    ;

fragment
FLOAT_TAIL
    : FLOAT_DECIMAL FLOAT_EXP
    | FLOAT_DECIMAL
    | FLOAT_EXP
    ;

fragment
FLOAT_DECIMAL
    : '.' [0-9]+
    ;

fragment
FLOAT_EXP
    : [eE] '-'? [0-9]+
    ;
fragment
HEXD: [0-9a-fA-F] ;
HEX: '0' [xX] HEXD+ ;
BIN: '0' [bB] [10]+ ;
LONG: '-'? [0-9]+[lL]?;
BIGN: '-'? [0-9]+[nN];

CHAR_U
    : '\\' 'u'[0-9D-Fd-f] HEXD HEXD HEXD ;
CHAR_NAMED
    : '\\' ( '\n'
           | '\t' ) ;
CHAR_ANY
    : '\\' . ;

NULL : 'null';

BOOLEAN : 'true' | 'false' ;

DOT : '.' ;

SYMBOL
    : '/'
    | NAME
    ;

NS_SYMBOL
    : NAME '/' SYMBOL
    ;

PARAM_NAME: 'it';

// Fragments
//--------------------------------------------------------------------

fragment
NAME: SYMBOL_HEAD SYMBOL_REST* (':' SYMBOL_REST+)* ;

fragment
SYMBOL_HEAD
    : ~('0' .. '9'
        | '^' | '`' | '\'' | '"' | '#' | '~' | '@' | ':' | '<' | '>' | '(' | ')' | '[' | ']' | '{' | '}' // FIXME: could be one group
        | [ \n\r\t,] // FIXME: WS
        )
    ;

fragment
SYMBOL_REST
    : SYMBOL_HEAD
    | '0'..'9'
    | '.'
    ;

// Discard
//--------------------------------------------------------------------

fragment
WS : [ \n\r\t,] ;

fragment
LINE_COMMENT: '//' ~[\r\n]* ;

fragment
BLOCK_COMMENT: '/*' .*? '*/';

TRASH
    : ( WS | LINE_COMMENT ) -> channel(HIDDEN)
    ;