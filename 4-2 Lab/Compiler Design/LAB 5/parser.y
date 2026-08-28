%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
extern int yylex();

FILE *outFile;

void yyerror(const char *s);
%}

%define parse.error verbose

%union {
    char *str;
}

%token HTML_OPEN HTML_CLOSE
%token HEAD_OPEN HEAD_CLOSE
%token TITLE_OPEN TITLE_CLOSE
%token BODY_OPEN BODY_CLOSE
%token H1_OPEN H1_CLOSE
%token H2_OPEN H2_CLOSE
%token P_OPEN P_CLOSE
%token DIV_OPEN DIV_CLOSE
%token B_OPEN B_CLOSE
%token I_OPEN I_CLOSE

%token <str> TEXT

%%

document
    : HTML_OPEN head body HTML_CLOSE
    ;

head
    : HEAD_OPEN title HEAD_CLOSE
    ;

title
    : TITLE_OPEN text TITLE_CLOSE
    ;

body
    : BODY_OPEN body_content BODY_CLOSE
    ;

body_content
    : /* empty */
    | body_content element
    ;

element
    : heading1
    | heading2
    | paragraph
    | division
    | bold
    | italic
    | text
    ;

/* H1 */

heading1
    : H1_OPEN body_content H1_CLOSE
    | H1_OPEN body_content H2_CLOSE
      {
          fprintf(outFile,
                  "Error: <h1> is closed incorrectly.\n");
          fprintf(outFile,
                  "Expected: </h1>\n");
          fprintf(outFile,
                  "Found: </h2>\n");
          YYERROR;
      }
    ;

/* H2 */

heading2
    : H2_OPEN body_content H2_CLOSE
    | H2_OPEN body_content H1_CLOSE
      {
          fprintf(outFile,
                  "Error: <h2> is closed incorrectly.\n");
          fprintf(outFile,
                  "Expected: </h2>\n");
          fprintf(outFile,
                  "Found: </h1>\n");
          YYERROR;
      }
    ;

/* Paragraph */

paragraph
    : P_OPEN body_content P_CLOSE
    | P_OPEN body_content BODY_CLOSE
      {
          fprintf(outFile,
                  "Error: <p> is not closed correctly.\n");
          fprintf(outFile,
                  "Expected: </p>\n");
          fprintf(outFile,
                  "Found: </body>\n");
          YYERROR;
      }
    ;

/* Division */

division
    : DIV_OPEN body_content DIV_CLOSE
    | DIV_OPEN body_content BODY_CLOSE
      {
          fprintf(outFile,
                  "Error: <div> is not closed correctly.\n");
          fprintf(outFile,
                  "Expected: </div>\n");
          fprintf(outFile,
                  "Found: </body>\n");
          YYERROR;
      }
    ;

/* Bold */

bold
    : B_OPEN body_content B_CLOSE
    | B_OPEN body_content P_CLOSE
      {
          fprintf(outFile,
                  "Error: <b> is not closed correctly.\n");
          fprintf(outFile,
                  "Expected: </b>\n");
          fprintf(outFile,
                  "Found: </p>\n");
          YYERROR;
      }
    ;

/* Italic */

italic
    : I_OPEN body_content I_CLOSE
    | I_OPEN body_content P_CLOSE
      {
          fprintf(outFile,
                  "Error: <i> is not closed correctly.\n");
          fprintf(outFile,
                  "Expected: </i>\n");
          fprintf(outFile,
                  "Found: </p>\n");
          YYERROR;
      }
    ;

/* Text */

text
    : TEXT
    ;

%%

void yyerror(const char *s)
{
    fprintf(outFile, "Syntax Error: %s\n", s);

    /*
     * General error messages.
     *
     * These are used when Bison encounters something
     * that is not covered by our specific error rules.
     */

    if (strstr(s, "unexpected HTML_CLOSE"))
    {
        fprintf(outFile,
                "Expected: a valid HTML structure before </html>.\n");
    }
    else if (strstr(s, "unexpected HEAD_CLOSE"))
    {
        fprintf(outFile,
                "Expected: </title> before </head>.\n");
    }
    else if (strstr(s, "unexpected TITLE_CLOSE"))
    {
        fprintf(outFile,
                "Expected: valid title content before </title>.\n");
    }
    else if (strstr(s, "unexpected BODY_CLOSE"))
    {
        fprintf(outFile,
                "Expected: a valid body element before </body>.\n");
    }
    else if (strstr(s, "unexpected H1_CLOSE"))
    {
        fprintf(outFile,
                "Expected: </h1>.\n");
    }
    else if (strstr(s, "unexpected H2_CLOSE"))
    {
        fprintf(outFile,
                "Expected: </h2>.\n");
    }
    else if (strstr(s, "unexpected P_CLOSE"))
    {
        fprintf(outFile,
                "Expected: </p>.\n");
    }
    else if (strstr(s, "unexpected DIV_CLOSE"))
    {
        fprintf(outFile,
                "Expected: </div>.\n");
    }
    else if (strstr(s, "unexpected B_CLOSE"))
    {
        fprintf(outFile,
                "Expected: </b>.\n");
    }
    else if (strstr(s, "unexpected I_CLOSE"))
    {
        fprintf(outFile,
                "Expected: </i>.\n");
    }
}

int main()
{
    int result;

    yyin = fopen("input3.html", "r");

    if (yyin == NULL)
    {
        printf("Cannot open input3.html\n");
        return 1;
    }

    outFile = fopen("output.txt", "w");

    if (outFile == NULL)
    {
        printf("Cannot create output.txt\n");
        fclose(yyin);
        return 1;
    }

    result = yyparse();

    if (result == 0)
    {
        fprintf(outFile,
                "HTML document is structurally valid.\n");
    }
    else
    {
        fprintf(outFile,
                "HTML document contains syntax errors.\n");
    }

    fclose(yyin);
    fclose(outFile);

    return 0;
}
