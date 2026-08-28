%{

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

void yyerror(char *s);
int yylex();

extern FILE *yyin;
extern FILE *yyout;

#define MAX_VAR 100

typedef struct
{
    char name[50];
    double value;
} Variable;

Variable vars[MAX_VAR];
int var_count = 0;

double getVar(char *name)
{
    for(int i=0;i<var_count;i++)
        if(strcmp(vars[i].name,name)==0)
            return vars[i].value;

    fprintf(yyout,"Undefined variable: %s\n",name);
    return 0;
}

void setVar(char *name,double val)
{
    for(int i=0;i<var_count;i++)
    {
        if(strcmp(vars[i].name,name)==0)
        {
            vars[i].value=val;
            return;
        }
    }

    strcpy(vars[var_count].name,name);
    vars[var_count].value=val;
    var_count++;
}

int error_flag=0;
int semantic_error=0;
int fatal_error=0;

%}

%union
{
    double dval;
    char sval[50];
}

%token <dval> NUMBER
%token <sval> ID

%token SIN COS TAN SQRT LOG
%token PI E
%token DEG RAD

%type <dval> expr term power factor

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

      ID '=' expr '\n'
      {
          setVar($1,$3);

          if(!fatal_error)
              fprintf(yyout,"%s = %lf\n",$1,$3);

          error_flag=0;
          semantic_error=0;
          fatal_error=0;
      }

    | expr '\n'
      {
          if(!error_flag && !semantic_error && !fatal_error)
              fprintf(yyout,"Result = %lf\n",$1);

          error_flag=0;
          semantic_error=0;
          fatal_error=0;
      }

    | error '\n'
      {
          yyerrok;

          error_flag=0;
          semantic_error=0;
          fatal_error=0;
      }

    | '\n'
;

expr:

      expr '+' term
      { $$=$1+$3; }

    | expr '-' term
      { $$=$1-$3; }

    | term
      { $$=$1; }
;

term:

      term '*' power
      { $$=$1*$3; }

    | term '/' power
      {
          if($3==0)
          {
              fprintf(yyout,"Division by zero\n");
              fatal_error=1;
              $$=0;
          }
          else
              $$=$1/$3;
      }

    | power
      { $$=$1; }
;

power:

      factor '^' power
      { $$=pow($1,$3); }

    | factor
      { $$=$1; }
;

factor:

      '-' factor %prec UMINUS
      { $$=-$2; }

    | SIN '(' expr ')'
      { $$=sin($3); }

    | COS '(' expr ')'
      { $$=cos($3); }

    | TAN '(' expr ')'
      {
          double c=cos($3);

          if(fabs(c)<1e-10)
          {
              fprintf(yyout,"Undefined tan()\n");
              fatal_error=1;
              $$=0;
          }
          else
              $$=tan($3);
      }

    | SQRT '(' expr ')'
      {
          if($3<0)
          {
              fprintf(yyout,"Invalid sqrt() domain\n");
              fatal_error=1;
              $$=0;
          }
          else
              $$=sqrt($3);
      }

    | LOG '(' expr ')'
      {
          if($3<=0)
          {
              fprintf(yyout,"Invalid log() domain\n");
              fatal_error=1;
              $$=0;
          }
          else
              $$=log($3);
      }

    | DEG '(' expr ')'
      {
          $$ = $3 * 180.0 / M_PI;
      }

    | RAD '(' expr ')'
      {
          $$ = $3 * M_PI / 180.0;
      }

    | '(' expr ')'
      { $$=$2; }

    | PI
      { $$=M_PI; }

    | E
      { $$=M_E; }

    | ID
      {
          $$=getVar($1);
      }

    | NUMBER
      { $$=$1; }
;

%%

void yyerror(char *s)
{
    if(!fatal_error)
        fprintf(yyout,"Syntax Error\n");

    error_flag=1;
}

int main()
{
    yyin=fopen("input.txt","r");

    if(!yyin)
    {
        printf("Cannot open input.txt\n");
        return 1;
    }

    yyout=fopen("output.txt","w");

    if(!yyout)
    {
        printf("Cannot create output.txt\n");
        return 1;
    }

    yyparse();

    fclose(yyin);
    fclose(yyout);

    printf("Calculation completed. Check output.txt\n");

    return 0;
}