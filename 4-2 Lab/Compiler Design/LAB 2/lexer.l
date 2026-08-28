%{
#include <stdio.h>
#include <string.h>

static FILE *out = NULL;

static int total_tokens = 0;
static int error_count = 0;
static int error_overflow = 0;

typedef struct {
    int line;
    char message[128];
    char lexeme[128];
} ErrorEntry;

#define MAX_ERRORS 256
static ErrorEntry errors[MAX_ERRORS];

static int keyword_count = 0;
static int identifier_count = 0;

static int int_const_count = 0;
static int float_const_count = 0;
static int char_const_count = 0;
static int string_const_count = 0;

static int arith_op_count = 0;
static int rel_op_count = 0;
static int logical_op_count = 0;
static int bitwise_op_count = 0;
static int assign_op_count = 0;
static int incdec_op_count = 0;

static int delimiter_count = 0;

static void emit_token(const char *type, const char *lexeme) {
    if (out) {
        fprintf(out, "<%s , %s>\n", type, lexeme);
    }
    fprintf(stdout, "<%s , %s>\n", type, lexeme);
    total_tokens++;
}

static void emit_error(const char *message, const char *lexeme) {
    if (out) {
        fprintf(out, "[ERROR] Line %d: %s -> %s\n", yylineno, message, lexeme);
    }
    fprintf(stdout, "[ERROR] Line %d: %s -> %s\n", yylineno, message, lexeme);
    error_count++;
    if (error_count <= MAX_ERRORS) {
        errors[error_count - 1].line = yylineno;
        snprintf(errors[error_count - 1].message, sizeof(errors[error_count - 1].message), "%s", message);
        snprintf(errors[error_count - 1].lexeme, sizeof(errors[error_count - 1].lexeme), "%s", lexeme);
    } else {
        error_overflow = 1;
    }
}
%}

%option noyywrap
%option yylineno

KEYWORD     int|float|if|else|print|for|while
ID          [A-Za-z_][A-Za-z0-9_]*
INTCONST    [0-9]+
FLOATCONST  [0-9]+\.[0-9]+
CHARCONST   \'([^\\'\n]|\\.)\'
INVALID_CHARCONST \'([^\\'\n]|\\.){2,}\'
STRINGCONST \"([^\\\"\n]|\\.)*\"
UNTERM_STRING \"([^\\\"\n]|\\.)*\n
UNTERM_CHAR \'([^\\'\n]|\\.)*\n

%%

"//".*                         { }
"/"\*([^*]|\*+[^*/])*\*+"/"   { }

[ \t\r\n]+                     { /* skip whitespace */ }

"++"|"--"                      { emit_token("INCDEC_OP", yytext); incdec_op_count++; }

"<<="|">>="|"+="|"-="|"*="|"/="|"%="|"&="|"|="|"^="|"="  { emit_token("ASSIGN_OP", yytext); assign_op_count++; }

"=="|"!="|"<="|">="|"<"|">"  { emit_token("REL_OP", yytext); rel_op_count++; }

"&&"|"||"|"!"                  { emit_token("LOGICAL_OP", yytext); logical_op_count++; }

"<<"|">>"|"&"|"|"|"^"|"~"    { emit_token("BITWISE_OP", yytext); bitwise_op_count++; }

"+"|"-"|"*"|"/"|"%"           { emit_token("ARITH_OP", yytext); arith_op_count++; }

";"|","|"("|")"|"{"|"}"     { emit_token("DELIMITER", yytext); delimiter_count++; }

{KEYWORD}                       { emit_token("KEYWORD", yytext); keyword_count++; }
{FLOATCONST}                    { emit_token("FLOAT_CONST", yytext); float_const_count++; }
{INTCONST}                      { emit_token("INT_CONST", yytext); int_const_count++; }
{INVALID_CHARCONST}             { emit_error("Invalid character constant", yytext); }
{UNTERM_CHAR}                    { emit_error("Unterminated character constant", yytext); }
{UNTERM_STRING}                  { emit_error("Unterminated string constant", yytext); }
{CHARCONST}                      { emit_token("CHAR_CONST", yytext); char_const_count++; }
{STRINGCONST}                    { emit_token("STRING_CONST", yytext); string_const_count++; }
{ID}                            { emit_token("IDENTIFIER", yytext); identifier_count++; }

.                               { emit_error("Unrecognized token", yytext); }

%%

int main(void) {
    FILE *in = fopen("input.txt", "r");
    if (!in) {
        fprintf(stderr, "Failed to open input.txt\n");
        return 1;
    }

    out = fopen("output.txt", "w");
    if (!out) {
        fprintf(stderr, "Failed to open output.txt\n");
        fclose(in);
        return 1;
    }

    yyin = in;

    fprintf(out, "Token Stream:\n");
    fprintf(out, "---------------------\n");
    yylex();

    int constants_count = int_const_count + float_const_count + char_const_count + string_const_count;
    int operators_count = arith_op_count + rel_op_count + logical_op_count + bitwise_op_count + assign_op_count + incdec_op_count;

    fprintf(out, "\n\n\n\nSummary Section:\n");
    fprintf(out, "------------------------\n");
    fprintf(out, "Total Tokens: %d\n", total_tokens);
    fprintf(out, "Keywords: %d\n", keyword_count);
    fprintf(out, "Identifiers: %d\n", identifier_count);
    fprintf(out, "Constants: %d\n", constants_count);
    fprintf(out, "\t\tInteger Constants: %d\n", int_const_count);
    fprintf(out, "\t\tFloat Constants: %d\n", float_const_count);
    fprintf(out, "\t\tCharacter Constants: %d\n", char_const_count);
    fprintf(out, "\t\tString Constants: %d\n", string_const_count);
    fprintf(out, "Operators: %d\n", operators_count);
    fprintf(out, "\t\tArithmetic Operators: %d\n", arith_op_count);
    fprintf(out, "\t\tRelational Operators: %d\n", rel_op_count);
    fprintf(out, "\t\tLogical Operators: %d\n", logical_op_count);
    fprintf(out, "\t\tBitwise Operators: %d\n", bitwise_op_count);
    fprintf(out, "\t\tAssignment Operators: %d\n", assign_op_count);
    fprintf(out, "\t\tIncrement/Decrement Operators: %d\n", incdec_op_count);
    fprintf(out, "Delimiters: %d\n", delimiter_count);
    fprintf(out, "\n\n\nErrors: %d\n", error_count);
    if (error_count > 0) {
        int i = 0;
        fprintf(out, "\nError Details:\n");
        fprintf(out, "------------------------\n");
        for (i = 0; i < error_count && i < MAX_ERRORS; i++) {
            fprintf(out, "Line %d: %s -> %s\n", errors[i].line, errors[i].message, errors[i].lexeme);
        }
        if (error_overflow) {
            fprintf(out, "(Additional errors omitted; increase MAX_ERRORS to list all.)\n");
        }
    }

    fclose(out);
    fclose(in);
    return 0;
}
