%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

ASTNode* rootNode = NULL;

extern FILE* yyin;
extern int yylex();
extern int yyparse();
extern char *yytext;
extern int yylineno;
void yyerror(const char *s);
%}

%code requires {
	#include "ast.h" 
}

%union{
    struct{
        int arg_count;
    }t;
    
    ASTNode* ast;
    char* sval;
}

%token BEGIN_PROGRAM END_PROGRAM END_BLOCK BEGIN_BLOCK
%token BEGIN_VARDECL END_VARDECL
%token PRINT SCAN IF ELSE FOR WHILE INC DEC DO TO
%token COLON
%token COMMA LP RP SEMICOLON ATRATE CHARACTER 
%token LB RB
%token COMMENT
%token DECIMAL_NUM BINARY_NUM OCTAL_NUM CHAR_CONSTANT NUMBER
%token <t> STRING_CONSTANT FORMAT SCAN_FORMAT
%token ASSIGN_OP PLUS_ASSIGN MINUS_ASSIGN MULT_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token ADD SUB MUL DIV MOD
%token <sval> ARR ID INT CHAR

%left ADD SUB
%left MUL DIV MOD
%right UMINUS
%type <t> expr print_args scan_args
%type <ast> decl 
%type <sval> type id_t arr_t

%token EQUAL NOT_EQUAL GREATER LESS GREATER_EQUAL LESS_EQUAL
%nonassoc IFX
%nonassoc ELSE
%%

program
    : BEGIN_PROGRAM COLON var_decl statements END_PROGRAM {printf("Valid Program\n"); return 0;}
    ;

var_decl
    : BEGIN_VARDECL COLON decl_list END_VARDECL {}
    ;

decl_list : decl decl_list {printAST($1);}
          |
          ;
decl : LP id_t COMMA type RP SEMICOLON {printf("%s hi %s\n", $2, $4); $$ = createDeclNode(NODE_DECL_ID, $2, $4);}
     | COMMENT {$$ = createCommentNode(NODE_COMMENT);}
     | LP arr_t COMMA type RP SEMICOLON {$$ = createDeclNode(NODE_DECL_ARR , $2, $4);}
     ;
id_t: ID {strcpy($$, $1);}
    ;
arr_t: ARR {strcpy($$, $1);}
     ;
type : INT {strcpy($$, $1);}
     | CHAR {strcpy($$, $1);}
     ;

statements : statement statements
           |
           ;

statement : block
          | assign
          | print
          | scan
          | if
          | while
          | for
          | COMMENT
          ;
block
    : BEGIN_BLOCK statements END_BLOCK SEMICOLON {printf("Block stmt\n");}
    ;

block_fun
    : BEGIN_BLOCK statements END_BLOCK {printf("Block stmt\n");}
    ;
assign : ID assign_op expr SEMICOLON {printf("Assignment\n");};

assign_op : ASSIGN_OP
    | PLUS_ASSIGN
    | MINUS_ASSIGN
    | MULT_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    ;

expr: expr MUL expr {}
| expr SUB expr {}
| expr ADD expr {}
| expr DIV expr {}
| expr MOD expr {}
| LP expr RP {}
| constant {}
| ID {}
| SUB expr %prec UMINUS {}
;

constant
: number
| STRING_CONSTANT
| CHAR_CONSTANT
;

number : DECIMAL_NUM | OCTAL_NUM | BINARY_NUM;
       ;

print : PRINT LP STRING_CONSTANT RP SEMICOLON {}
| PRINT LP FORMAT COMMA print_args RP SEMICOLON {
        if($3.arg_count > $5.arg_count){
            yyerror("Error at print Statement, too less arguments\n");
            exit(1);
        }
        else if($3.arg_count < $5.arg_count){
            yyerror("Error at print Statement, too many arguments\n");
        exit(1);
        }
        else{
            printf("Valid print\n");
        }
    }
| PRINT LP SCAN_FORMAT COMMA print_args RP SEMICOLON {
    if($3.arg_count > $5.arg_count){
        yyerror("Error at print Statement, too less arguments\n");
        exit(1);
    }
    else if($3.arg_count < $5.arg_count){
        yyerror("Error at print Statement, too many arguments\n");
        exit(1);
    }
    else{
        printf("Valid print\n");
    }
}
;
print_args : expr {$$.arg_count = 1;}
            | expr COMMA print_args {$$.arg_count = $3.arg_count+1;}
            ;

scan
    : SCAN LP SCAN_FORMAT COMMA scan_args RP SEMICOLON {
        if($3.arg_count > $5.arg_count){
            yyerror("Error at scan Statement, too less arguments\n");
            exit(1);
        }
        else if($3.arg_count < $5.arg_count){
            yyerror("Error at scan Statement, too many arguments\n");
            exit(1);
        }
        else{
            printf("Valid scan\n");
        }
    }
    | SCAN LP FORMAT COMMA scan_args RP SEMICOLON {
        yyerror("Error in format string of scan");
        exit(1);
    }
    ;

scan_args
    : ID {$$.arg_count = 1;}
    | ID COMMA scan_args {$$.arg_count = $3.arg_count+1;}
    ;


if : IF LP condition RP block %prec IFX
| IF LP condition RP block_fun ELSE block
;
while
    : WHILE LP condition RP block
    ;

for
    : FOR ID ASSIGN_OP expr TO expr inc_dec expr DO block
    ;

inc_dec
    : INC
    | DEC
    ;
condition : expr rel_op expr
    ;
rel_op
    : EQUAL
    | NOT_EQUAL
    | GREATER
    | LESS
    | GREATER_EQUAL
    | LESS_EQUAL
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d: %s near '%s'\n", yylineno, s, yytext);
}

int main(int argc, char *argv[]) {
	//if (argc != 2) {
	//	fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
	//	return 1;
	//}
	
	yyin = fopen("input1.txt", "r");
	if (!yyin) {
		perror("Error opening file");
		return 1;
	}
	
	yyparse();
	
	fclose(yyin);

	return 0;
}
