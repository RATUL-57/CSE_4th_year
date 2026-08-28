%{
#include "config.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%%

true|false {
    yylval.bval = (strcmp(yytext, "true") == 0);
    return BOOL;
}

[0-9]+\.[0-9]+ {
    yylval.dval = atof(yytext);
    return DOUBLE;
}

[0-9]+ {
    yylval.ival = atoi(yytext);
    return INTEGER;
}

[A-Za-z_][A-Za-z0-9_.]* {
    strncpy(yylval.sval, yytext, sizeof(yylval.sval)-1);
    yylval.sval[sizeof(yylval.sval)-1] = '\0';
    return STRING;
}

"["     { return '['; }
"]"     { return ']'; }
"="     { return '='; }

[ \t\r]+    ;
\n          { return '\n'; }

.           { return yytext[0]; }

%%

int yywrap(void)
{
    return 1;
}