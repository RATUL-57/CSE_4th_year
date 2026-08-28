%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Function prototypes */
int yylex(void);
void yyerror(const char *s);
char* newTemp(void);
void emit(const char *instr);

typedef void* YY_BUFFER_STATE;
extern YY_BUFFER_STATE yy_scan_string(const char *str);
extern void yy_delete_buffer(YY_BUFFER_STATE buffer);

/* Global state tracking */
int temp_count = 1;
int has_error = 0;
int line_num = 0;

/* Instruction buffer to prevent printing partial assembly on syntax errors */
#define MAX_INSTR 100
#define INSTR_LEN 100
char code_buffer[MAX_INSTR][INSTR_LEN];
int code_count = 0;

/* Helper function to store generated assembly instructions */
void emit(const char *instr) {
    if (code_count < MAX_INSTR) {
        strncpy(code_buffer[code_count++], instr, INSTR_LEN - 1);
    }
}
%}

%union {
    char* str;
}

%token <str> ID NUMBER
%type <str> Expr Term Factor

%%

Program   : StmtList
          ;

StmtList  : StmtList Stmt
          | Stmt
          ;

Stmt      : ID '=' Expr ';' {
                char buf[INSTR_LEN];
                snprintf(buf, sizeof(buf), "MOV %s, %s", $1, $3);
                emit(buf);
                free($1);
                free($3);
          }
          ;

Expr      : Expr '+' Term {
                $$ = newTemp();
                char buf[INSTR_LEN];
                snprintf(buf, sizeof(buf), "ADD %s, %s, %s", $$, $1, $3);
                emit(buf);
                free($1); free($3);
          }
          | Expr '-' Term {
                $$ = newTemp();
                char buf[INSTR_LEN];
                snprintf(buf, sizeof(buf), "SUB %s, %s, %s", $$, $1, $3);
                emit(buf);
                free($1); free($3);
          }
          | Term {
                $$ = $1;
          }
          ;

Term      : Term '*' Factor {
                $$ = newTemp();
                char buf[INSTR_LEN];
                snprintf(buf, sizeof(buf), "MUL %s, %s, %s", $$, $1, $3);
                emit(buf);
                free($1); free($3);
          }
          | Term '/' Factor {
                $$ = newTemp();
                char buf[INSTR_LEN];
                snprintf(buf, sizeof(buf), "DIV %s, %s, %s", $$, $1, $3);
                emit(buf);
                free($1); free($3);
          }
          | Term '%' Factor {
                $$ = newTemp();
                char buf[INSTR_LEN];
                snprintf(buf, sizeof(buf), "MOD %s, %s, %s", $$, $1, $3);
                emit(buf);
                free($1); free($3);
          }
          | Factor {
                $$ = $1;
          }
          ;

Factor    : '(' Expr ')' {
                $$ = $2;
          }
          | ID {
                $$ = $1;
          }
          | NUMBER {
                $$ = $1;
          }
          ;

%%

char* newTemp() {
    char* temp = (char*)malloc(10 * sizeof(char));
    sprintf(temp, "T%d", temp_count++);
    return temp;
}

void yyerror(const char *s) {
    has_error = 1;
}

int main(void) {
    char line[1000];
    void *buffer;

    if (freopen("input.txt", "r", stdin) == NULL) {
        perror("Unable to open input.txt");
        return 1;
    }

    if (freopen("Output.txt", "w", stdout) == NULL) {
        perror("Unable to open Output.txt");
        return 1;
    }

    while (fgets(line, sizeof(line), stdin) != NULL) {
        line_num++;
        char parsed_line[1000];
        char *trimmed = line;

        while (*trimmed == ' ' || *trimmed == '\t') {
            trimmed++;
        }

        if (*trimmed == '\0' || *trimmed == '\n' || *trimmed == '\r') {
            continue;
        }

        trimmed[strcspn(trimmed, "\r\n")] = '\0';
        strcpy(parsed_line, trimmed);

        /* Auto-append semicolon if missing */
        if (parsed_line[strlen(parsed_line) - 1] != ';') {
            strcat(parsed_line, ";");
        }

        temp_count = 1;
        code_count = 0;
        has_error = 0;

        buffer = yy_scan_string(parsed_line);
        if (buffer == NULL) {
            printf("[ERROR Line %d] Failed to scan line: %s\n\n\n", line_num, trimmed);
            continue;
        }

        int parse_result = yyparse();
        yy_delete_buffer(buffer);

        if (parse_result == 0 && !has_error) {
            for (int i = 0; i < code_count; i++) {
                printf("%s\n", code_buffer[i]);
            }
        } else {
            printf("[SYNTAX ERROR Line %d] Invalid expression: \"%s\"", line_num, trimmed);
        }

        printf("\n\n");
    }

    return 0;
}