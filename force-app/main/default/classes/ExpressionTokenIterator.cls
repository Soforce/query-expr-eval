public with sharing class ExpressionTokenIterator implements Iterator<ExpressionTokenIterator.Token> {
    public class InvalidTokenException extends Exception {}
    public class TokenIteratorException extends Exception {}

    private List<Token> tokens;
    private Integer currentIndex;

    public enum ExpressionTokenType {
        LogicalOperator,        // AND, OR, NOT
        ComparisonOperator,     // =, >, >=, <, <=, !=, IN, NOT IN, LIKE, INCLUDES, EXCLUDES
        FunctionStart,          // FunctName(
        Coma,                   // ,
        GroupStart,             // (
        GroupStop,              // )
        Variable,               // varName
        Literal                 // True, False, NULL, 'String', 12, 12.34
    }    

    public ExpressionTokenIterator(String expressionString) {
        this.tokens = tokenize(expressionString);
        this.currentIndex = 0;
    }

    public Boolean hasNext() { 
        return currentIndex < tokens.size();
    }    
  
    public Token next() {
        if(hasNext()) {
            return tokens[currentIndex++];
        } else {
            throw new TokenIteratorException('TokenIterator has no more elements.');
        }
    } 

    public Token peekNext() {
        if (hasNext()) {
            return tokens[currentIndex];
        } else {
            return null;
        }
    }

    /**
     * @description tokenize the expression string 
     */
    private Token[] tokenize(String expressionString) {
        // Holds the tokens parsed
        Token[] expressionTokens = new List<Token>();

        // Char array used to loop through for tokens
        List<Integer> expressionChars = expressionString.getChars();
        
        // holds the in-progress token chars 
        List<Integer> tokenChars = new List<Integer>(); 
        Integer idx = 0;
        while (idx < expressionChars.size()) { 
            Integer ch = expressionChars[idx];

            // if (tokenChars == null) tokenChars = new List<Integer>();
            if (ch == 32 || ch == 9) { // space or tab is found
                if (tokenChars.size() == 0) {
                    // skip/ignore the tab or space char 
                    // idx ++; 
                } else {
                    // A token is found on hitting the space or tab
                    Token token = new Token(tokenChars);
                    if (token.tokenText == 'IN' && expressionTokens[expressionTokens.size() - 1].tokenText == 'NOT') {
                        expressionTokens.remove(expressionTokens.size() - 1);
                        expressionTokens.add(new Token('NOT IN'));
                    } else {
                        expressionTokens.add(token);
                    }

                    tokenChars = new List<Integer>(); // re-initialize the tokenChars array for new token
                }
            } else if (ch == 44) { // ","
                if (tokenChars.size() > 0) {
                    // A token is found on hitting the coma(,)
                    expressionTokens.add(new Token(tokenChars));
                    tokenChars = new List<Integer>(); // re-initialize the tokenChars array for new token
                }
                expressionTokens.add(new Token(',')); // Coma is a token for function
            } else if (ch == 40) { // group exprs in (
                // Can be FuncStart or GroupStart
                if (tokenChars.size() > 0) {
                    // Function( 
                    tokenChars.add(ch);
                    expressionTokens.add(new Token(tokenChars));
                    tokenChars = new List<Integer>(); // re-initialize the tokenChars array for new token
                } else {
                    if (expressionTokens.size() > 0 && expressionTokens[expressionTokens.size() - 1].TokenType == ExpressionTokenType.Variable) {
                        // The previous token of left parenthsis is a variable, then the previous token needs to be converted to FuncStart
                        expressionTokens[expressionTokens.size() - 1] = new Token(expressionTokens[expressionTokens.size() - 1].tokenText + '(');
                    } else {
                        expressionTokens.add(new Token('('));
                    }
                }
            } else if (ch == 41) { // group exprs in )
                if (tokenChars.size() > 0) {
                    // token found before the closing ")"
                    expressionTokens.add(new Token(tokenChars));
                    tokenChars = new List<Integer>(); // re-initialize the tokenChars array for new token
                }
                expressionTokens.add(new Token(')'));
            } else if (ch == 39) { // single quote '
                tokenChars.add(ch);
                // Find the right single quote to close 
                ch = expressionChars[++idx];
                while (ch != 39 || (ch == 39 && expressionChars[idx-1] == 92)) { // Not single quote or escapted single quote
                    tokenChars.add(ch);
                    ch = expressionChars[++idx];
                }
                tokenChars.add(ch); // the closing single quote
            } else if (ch == 61 || ch == 60 || ch == 62 || ch == 33) { // =, <, > ! operators
                if (tokenChars.size() > 0) {
                    expressionTokens.add(new Token(tokenChars));
                    tokenChars = new List<Integer>(); // re-initialize the tokenChars array for new token
                }
                tokenChars.add(ch);
                if (ch != 61 && expressionChars[idx+1] == 61) {
                    ch = expressionChars[++idx];
                    tokenChars.add(ch); // Add = for >= or <=
                }
                expressionTokens.add(new Token(tokenChars));
                tokenChars = new List<Integer>(); // re-initialize the tokenChars array for new token
            } else {
                tokenChars.add(ch);
            }

            idx += 1;

            // Move to the next last of the tokenChars, need to pickup the last token
            if (idx == expressionChars.size() && tokenChars.size() > 0) {
                // Pickup the last token
                expressionTokens.add(new Token(tokenChars));
            }
        }


        {
            List<String> ts = new List<String>();
            for (Token t : expressionTokens) {
                ts.add(t.tokenText);
            }
            System.debug('tokens: ' + String.join(ts, '; '));
        }

        return expressionTokens;
    }    

    public class Token {
        public String tokenText;
        public ExpressionTokenType tokenType;
    
        public Token() {}
        
        public Token(String tokenText) {
            this();
            this.tokenText = tokenText;
            // TfB_DebugLog.logFiner(tokenText);
            switch on this.tokenText.toUpperCase() {
                when 'AND', 'OR', 'NOT' {
                    this.tokenType = ExpressionTokenType.LogicalOperator;
                }
                when '=', '>', '>=', '<', '<=', '!=', 'IN', 'NOT IN', 'LIKE', 'INCLUDES', 'EXCLUDES' {
                    this.tokenType = ExpressionTokenType.ComparisonOperator;
                }
                when '(' {
                    this.tokenType = ExpressionTokenType.GroupStart;
                }
                when ')' {
                    this.tokenType = ExpressionTokenType.GroupStop;
                }
                when ',' {
                    this.tokenType = ExpressionTokenType.Coma;
                }
                when 'TRUE', 'FALSE', 'NULL' {
                    this.tokenType = ExpressionTokenType.Literal;
                }
                when else {
                    if (this.tokenText.endsWith('(')) {
                        this.tokenType = ExpressionTokenType.FunctionStart;
                    } else if (tokenText.isNumeric() || tokenText.startsWith('\'')) {
                        this.tokenType = ExpressionTokenType.Literal;
                    } else {
                        try {
                            Decimal d = Decimal.valueOf(tokenText);
                            this.tokenType = ExpressionTokenType.Literal;
                        } catch (Exception ex) {
                            this.tokenType = ExpressionTokenType.Variable;
                        }
                    }
                }
            }
        }
    
        public Token(List<Integer> tokenChars) {
            this(String.fromCharArray(tokenChars));
        }
    
        public Boolean isOperator() {
            return tokenType == ExpressionTokenType.LogicalOperator || tokenType == ExpressionTokenType.ComparisonOperator;
        }
    
        public Integer getOperatorPrcedence() {
            QueryExpression.LogicalOperator opr = new QueryExpression.LogicalOperator(tokenText);
            return opr.getPrecedence();
        }    
    
    }
}