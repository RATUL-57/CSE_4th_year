%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>

extern YYSTYPE yylval;
%}

%%

[0-9]+\.[0-9]+ {
    yylval.dval = atof(yytext);
    return DOUBLE;
}

[0-9]+ {
    yylval.ival = atoi(yytext);
    return INTEGER;
}

sin   { return SIN; }
cos   { return COS; }
tan   { return TAN; }
sqrt  { return SQRT; }
log   { return LOG; }

[A-Za-z_][A-Za-z0-9_]* {
    strncpy(yylval.sval, yytext, sizeof(yylval.sval) - 1);
    yylval.sval[sizeof(yylval.sval) - 1] = '\0';
    return ID;
}

"+"    { return '+'; }
"-"    { return '-'; }
"*"    { return '*'; }
"/"    { return '/'; }
"^"    { return '^'; }
"="    { return '='; }
"("    { return '('; }
")"    { return ')'; }

[ \t\r]+  { /* ignore whitespace */ }
\n        { return '\n'; }

.         { return yytext[0]; }

%%

int yywrap(void) {
    return 1;
}