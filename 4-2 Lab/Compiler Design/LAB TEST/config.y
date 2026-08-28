%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void yyerror(char *s);
int yylex();

extern FILE *yyin;
FILE *output;
%}

%union{
    int ival;
    double dval;
    char sval[100];
    bool bval;
}

%token <ival> INTEGER
%token <dval> DOUBLE
%token <sval> STRING
%token <bval> BOOL

%type <sval> key

%%

program:
      lines
;

lines:
      lines line
    |
;

line:
      statement '\n'
    | '\n'
;

statement:
      key '=' expr
      {
          fprintf(output, "Assignment parsed\n");
      }
    | '[' expr ']'
      {
          fprintf(output, "Section parsed\n");
      }
;

key:
      STRING
      {
          strcpy($$, $1);
      }
;

expr:
      INTEGER
      {
          fprintf(output, "INTEGER: %d\n", $1);
      }
    | DOUBLE
      {
          fprintf(output, "DOUBLE: %.2f\n", $1);
      }
    | STRING
      {
          fprintf(output, "STRING: %s\n", $1);
      }
    | BOOL
      {
          fprintf(output, "BOOL: %s\n", $1 ? "true" : "false");
      }
;

%%

void yyerror(char *s)
{
    fprintf(stderr, "Parse error: %s\n", s);
}

int main()
{
    yyin = fopen("input.txt", "r");
    if (!yyin){
        printf("Cannot open input.txt\n");
        return 1;
    }

    output = fopen("output.txt", "w");
    if (!output){
        printf("Cannot open output.txt\n");
        fclose(yyin);
        return 1;
    }

    yyparse();

    fclose(yyin);
    fclose(output);
    return 0;
}