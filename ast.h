#ifndef AST_H
#define AST_H

typedef enum {
	NODE_NUMBER,
	NODE_STR,
	NODE_COMMENT,
	NODE_ADD,
	NODE_SUB,
	NODE_MUL,
	NODE_DIV,
	NODE_DECL_ID,
	NODE_DECL_ARR
} NodeType;

typedef struct ASTNode {
	NodeType type;
	union {
		int value;
		char* str;
		struct {
			struct ASTNode* left;
			struct ASTNode* right;
		} children;
	} data;
} ASTNode;

ASTNode* createNumberNode(int value);
ASTNode* createOperatorNode(NodeType type, ASTNode* left, ASTNode* right);
ASTNode* createDeclNode(NodeType type, char* id, char* dataType);
ASTNode* createCommentNode(NodeType type);
void printAST(ASTNode* node);
void freeAST(ASTNode* node);

#endif // AST_H
