#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Function to create a comment node in the AST
ASTNode* createCommentNode(NodeType type) {
	
	ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
	if (!node) {
		fprintf(stderr, "Memory allocation failed\n");
		exit(EXIT_FAILURE);
	}
	
	node->type = NODE_COMMENT;
	return node;
}

// Function to create a number node in the AST
ASTNode* createNumberNode(int value) {
	printf("Creating NUMBER node: %d\n", value);
	
	ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
	if (!node) {
		fprintf(stderr, "Memory allocation failed\n");
		exit(EXIT_FAILURE);
	}
	
	node->type = NODE_NUMBER;
	node->data.value = value;
	return node;
}

// Function to create a string node in the AST
ASTNode* createStringNode(char* str) {
	printf("Creating STR node: %s\n", str);
	
	ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
	if (!node) {
		fprintf(stderr, "Memory allocation failed\n");
		exit(EXIT_FAILURE);
	}
	
	node->type = NODE_STR;
	strcpy(node->data.str, str);
	return node;
}

// Function to create an operator node with left and right children
ASTNode* createOperatorNode(NodeType type, ASTNode* left, ASTNode* right) {
	printf("Creating OPERATOR node: %d\n", type);
	
	ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
	if (!node) {
		fprintf(stderr, "Memory allocation failed\n");
		exit(EXIT_FAILURE);
	}
	
	node->type = type;
	node->data.children.left = left;
	node->data.children.right = right;
	return node;
}

// Function to create an decl node in the AST
ASTNode* createDeclNode(NodeType type, char* id, char* dataType) {
	printf("Creating DECL node: %d\n", type);
	
	ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
	if (!node) {
		fprintf(stderr, "Memory allocation failed\n");
		exit(EXIT_FAILURE);
	}
	
	node->type = type;
	switch (type) {
		case NODE_DECL_ID:
			strcpy(node->data.str, id);
			node->data.children.left = createStringNode(dataType);
			break;
			
		case NODE_DECL_ARR:
			char arrid[100];
			int i = 0;
			
			while(id[i] != '[') {
				i++;
			}
			
			strncpy(arrid, id + 0, i);
			arrid[i] = '\0';
			
			char numid[100];
			i++;
			int numidx = i;
			int len = 0;
			while(id[i] != ']'){
				i++;
				len++;
			}
			
			strncpy(arrid, id + numidx, len);
			numid[len] = '\0';
			
			strcpy(node->data.str, arrid);
			ASTNode* num_node = createStringNode(numid);
			node->data.children.left = num_node;			
			num_node->data.children.left = createStringNode(dataType);
		
			break;
		default:
			printf("invalid Declaration\n");
	}
	
	return node;
}

// Function to print the AST in a readable format
void printAST(ASTNode* node) {
	if (node == NULL || node->type == NODE_COMMENT) return;
	
	if (node->type == NODE_NUMBER) {
		printf("%d", node->data.value);
	} 
	else if(node->type == NODE_STR){
		printf("%s", node->data.str);
	} else {
		printf("("); // Start expression
		switch (node->type) {
			case NODE_ADD:
				printf("+ ");
				break;
			case NODE_SUB:
				printf("- ");
				break;
			case NODE_MUL:
				printf("* ");
				break;
			case NODE_DIV:
				printf("/ ");
				break;
			
			case NODE_DECL_ID:
				printf("%s ", node->data.str);	
				ASTNode* idtype = node->data.children.left;	
				printAST(idtype);
				printf(")\n");
				return;
			
			case NODE_DECL_ARR:
				printf("%s", node->data.str);	
				ASTNode* arrnum = node->data.children.left;	
				printAST(arrnum);
				printf(" ");
				ASTNode* arrtype = arrnum->data.children.left;
				printAST(arrtype);
				printf(")\n");
				return;	
			
			default:
				printf("? "); // Handle unknown node types
		}
		
		printAST(node->data.children.left);
		printf(" ");
		printAST(node->data.children.right);
		printf(")"); // Close expression
	}
}

// Function to free the memory allocated for the AST
void freeAST(ASTNode* node) {
	if (node == NULL) return;
	
	if (node->type != NODE_NUMBER) {
		freeAST(node->data.children.left);
		freeAST(node->data.children.right);
	}
	
	free(node);
}
