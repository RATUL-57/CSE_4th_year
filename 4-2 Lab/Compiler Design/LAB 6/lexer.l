%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
%}

%option noyywrap

%%

[ \t\n\r]+              { /* Ignore whitespace */ }

[a-zA-Z_][a-zA-Z0-9_]*  { 
                            yylval.str = strdup(yytext); 
                            return ID; 
                        }

[0-9]+                  { 
                            yylval.str = strdup(yytext); 
                            return NUMBER; 
                        }

"+"                     { return '+'; }
"-"                     { return '-'; }
"*"                     { return '*'; }
"/"                     { return '/'; }
"%"                     { return '%'; }
"="                     { return '='; }
";"                     { return ';'; }
"("                     { return '('; }
")"                     { return ')'; }

.                       { return yytext[0]; /* Send invalid token to Bison to trigger syntax error */ }

%%