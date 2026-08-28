%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#define MAX_VAR 1000

void yyerror(char *s);
int yylex();

extern FILE *yyin;

/* Output file for results */
FILE *output = NULL;

typedef struct
{
    char name[100];
    double value;
} Symbol;

Symbol table[MAX_VAR];
int symbolCount = 0;

/* ---------- Symbol Table ---------- */

void saveSymbols()
{
    FILE *fp = fopen("symbols.txt","w");

    if(!fp)
        return;

    for(int i=0;i<symbolCount;i++)
    {
        fprintf(fp,"%s %lf\n",
                table[i].name,
                table[i].value);
    }

    fclose(fp);
}

void loadSymbols()
{
    FILE *fp = fopen("symbols.txt","r");

    if(!fp)
        return;

    while(fscanf(fp,"%s %lf",
                 table[symbolCount].name,
                 &table[symbolCount].value)==2)
    {
        symbolCount++;
    }

    fclose(fp);
}

double getSymbol(char *name)
{
    for(int i=0;i<symbolCount;i++)
    {
        if(strcmp(table[i].name,name)==0)
            return table[i].value;
    }

    fprintf(stderr, "Undefined variable: %s\n", name);
    return 0;
}

void setSymbol(char *name,double value)
{
    for(int i=0;i<symbolCount;i++)
    {
        if(strcmp(table[i].name,name)==0)
        {
            table[i].value=value;
            saveSymbols();
            return;
        }
    }

    strcpy(table[symbolCount].name,name);
    table[symbolCount].value=value;
    symbolCount++;

    saveSymbols();
}

%}

%union
{
    int ival;
    double dval;
    char sval[100];
}

%token <ival> INTEGER
%token <dval> DOUBLE
%token <sval> ID

%token SIN COS TAN SQRT LOG

%type <dval> statement expr term power factor

%left '+' '-'
%left '*' '/'
%right '^'
%right UMINUS

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

      ID '=' expr
      {
          setSymbol($1,$3);
          fprintf(output, "%s = %lf\n", $1, $3);
          $$ = $3;
      }

    | expr
      {
          fprintf(output, "Result = %lf\n", $1);
          $$ = $1;
      }
;

expr:

      expr '+' term
      { $$ = $1 + $3; }

    | expr '-' term
      { $$ = $1 - $3; }

    | term
      { $$ = $1; }
;

term:

      term '*' power
      { $$ = $1 * $3; }

    | term '/' power
      {
          if($3 == 0)
          {
              fprintf(stderr, "Division by zero\n");
              $$ = 0;
          }
          else
              $$ = $1 / $3;
      }

    | power
      { $$ = $1; }
;

power:

      factor '^' power
      { $$ = pow($1, $3); }

    | factor
      { $$ = $1; }
;

factor:

      SIN '(' expr ')'
      { $$ = sin($3); }

    | COS '(' expr ')'
      { $$ = cos($3); }

    | TAN '(' expr ')'
      { $$ = tan($3); }

    | SQRT '(' expr ')'
      { $$ = sqrt($3); }

    | LOG '(' expr ')'
      { $$ = log($3); }

    | '-' factor %prec UMINUS
      { $$ = -$2; }

    | '(' expr ')'
      { $$ = $2; }

    | INTEGER
      { $$ = $1; }

    | DOUBLE
      { $$ = $1; }

    | ID
      { $$ = getSymbol($1); }
;

%%

void yyerror(char *s)
{
    fprintf(stderr, "Syntax Error\n");
}

int main()
{
    loadSymbols();

    yyin = fopen("input.txt", "r");
    if(!yyin)
    {
        fprintf(stderr, "Cannot open input.txt\n");
        return 1;
    }

    output = fopen("output.txt", "w");
    if(!output)
    {
        fprintf(stderr, "Cannot open output.txt\n");
        fclose(yyin);
        return 1;
    }

    yyparse();

    fclose(yyin);
    fclose(output);

    return 0;
}