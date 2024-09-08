public with sharing virtual class QueryExpressionParser {
  
    // Operator Expression stack 
    private OperatorExpressionStack oprExprStack;
    // ExpressionToken iterator
    public ExpressionTokenIterator tokenIterator;

    public QueryExpressionParser(String expressionString) {
        ExpressionTokenIterator iterator = new ExpressionTokenIterator(expressionString);
        this.tokenIterator = iterator;
        this.oprExprStack = new OperatorExpressionStack();
    }

    public QueryExpressionParser(ExpressionTokenIterator tokenIterator) {
        this.tokenIterator = tokenIterator;
        this.oprExprStack = new OperatorExpressionStack();
    }

    /**
     * @description utility method to parse the expression string to the QueryExpression
     */
    public virtual QueryExpression parse(QueryExpression.IExpressionProcessorPlugin plugin) {
        QueryExpression operand;
        ExpressionTokenIterator.Token prevToken;

        while (tokenIterator.hasNext()) {
            // Pick up
            ExpressionTokenIterator.Token token = tokenIterator.next();
            // TfB_DebugLog.logFiner('token: ' + token.tokenText);

            switch on token.tokenType {
                when LogicalOperator, ComparisonOperator {
                    operand = processOperatorToken(operand, token.tokenText, plugin);
                }
                when Literal {
                    operand = processLiteralToken(token.tokenText, plugin);
                }
                when Variable {
                    operand = processVariableToken(token.tokenText, plugin);
                }
                when FunctionStart {
                    // Start dedicated parser for Function
                    operand = processFunctionStartToken(operand, token.tokenText, plugin);
                } 
                when GroupStart {
                    if (prevToken != null && (prevToken.tokenText == 'IN' || prevToken.tokenText == 'NOT IN')) {
                        operand = processCollectionStartToken(token.tokenText, plugin);
                    } else {
                        operand = processGroupStartToken(token.tokenText, plugin);
                    }   
                }
                when GroupStop {
                    operand = processGroupStopToken(operand, plugin);

                    break;
                }
                when Coma {
                    operand = processCommaToken(operand, plugin);
                }
                when else {
                    // exception
                    throw new ExpressionTokenIterator.InvalidTokenException();
                }
            }

            // store the prevToken
            prevToken = token;
        }

        // Loop through the end of tokens.
        if (!tokenIterator.hasNext() && this.oprExprStack.peek() != null) {
            operand = this.oprExprStack.reduce(operand, null);
        }

        // Attach the evaluator if provided
        // operand.setPlugin(plugin);

        return operand;
    }    

    protected virtual QueryExpression processOperatorToken(QueryExpression leftOperand, String tokenText, QueryExpression.IExpressionProcessorPlugin plugin) {
        // System.debug(tokenText);
        QueryExpression.LogicalExpr oprExpr = new QueryExpression.LogicalExpr(leftOperand, tokenText, plugin);
        // oprExpr.setPlugin(plugin);

        oprExprStack.push(oprExpr);

        return null;
    }

    protected virtual QueryExpression processLiteralToken(String tokenText, QueryExpression.IExpressionProcessorPlugin plugin) {
        QueryExpression operand = new QueryExpression.LiteralExpr(tokenText, plugin);
        // operand.setPlugin(plugin);

        ExpressionTokenIterator.Token nextToken = this.tokenIterator.peekNext();
        if (nextToken != null && nextToken.isOperator() && this.oprExprStack.peek() != null) {
            // if nextToken is operator and the current expr stack is NOT empty, needs to evaluate if the current operand should assigned to the current operator based on the precedence.
            return this.oprExprStack.reduce(operand, nextToken);
        } else {
            return operand;
        }
    }

    protected virtual QueryExpression processVariableToken(String tokenText, QueryExpression.IExpressionProcessorPlugin plugin) {
        QueryExpression operand = new QueryExpression.VariableExpr(tokenText, plugin);
        // operand.setPlugin(plugin);

        ExpressionTokenIterator.Token nextToken = this.tokenIterator.peekNext();
        if (nextToken != null && nextToken.isOperator() && this.oprExprStack.peek() != null) {
            // if nextToken is operator and the current expr stack is NOT empty, needs to evaluate if the current operand should assigned to the current operator based on the precedence.
            return this.oprExprStack.reduce(operand, nextToken);
        } else {
            return operand;
        }
    }

    protected virtual QueryExpression processGroupStartToken(String tokenText, QueryExpression.IExpressionProcessorPlugin plugin) {
        GroupExprParser groupParser = new GroupExprParser(this.tokenIterator, plugin);

        return groupParser.parse(plugin);
    }

    protected virtual QueryExpression processCollectionStartToken(String tokenText, QueryExpression.IExpressionProcessorPlugin plugin) {
        CollectionExprParser collectionParser = new CollectionExprParser(this.tokenIterator, plugin);

        return collectionParser.parse(plugin);
    }

    protected virtual QueryExpression processFunctionStartToken(QueryExpression leftOperand, String tokenText, QueryExpression.IExpressionProcessorPlugin plugin) {
        FunctionExprParser funcParser = new FunctionExprParser(this.tokenIterator, tokenText, plugin);
        
        return funcParser.parse(plugin);
    }

    @testVisible
    protected virtual QueryExpression processGroupStopToken(QueryExpression operand, QueryExpression.IExpressionProcessorPlugin plugin) {
        throw new ExpressionTokenIterator.InvalidTokenException();
    }

    @testVisible
    protected virtual QueryExpression processCommaToken(QueryExpression operand, QueryExpression.IExpressionProcessorPlugin plugin) {
        throw new ExpressionTokenIterator.InvalidTokenException();
    }

    
    /**
     * @description 
     */
    public virtual class GroupExprParser extends QueryExpressionParser {
        public GroupExprParser(ExpressionTokenIterator tokenIterator, QueryExpression.IExpressionProcessorPlugin plugin) {
            super(tokenIterator);
        }

        protected override QueryExpression processGroupStopToken(QueryExpression operand, QueryExpression.IExpressionProcessorPlugin plugin) {
            if (this.oprExprStack.peek() != null) {
                // reach the end of the group express 
                operand = this.oprExprStack.reduce(operand, null);
            }

            return new QueryExpression.GroupExpr(operand, plugin);
        }
    }

    /**
     * @description Parser for CollectionExpression, e.g. ('a', 'b')
     */
    public virtual class CollectionExprParser extends QueryExpressionParser {
        QueryExpression.CollectionExpr colExpr;

        public CollectionExprParser(ExpressionTokenIterator tokenIterator, QueryExpression.IExpressionProcessorPlugin plugin) {
            super(tokenIterator);

            colExpr = new QueryExpression.CollectionExpr(plugin);
        }

        protected override QueryExpression processGroupStopToken(QueryExpression operand, QueryExpression.IExpressionProcessorPlugin plugin) {
            colExpr.paramExprList.add(operand);
            return colExpr;
            // if (this.oprExprStack.peek() != null) {
            //     // reach the end of the group express 
            //     operand = this.oprExprStack.reduce(operand, null);
            // }

            // return new QueryExpression.GroupExpr(operand);
        }

        protected override QueryExpression processCommaToken(QueryExpression operand, QueryExpression.IExpressionProcessorPlugin plugin) {
            colExpr.paramExprList.add(operand);

            return null;
        }
    }

    /**
     * @description
     */
    public class FunctionExprParser extends QueryExpressionParser {
        QueryExpression.FuctionExpr funcExpr;

        public FunctionExprParser(ExpressionTokenIterator tokenIterator, String functionToken, QueryExpression.IExpressionProcessorPlugin plugin) {
            super(tokenIterator);

            funcExpr = new QueryExpression.FuctionExpr(functionToken.left(functionToken.length() - 1), plugin);
        }

        protected override QueryExpression processGroupStopToken(QueryExpression operand, QueryExpression.IExpressionProcessorPlugin plugin) {
            funcExpr.paramExprList.add(operand);
            return funcExpr;
        }

        protected override QueryExpression processCommaToken(QueryExpression operand, QueryExpression.IExpressionProcessorPlugin plugin) {
            funcExpr.paramExprList.add(operand);

            return null;
        }
    }


    /**
     * @description 
     */
    public class OperatorExpressionStack {
        private List<QueryExpression.LogicalExpr> exprStack;

        public OperatorExpressionStack() {
            this.exprStack = new List<QueryExpression.LogicalExpr>();
        }

        public void push(QueryExpression.LogicalExpr expr) {
            this.exprStack.add(expr);
        }

        public QueryExpression.LogicalExpr pop() {
            if (this.exprStack.size() > 0) return this.exprStack.remove(exprStack.size() - 1);
            return null;
        }

        public QueryExpression.LogicalExpr peek() {
            if (this.exprStack.size() > 0) return this.exprStack[exprStack.size() - 1];
            return null;        
        }

        public QueryExpression reduce(QueryExpression rightOperand, ExpressionTokenIterator.Token nextOprToken) {
            QueryExpression.LogicalExpr currentExpr = peek();
            if (currentExpr == null) return rightOperand;   // Nothing to reduce


            if (nextOprToken == null || currentExpr.getOperatorPrecedence() <= nextOprToken.getOperatorPrcedence()) {
                // The current expression operator precede the next operator to be evaluated, needs to be reduced.
                currentExpr = pop();
                currentExpr.addRightOperand(rightOperand);

                return reduce(currentExpr, nextOprToken);
            } else {
                // DO NOT reduce because the next operator has preceded the one currently in the stack
                return rightOperand;
            }
        }
    }    
}