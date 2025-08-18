@isTest
private class QueryExpressionTest {
    @isTest
    private static void testParser() {
        String exprString = 'A = \'Text Value\' AND (C>=10.2 OR FF=$User.name) OR Func(2, 10)=TRUE AND f (2)=false AND ID NOT IN (\'aaa\', \'bbb\') OR C=dd';
        QueryExpressionParser parser = new QueryExpressionParser(exprString);
        QueryExpression expr = parser.parse(null);
        System.debug(expr.toString());
    }

    @isTest
    private static void testParserException() {
        String exprString = 'A = b';
        QueryExpressionParser parser = new QueryExpressionParser(exprString);
        try {
            parser.processGroupStopToken(null, null);
        } catch (ExpressionTokenIterator.InvalidTokenException ex) {

        }
        try {
            parser.processCommaToken(null, null);
        } catch (ExpressionTokenIterator.InvalidTokenException ex) {
            
        }
    }

    @isTest
    private static void testParserFunction() {
        String exprString = 'A(a= b, 10.0)=true';
        QueryExpressionParser parser = new QueryExpressionParser(exprString);
        QueryExpression expr = parser.parse(null);
        System.debug(expr.toString());
    }

    @isTest
    private static void testParserEval() {
        {
            String exprString = '10>1 OR 10=1 OR 10!=1 OR 10>1 OR 10>=1 OR 10<1 OR 10<=1 ';
            QueryExpressionParser parser = new QueryExpressionParser(exprString);
            QueryExpression expr = parser.parse(null);
            Boolean result = (Boolean)expr.evaluate();
            System.debug(result);
        }
        {
            String exprString = '10.0>1.0 OR 10.1=1.1 OR 10.1 !=1.1 OR 10.1>1.1 OR 10.1>=1.1 OR 10.1<1.1 OR 10.1<=1.0 ';
            QueryExpressionParser parser = new QueryExpressionParser(exprString);
            QueryExpression expr = parser.parse(null);
            Boolean result = (Boolean)expr.evaluate();
            System.debug(result);
        }
        {
            String exprString = '\'2024-10-12 14:22:30\' = \'2024-10-12 14:22:30\' OR ' + 
                                '\'2024-10-12 14:22:30\' != \'2024-10-12 14:22:30\' OR ' +
                                '\'2024-10-12 14:22:30\' > \'2024-10-12 14:22:30\' OR ' +
                                '\'2024-10-12 14:22:30\' >= \'2024-10-12 14:22:30\' OR ' +
                                '\'2024-10-12 14:22:30\' < \'2024-10-12 14:22:30\' OR ' +
                                '\'2024-10-12 14:22:30\' <= \'2024-10-12 14:22:30\'';
            QueryExpressionParser parser = new QueryExpressionParser(exprString);
            QueryExpression expr = parser.parse(null);
            Boolean result = (Boolean)expr.evaluate();
            System.debug(result);
        }   
        {
            String exprString = '\'2024-10-12\' = \'2024-10-12\' OR ' + 
                                '\'2024-10-12\' != \'2024-10-12\' OR ' +
                                '\'2024-10-12\' > \'2024-10-12\' OR ' +
                                '\'2024-10-12\' >= \'2024-10-12\' OR ' +
                                '\'2024-10-12\' < \'2024-10-12\' OR ' +
                                '\'2024-10-12\' <= \'2024-10-12\'';
            QueryExpressionParser parser = new QueryExpressionParser(exprString);
            QueryExpression expr = parser.parse(null);
            Boolean result = (Boolean)expr.evaluate();
            System.debug(result);
        }          
        {
            String exprString = 'true=true OR true!=False';
            QueryExpressionParser parser = new QueryExpressionParser(exprString);
            QueryExpression expr = parser.parse(null);
            Boolean result = (Boolean)expr.evaluate();
            System.debug(result);
        }   

        {
            String exprString = '\'true\'=\'true\' AND \'true\'=\'true\' OR \'true\'!=\'False\'';
            QueryExpressionParser parser = new QueryExpressionParser(exprString);
            QueryExpression expr = parser.parse(null);
            Boolean result = (Boolean)expr.evaluate();
            System.debug(result);
        }   
        {
            String exprString = 'null=null OR null!=null OR ' +
                                'True=null OR True!=null OR ' +
                                'null=False OR NULL!=False ';
            QueryExpressionParser parser = new QueryExpressionParser(exprString);
            QueryExpression expr = parser.parse(null);
            Boolean result = (Boolean)expr.evaluate();
            System.debug(result);
        }   
        {
            String exprString = '\'Abc\' like null OR \'Abc\' Like \'ab\'' ;
            QueryExpressionParser parser = new QueryExpressionParser(exprString);
            QueryExpression expr = parser.parse(null);
            Boolean result = (Boolean)expr.evaluate();
            System.debug(result);
        }           
    }

    @isTest
    private static void testException() {
        try {
            QueryExpression.LogicalOperator logicalOpr = new QueryExpression.LogicalOperator('');
        } catch (QueryExpression.InvalidOperatorException ex) {
            System.debug(ex.getMessage());
        }

        try {
            QueryExpression.LogicalOperator logicalOpr = new QueryExpression.LogicalOperator('NAOPR');
        } catch (QueryExpression.InvalidOperatorException ex) {
            System.debug(ex.getMessage());
        }

        try {
            QueryExpression.LiteralExpr literalExpr = new QueryExpression.LiteralExpr('NAOPR', null);
            literalExpr.evaluate();
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        try {
            QueryExpression.VariableExpr varExpr = new QueryExpression.VariableExpr('NAOPR', null);
            varExpr.evaluate();
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        try {
            QueryExpression.GroupExpr grpExpr = new QueryExpression.GroupExpr(new QueryExpression.LiteralExpr('Ab', null) , null);
            grpExpr.evaluate();
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
        try {
            QueryExpression.CollectionExpr colExpr = new QueryExpression.CollectionExpr(null);
            colExpr.evaluate();
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

        try {
            QueryExpression.FunctionExpr funcExpr = new QueryExpression.FunctionExpr('NAOPR', null);
            funcExpr.evaluate();
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }        


        try {
            QueryExpression.LogicalExpr logicalExpr = new QueryExpression.LogicalExpr(null, 'NOT', null);
            logicalExpr.addRightOperand(new QueryExpression.LiteralExpr('false', null));
            logicalExpr.toString();
            logicalExpr.evaluate();

            logicalExpr = new QueryExpression.LogicalExpr(null, '>', null);
            logicalExpr.compare('>', null, null, logicalExpr);
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        } 
        try {
            QueryExpression.LogicalExpr logicalExpr = new QueryExpression.LogicalExpr(null, '>', null);
            logicalExpr.compare('>', 'abc', null, logicalExpr);

        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }  
        try {
            QueryExpression.LogicalExpr logicalExpr = new QueryExpression.LogicalExpr(null, '>', null);
            logicalExpr.getDataType(new QueryExpression.FunctionExpr('NAOPR', null));

        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }         
    }

}