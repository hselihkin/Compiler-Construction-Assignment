%{
#include <stdio.h>
#include <string.h>
#include "ast.tab.h" 
#include "ast.h"
%}

DIGIT       [0-9]
BINARY      [0-1]
OCTAL       [0-7]
LOWERCASE   [a-z]

%x COMMENT_STATE 

%%
[ \t\n] { }
"begin program" { return BEGIN_PROGRAM; }
"end program" { return END_PROGRAM; }
"begin VarDecl" { return BEGIN_VARDECL; }
"end VarDecl" { return END_VARDECL; }
"begin" {return BEGIN_BLOCK;}
"end" {return END_BLOCK;}
"int" { yylval.sval = "int"; return INT; }
"char" { yylval.sval = "char"; return CHAR; }
"print" {return PRINT;}
"scan" {return SCAN;}
"if" {return IF;}
"else" {return ELSE;}
"while" { return WHILE; }
"for" { return FOR; }
"to" { return TO; }
"do" { return DO; }
"inc" { return INC; }
"dec" { return DEC; }
":" {return COLON;}
"," {return COMMA;}
";" {return SEMICOLON;}
"(" {return LP;}
")" {return RP;}
"[" {return LB;}
"]" {return RB;}
":=" {return ASSIGN_OP;}
"+=" { return PLUS_ASSIGN; }
"-=" { return MINUS_ASSIGN; }
"*=" { return MULT_ASSIGN; }
"/=" { return DIV_ASSIGN; }
"%=" { return MOD_ASSIGN; }
"=" { return EQUAL; }
"<>" { return NOT_EQUAL; }
">"  { return GREATER; }
"<"  { return LESS; }
">=" { return GREATER_EQUAL; }
"<=" { return LESS_EQUAL; }
"+" {return ADD;}
"-" {return SUB;}
"*" {return MUL;}
"/" {return DIV;}
"%" {return MOD;}
"/*" {BEGIN COMMENT_STATE;}
<COMMENT_STATE>.|\n { }
<COMMENT_STATE>"*/" {BEGIN 0; return COMMENT;}
"//"(.)*\n {return COMMENT;}
"("{BINARY}+","[ \t]*"2)" {return BINARY_NUM;}
"("{OCTAL}+","[ \t]*"8)" {return OCTAL_NUM;}
"("{DIGIT}+","[ \t]*"10)" {return DECIMAL_NUM;}
{DIGIT}+/"]" {return NUMBER;}
\'.\' {return CHAR_CONSTANT;}
\"(.)*\" { 
  int atrates = 0;
  yytext[0] == '@' ? atrates++ : atrates;
  printf("%s\n", yytext);
  for(int i = 1; i < strlen(yytext)-1; i++){
      if(yytext[i] == '@' && yytext[i-1] != '\\'){
          atrates++;
      }
  }
  if(atrates == 0){
      printf("returning STRING_CONSTANT\n");
      yylval.t.arg_count = 0;
      return STRING_CONSTANT;
  }
  else{
      // DOES IT HANDLE ESCAPE SEQUENCES IN SCAN FORMATS?
      char* temp = (char*)malloc(sizeof(char)*strlen(yytext));
      int pointer = 0;
      for(int i = 0; i < strlen(yytext); i++){
          if(yytext[i] == '@' || yytext[i] == ','){
            temp[pointer] = yytext[i];
            pointer++;
          }
      }
      temp[pointer] = '\0';
      int scan_flag = 0;
      for(int i = 0; i < strlen(temp) - 1; i++){
          if(temp[i] == '@' && temp[i+1] == ','){
              scan_flag = 1;
          }
      }
      if(temp[strlen(temp)-1] != '@'){
          scan_flag = 0;
      }
      if(scan_flag == 1){
        printf("returning SCAN_FORMAT\n");
        yylval.t.arg_count = atrates;
        return SCAN_FORMAT;
      }
      else{
        printf("returning FORMAT\n");
        yylval.t.arg_count = atrates;
        return FORMAT;
      }
  }
}
{LOWERCASE}({LOWERCASE}|{DIGIT}|_)* {yylval.sval = yytext; return ID;}
{LOWERCASE}+"["{DIGIT}+"]" {yylval.sval = yytext; return ARR;}
. {printf("Unidentified character\n");}
%%

int yywrap() {
	return 1;
}
