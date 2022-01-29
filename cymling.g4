grammar cymling ;

file_: form * EOF;

form: literal
    | fun_block
//    | fun_appl
    | record
    | vector
    ;

forms: form* ;

pair: lcf_sym '=' form;

record: '(' pair* ')' ;

vector: '[' forms ']' ;

fun_block: '{' (lcf_sym* '->')? forms '}' ;

//fun_appl: lcf_sym '(' (form | pair)* ')' ;

// fluent_appl: fun_appl ( '.' fun_appl )+ ;

literal
    : string_
    | number
    | character
    | null_
    | BOOLEAN
    | keyword
    | lcf_sym
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

symbol: lcf_sym | ucf_sym;
lcf_sym: LCF_SYMBOL;
ucf_sym: UCF_SYMBOL;

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

LCF_SYMBOL : LCF_SYMBOL_HEAD SYMBOL_REST* ;

UCF_SYMBOL : UCF_SYMBOL_HEAD SYMBOL_REST* ;

PARAM_NAME: 'it';

// Fragments
//--------------------------------------------------------------------

fragment
LCF_SYMBOL_HEAD : [\p{lowerCase}] ;

fragment
UCF_SYMBOL_HEAD : [\p{upperCase}] ;

fragment
SYMBOL_REST
    : ~('^' | '`' | '\'' | '"' | '#' | '~' | '@' | ':' | '<' | '=' | '>' | '(' | ')' | '[' | ']' | '{' | '}'
              | [ \n\r\t,]
              )
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