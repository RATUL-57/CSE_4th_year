%{

#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>

%}

%%

[0-9]+(\.[0-9]+)? {
    yylval.dval = atof(yytext);
    return NUMBER;
}

PI      { return PI; }
E       { return E; }

sin     { return SIN; }
cos     { return COS; }
tan     { return TAN; }
sqrt    { return SQRT; }
log     { return LOG; }

deg     { return DEG; }
rad     { return RAD; }

[A-Za-z_][A-Za-z0-9_]* {
    strcpy(yylval.sval, yytext);
    return ID;
}

"+"     { return '+'; }
"-"     { return '-'; }
"*"     { return '*'; }
"/"     { return '/'; }
"^"     { return '^'; }
"="     { return '='; }

"("     { return '('; }
")"     { return ')'; }

\r?\n   { return '\n'; }

[ \t]+  ;

.       { return yytext[0]; }

%%

int yywrap()
{
    return 1;
}