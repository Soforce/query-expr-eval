/**
 * 
 */
public with sharing abstract class QueryExpression {

    public class InvalidOperatorException extends Exception {}
    public class NotImplementedException extends Exception {}
    public class NotSupportedException extends Exception {}
    public class InvalidVariableNameException extends Exception {}

    
    /**
     * @description Evaluator to evaluate variables
     */
    public interface IExpressionProcessorPlugin {
        Object evaluateVar(String varName, Object context);
        Object evaluateFunc(String funcName, List<Object> params, Object context);
    } 

    /**
     * @description Evaluator to evaluate variables
     */
    public interface IExpressionQueryPlugin {
        String buildQuery(String query);
    }

    
    /**
     * @description OperatorType enum for the Query/Logical Expression 
     */
    public enum LogicalOperatorType {
        AndOpr,
        OrOpr,
        NotOpr,
        InOpr,
        NotInOpr,
        LikeOpr,
        EqualToOpr,
        NotEqualToOpr,
        LessThanOpr,
        GreaterThanOpr,
        LessThanOrEqualToOpr,
        GreaterThanOrEqualToOpr,
        // Reserved for the future
        IncludesOpr ,
        ExcludesOpr
    }


    // Parent Expression Node
    protected transient QueryExpression parent;
    // The Expression Plugin processor 
    protected IExpressionProcessorPlugin plugin;

    // Evaluate the result 
    public abstract Object evaluate(Object context);
    public virtual Object evaluate() {
        return evaluate(null);
    }    

    /**
     * build Query string
     */
    public abstract String toQuery(IExpressionQueryPlugin queryPlugin);    

    /**
     * 
     */
    public String getDataType(Object value) {
        if (value instanceOf Boolean) return 'Boolean';
        else if (value instanceOf Date) return 'Date';
        else if (value instanceOf Datetime) return 'Datetime';
        // else if (value instanceOf Integer) return 'Integer';
        else if (value instanceOf Long) return 'Long';
        // else if (value instanceOf Decimal) return 'Decimal';
        else if (value instanceOf Double) return 'Double';
        else if (value instanceOf String) return 'String';
        // else if (value instanceOf Time) return 'Time';
        else {
            throw new NotSupportedException('The ' + value + ' is NOT supported.');
        }
    }

    /**
     * @descrptin Helper method for comparison operator, >, >=, <, <=
     */
    public Boolean compare(String operator, Object leftVal, Object rightVal) {
        if (leftVal == null && rightVal == null) {
            if (operator == '=') return true;
            else if (operator == '!=') return false;
            else 
                throw new NotSupportedException('The ' + operator + ' operator does not support NULL operand.');
        } else if (leftVal == null || rightVal == null) {
            if (operator == '=') return false;
            else if (operator == '!=') return true;
            else 
                throw new NotSupportedException('The ' + operator + ' operator does not support NULL operand.');            
        }

        String dataType = getDataType(leftVal);

        // TfB_DebugLog.logFine('QueryExpression.compare (' + operator + ', ' + dataType + '): ' + leftVal + ', ' + rightVal);
        switch on dataType {
            when 'Boolean' {
                if (operator == '=') return (Boolean)leftVal == (Boolean)rightVal;
                else if (operator == '!=') return (Boolean)leftVal != (Boolean)rightVal;
            }
            when 'String' {
                Boolean eq = ((String)leftVal).equalsIgnoreCase((String)rightVal);
                if (operator == '=') return eq;
                else if (operator == '!=') return !eq;
            }
            when 'Date' {
                if (operator == '=') return (Date)leftVal == (Date)rightVal;
                else if (operator == '!=') return (Date)leftVal != (Date)rightVal;
                else if (operator == '>') return (Date)leftVal > (Date)rightVal;
                else if (operator == '>=') return (Date)leftVal >= (Date)rightVal;
                else if (operator == '<') return (Date)leftVal < (Date)rightVal;
                else if (operator == '<=') return (Date)leftVal <= (Date)rightVal;
            }
            when 'Datetime' {
                if (operator == '=') return (Datetime)leftVal == (Datetime)rightVal;
                else if (operator == '!=') return (Datetime)leftVal != (Datetime)rightVal;
                else if (operator == '>') return (Datetime)leftVal > (Datetime)rightVal;
                else if (operator == '>=') return (Datetime)leftVal >= (Datetime)rightVal;
                else if (operator == '<') return (Datetime)leftVal < (Datetime)rightVal;
                else if (operator == '<=') return (Datetime)leftVal <= (Datetime)rightVal;
            }
            // when 'Decimal' {
            //     if (operator == '>') return (Decimal)leftVal > (Decimal)rightVal;
            //     else if (operator == '>=') { return (Decimal)leftVal >= (Decimal)rightVal; }
            //     else if (operator == '<') return (Decimal)leftVal < (Decimal)rightVal;
            //     else if (operator == '<=') return (Decimal)leftVal <= (Decimal)rightVal;
            //     else throw new InvalidOperatorException();               
            // }
            when 'Double' {
                if (operator == '=') return (Double)leftVal == (Double)rightVal;
                else if (operator == '!=') return (Double)leftVal != (Double)rightVal;
                else if (operator == '>') return (Double)leftVal > (Double)rightVal;
                else if (operator == '>=') return (Double)leftVal >= (Double)rightVal;
                else if (operator == '<') return (Double)leftVal < (Double)rightVal;
                else if (operator == '<=') return (Double)leftVal <= (Double)rightVal;
            }
            // when 'Integer' {
            //     if (operator == '>') return (Integer)leftVal > (Integer)rightVal;
            //     else if (operator == '>=') return (Integer)leftVal >= (Integer)rightVal;
            //     else if (operator == '<') return (Integer)leftVal < (Integer)rightVal;
            //     else if (operator == '<=') return (Integer)leftVal <= (Integer)rightVal;
            //     else throw new InvalidOperatorException();                        
            // }
            when 'Long' {
                if (operator == '=') return (Long)leftVal == (Long)rightVal;
                else if (operator == '!=') return (Long)leftVal != (Long)rightVal;
                else if (operator == '>') return (Long)leftVal > (Long)rightVal;
                else if (operator == '>=') return (Long)leftVal >= (Long)rightVal;
                else if (operator == '<') {
                    return (Long)leftVal < (Long)rightVal;
                } else if (operator == '<=') return (Long)leftVal <= (Long)rightVal;
            }
            // when 'Time' {
            //     if (operator == '>') return (Time)leftVal > (Time)rightVal;
            //     else if (operator == '>=') return (Time)leftVal >= (Time)rightVal;
            //     else if (operator == '<') return (Time)leftVal < (Time)rightVal;
            //     else if (operator == '<=') return (Time)leftVal <= (Time)rightVal;
            //     else throw new InvalidOperatorException();                       
            // }


        }
        throw new NotSupportedException('The ' + operator + ' operator does not support ' + dataType + ' value.');
    }


    /**************************************************************************
     * QuerExpression sub-classes
     **************************************************************************/
    /**
     * 
     */
    public class LogicalOperator {
        private Integer precedence;
        private String oprText;

        public LogicalOperator(String oprText) {
            
            if (String.isEmpty(oprText)) {
                throw new InvalidOperatorException('Operator cannot be empty.');
            }

            switch on oprText.toUpperCase() {
                when 'AND', 'OR', 'NOT' {
                    this.precedence = 20;
                }
                when 'IN', 'NOT IN', 'LIKE', '=', '!=', '<', '<=', '>', '>=', 'INCLUDES', 'EXCLUDES' {
                    this.precedence = 10;
                }
                when else {
                    throw new InvalidOperatorException(oprText + ' is an invalid operator.');
                }
            }
            this.oprText = oprText.toUpperCase();
        }

        public override String toString() {
            return oprText;
        }

        public Integer getPrecedence() {
            return this.precedence;
        }
    }


    /**
     * 
     */
    public class LiteralExpr extends QueryExpression {
        public String literal; 

        public LiteralExpr(String literal, IExpressionProcessorPlugin plugin) {
            this.literal = literal;
            this.plugin = plugin;
        }

        public override String toString() {
            if (literal.startsWith('"') && literal.endsWith('"')) return '\'' + literal.substring(1, literal.length() - 1) + '\'';
            else return literal;
        }

        public override String toQuery(IExpressionQueryPlugin queryPlugin) {
            if (queryPlugin != null) return queryPlugin.buildQuery(toString());
            return toString();
        }

        public override Object evaluate(Object context) {
            
            if (literal == 'null') return null;
            else if (literal == 'true' || literal == 'false') return Boolean.valueOf(literal);
            else if ((literal.startsWith('\'') && literal.endsWith('\'')) || (literal.startsWith('"') && literal.endsWith('"'))) {
                String value = literal.substring(1, literal.length() - 1);
                if (Pattern.matches('^(\\d{4})\\-(0?[1-9]|1[012])\\-(0?[1-9]|[12][0-9]|3[01]) ([0-1][0-9]|[2][0-3]):([0-5][0-9]):([0-5][0-9])$', value)) {
                    return Datetime.valueOf(value);
                }  else if (Pattern.matches('^(\\d{4})\\-(0?[1-9]|1[012])\\-(0?[1-9]|[12][0-9]|3[01])$', value)) {
                    return Date.valueOf(value);
                } else {
                    return value;
                }
            } else if (literal.isNumeric()) return Long.valueOf(literal);
            else if (Pattern.matches('^(([0-9]*)|(([0-9]*)\\.([0-9]*)))$', literal)) {
                return Double.valueOf(literal);
            } else {
                return this.literal;
            }
        }
    }

    /**
     * 
     */
    public class VariableExpr extends QueryExpression {
        public String variable; 

        public VariableExpr(String variable, IExpressionProcessorPlugin plugin) {
            this.variable = variable;
            this.plugin = plugin;
        }

        public override String toString() {
            return variable;
        }

        public override String toQuery(IExpressionQueryPlugin queryPlugin) {
            // if (this.plugin == null) return toString();
            // else return this.plugin.getSObjectFieldName(variable);
            if (queryPlugin != null) return queryPlugin.buildQuery(toString());
            return toString();            
        }        

        public override Object evaluate(Object context) {
            // TfB_DebugLog.logVar('variable', variable);
            return this.plugin.evaluateVar(variable, context);
        }
    }

    /**
     * 
     */
    public class LogicalExpr extends QueryExpression {
        public QueryExpression leftOperand;
        public QueryExpression rightOperand;
        public LogicalOperator operator;

        public LogicalExpr(QueryExpression leftOperand, String operatorText, IExpressionProcessorPlugin plugin) {
            this.plugin = plugin;
            this.leftOperand = leftOperand;
            this.operator = new LogicalOperator(operatorText);

            if (this.leftOperand != null)
                this.leftOperand.parent = this;
        }


        public QueryExpression addRightOperand(QueryExpression operand) {
            this.rightOperand = operand;
            this.rightOperand.parent = this;

            return this;
        }

        public override String toString() {
            if (leftOperand == null) {
                return operator.toString() + ' ' + rightOperand.toString();    
            } else {
                return leftOperand.toString() + ' ' + operator.toString() + ' ' + rightOperand.toString();    
            }
        }

        public override String toQuery(IExpressionQueryPlugin queryPlugin) {
            if (leftOperand == null) {
                return operator.toString() + ' ' + rightOperand.toQuery(queryPlugin);    
            } else {
                return leftOperand.toQuery(queryPlugin) + ' ' + operator.toString() + ' ' + rightOperand.toQuery(queryPlugin);    
            }
        }

        public Integer getOperatorPrecedence() {
            return operator.getPrecedence();
        }

        public override Object evaluate(Object context) {
            Object leftOpdVal = leftOperand?.evaluate(context);
            Object rightOpdVal = rightOperand.evaluate(context);

            // TfB_DebugLog.logFine('LogicalExpr.evaluate: ' + leftOpdVal + ', ' + rightOpdVal);
            switch on operator.oprText.toUpperCase() {
                when 'AND' {
                    return (Boolean)leftOpdVal && (Boolean)rightOpdVal;
                }
                when 'OR' {
                    return (Boolean)leftOpdVal || (Boolean)rightOpdVal;
                }
                when 'NOT' {
                    return !(Boolean)rightOpdVal;
                }
                when 'LIKE' {
                    if (leftOpdVal == null || rightOpdVal == null) return false;

                    if (leftOpdVal instanceOf String && rightOpdVal instanceOf String) {
                        String leftVal = (String)leftOpdVal;
                        String rightVal = (String)rightOpdVal;
                        if (rightVal.startsWith('%') && rightVal.endsWith('%')) {
                            return leftVal.contains(rightVal.substring(1, rightVal.length() - 1));
                        } else if (rightVal.startsWith('%')) {
                            return leftVal.endsWith(rightVal.substring(1));
                        } else if (rightVal.endsWith('%')) {
                            return leftVal.startsWith(rightVal.left(rightVal.length() - 1));
                        } else {
                            return leftVal == rightVal;
                        }
                    }
                }
                when 'IN', 'NOT IN' {
                    throw new NotImplementedException('The ' + operator.oprText +' is not supported yet.');
                }
                // when '=' {
                //     return leftOpdVal == rightOpdVal;
                // }
                // when '!=' {
                //     return leftOpdVal != rightOpdVal;
                // }
                when '=', '!=', '<', '<=', '>', '>=' {
                // when '<', '<=', '>', '>=' {
                    return compare(operator.oprText, leftOpdVal, rightOpdVal);
                }
                // when 'INCLUDES', 'EXCLUDES' {
                //     throw new NotSupportedException('The given left (' + leftOpdVal + ') and right (' + rightOpdVal + ') operands are not supported for the LIKE operator.');
                // }
                // when else {
                //     throw new InvalidOperatorException('The ' + operator.oprText + ' is an invalid operator.');
                // }
            }
            throw new NotSupportedException('The given left (' + leftOpdVal + ') and right (' + rightOpdVal + ') operands are not supported for the ' + operator.oprText + ' operator.');


        }
    }

    /**
     * 
     */
    public class GroupExpr extends QueryExpression {
        public QueryExpression groupExpr;

        public GroupExpr(QueryExpression operand, IExpressionProcessorPlugin plugin) {
            // this();
            this.plugin = plugin;
            this.groupExpr = operand;
            this.groupExpr.parent = this;
        }

        public override String toString() {
            return '(' + groupExpr.toString() + ')';
        }

        public override String toQuery(IExpressionQueryPlugin queryPlugin) {
            return '(' + groupExpr.toQuery(queryPlugin) + ')';
        }

        public override Object evaluate(Object context) {
            return groupExpr.evaluate(context);
        }
    }

    /**
     * @description Collection Expression, e.g. ('ab', 'bc')
     */
    public class CollectionExpr extends QueryExpression {
        public QueryExpression[] paramExprList;

        public CollectionExpr(IExpressionProcessorPlugin plugin) {
            this.plugin = plugin;
            paramExprList = new List<QueryExpression>();
        }

        // public CollectionExpr(QueryExpression operand) {
        //     this();
        //     this.groupExpr = operand;
        //     this.groupExpr.parent = this;
        // }

        public override String toString() {
            List<String> params = new List<String>();
            for (QueryExpression paramExpr : paramExprList) {
                params.add(paramExpr.toString());
            }

            return '(' + String.join(params, ', ') + ')';
        }

        public override String toQuery(IExpressionQueryPlugin queryPlugin) {
            List<String> params = new List<String>();
            for (QueryExpression paramExpr : paramExprList) {
                params.add(paramExpr.toQuery(queryPlugin));
            }

            return '(' + String.join(params, ', ') + ')';
        }

        public override Object evaluate(Object context) {
            List<Object> valueList = new List<Object>();
            for (QueryExpression paramExpr : paramExprList) {
                valueList.add(paramExpr.evaluate(context));
            }
            return valueList;
        }
    }

    /**
     * @description Collection Expression, e.g. ('ab', 'bc')
     */
    public class FuctionExpr extends QueryExpression {
        public String functionName;
        public QueryExpression[] paramExprList;

        public FuctionExpr(String functionName, IExpressionProcessorPlugin plugin) {
            this.plugin = plugin;
            this.functionName = functionName;
            paramExprList = new List<QueryExpression>();
        }

        // public FuctionExpr(QueryExpression operand) {
        //     this();
        //     this.groupExpr = operand;
        //     this.groupExpr.parent = this;
        // }

        public override String toString() {
            List<String> params = new List<String>();
            for (QueryExpression paramExpr : paramExprList) {
                params.add(paramExpr.toString());
            }

            return functionName + '(' + String.join(params, ', ') + ')';
        }

        public override String toQuery(IExpressionQueryPlugin queryPlugin) {
            List<String> params = new List<String>();
            for (QueryExpression paramExpr : paramExprList) {
                params.add(paramExpr.toQuery(queryPlugin));
            }

            return functionName + '(' + String.join(params, ', ') + ')';
        }

        public override Object evaluate(Object context) {
            List<Object> params = new List<Object>();
            for (QueryExpression paramExpr : this.paramExprList) {
                params.add(paramExpr.evaluate(context));
            }

            return this.plugin.evaluateFunc(functionName, params, context);
        }
    }    




    /**
     * @description utility method to parse the expression string to the QueryExpression
     */
    // public static QueryExpression parse(String expressionString) {
    //     QueryExpressionParser parser = new QueryExpressionParser(expressionString);
    //     return parser.parse(null);
    // }

    public static QueryExpression build(String expression, IExpressionProcessorPlugin plugin) {
        if (plugin == null ) plugin = new SObjectQueryExprPlugin();
        QueryExpressionParser parser = new QueryExpressionParser(expression);
        QueryExpression expr = parser.parse(plugin);

        return expr;
    }

    public static QueryExpression build(String expression) {
        return build(expression, null);
    }
}