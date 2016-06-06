/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
    if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
        YY_FATAL_ERROR( "read() in flex scanner failed");

char str_buf[MAX_STR_CONST]; /* to assemble string constants */
char *str_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */
void print_strlen();
void print_str();
void print_input();
bool max_strlen_check();
bool max_strlen_check(int);
int max_strlen_err();
%}

%x STRING
%x COMMENT

/*
 * Define names for regular expressions here.
 */

LETTER      [a-zA-Z_]
DIGIT       [0-9]
NEWLINE     (\r\n|\n)+
WHITESPACE  [ \t]*
DASHCOMMENT --.*\n

CLASS       (?i:class)
ELSE        (?i:else)
FI          (?i:fi)
IF          (?i:if)
IN          (?i:in)
INHERITS    (?i:inherits)
LET         (?i:let)
LOOP        (?i:loop)
POOL        (?i:pool)
THEN        (?i:then)
WHILE       (?i:while)
CASE        (?i:case)
NEW         (?i:new)
ISVOID      (?i:isvoid)
OF          (?i:of)
NOT         (?i:not)

TYPEID      [A-Z]({DIGIT}|{LETTER})*
OBJECTID    [a-z]({DIGIT}|{LETTER})*
INT_CONST   {DIGIT}+

%%

"*)" {
    cool_yylval.error_msg = "Unmatched *)";
    return ERROR;
}
"(*" {
    BEGIN(COMMENT);
}
<COMMENT><<EOF>> {
    BEGIN(INITIAL);
    cool_yylval.error_msg = "EOF in comment";
    return ERROR;
}
<COMMENT>\n { curr_lineno++; }
<COMMENT>. { }
<COMMENT>"*)" {
    BEGIN(INITIAL);
}
{DASHCOMMENT} { curr_lineno++; }
\" {
    BEGIN(STRING);
    str_buf_ptr = str_buf;
}
<STRING>\" {
    BEGIN(INITIAL);
    if (max_strlen_check()) return max_strlen_err();
    str_buf_ptr = '\0';
    cool_yylval.symbol = stringtable.add_string(str_buf);
    return STR_CONST;
}
<STRING><<EOF>> {
    cool_yylval.error_msg = "EOF in string constant";
    return ERROR;
}
<STRING>\\\n { curr_lineno++; }
<STRING>\n {
    curr_lineno++;
    BEGIN(INITIAL);
    cool_yylval.error_msg = "Unterminated string constant";
    return ERROR;
}
<STRING>\0 {
    cool_yylval.error_msg = "String contains null character";
    return ERROR;
}
<STRING>\\[^ntbf] {
    if (max_strlen_check()) return max_strlen_check();
    *str_buf_ptr++ = yytext[1];
}
<STRING>\\[n] {
    if (max_strlen_check()) return max_strlen_check();
    *str_buf_ptr++ = '\n';
}
<STRING>\\[t] {
    if (max_strlen_check()) return max_strlen_check();
    *str_buf_ptr++ = '\t';
}
<STRING>\\[b] {
    if (max_strlen_check()) return max_strlen_check();
    *str_buf_ptr++ = '\b';
}
<STRING>\\[f] {
    if (max_strlen_check()) return max_strlen_check();
    *str_buf_ptr++ = '\f';
}
<STRING>. {
    if (max_strlen_check()) return max_strlen_err();
    *str_buf_ptr++ = *yytext;
}
{INT_CONST} { 
    cool_yylval.symbol = inttable.add_string(yytext);
    return INT_CONST; 
}
"false" {
    cool_yylval.boolean = false;
    return BOOL_CONST;
}
"true" {
    cool_yylval.boolean = true;
    return BOOL_CONST;
}
"=>"        { return DARROW; }
"=<"        { return LE; }
"<-"        { return ASSIGN; }
"<"         { return '<'; }
"@"         { return '@'; }
"~"         { return '~'; }
"="         { return '='; }
"."         { return '.'; }
"-"         { return '-'; }
","         { return ','; }
"+"         { return '+'; }
"*"         { return '*'; }
"/"         { return '/'; }
"}"         { return '}'; }
"{"         { return '{'; }
"("         { return '('; }
")"         { return ')'; }
":"         { return ':'; }
";"         { return ';'; }
{CLASS}     { return CLASS; }
{ELSE}      { return ELSE; }
{FI}        { return FI; }
{IF}        { return IF; }
{IN}        { return IN; }
{INHERITS}  { return INHERITS; }    
{LET}       { return LET; } 
{LOOP}      { return LOOP; }    
{POOL}      { return POOL; }
{THEN}      { return THEN; }
{WHILE}     { return WHILE; }
{CASE}      { return CASE; }
{NEW}       { return NEW; }
{OF}        { return OF; }
{NOT}       { return NOT; }
{OBJECTID} { 
    cool_yylval.symbol = idtable.add_string(yytext); 
    return OBJECTID; 
}
{TYPEID} { 
    cool_yylval.symbol = idtable.add_string(yytext); 
    return TYPEID; 
}
\n { curr_lineno++; }
{WHITESPACE} {}
. {
    cool_yylval.error_msg = strdup(yytext);
    return ERROR;
}

%%

void print_strlen () { 
    printf("String length:%d\n", str_buf_ptr - str_buf); 
}

void print_str () {
    printf("String:'%s'\n", str_buf);
}

void print_input () {
    printf("Scan:'%s'\n", yytext);
}

bool max_strlen_check () { 
    return (str_buf_ptr - str_buf) + 1 > MAX_STR_CONST; 
}

bool max_strlen_check (int size) {
    return (str_buf_ptr - str_buf) + size > MAX_STR_CONST;
}

int max_strlen_err() { 
    BEGIN(INITIAL);
    cool_yylval.error_msg = "String constant too long";
    return ERROR;
}
