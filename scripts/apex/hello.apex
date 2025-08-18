// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

{
    String queryFormula = '$User.FirstName="Justin"';
    QueryExpression expr = QueryExpression.build(queryFormula);
    System.debug(expr.evaluate());
}

{
    String queryFormula = '$User.FirstName="Justin" AND $Organization.Name="Demo Company" AND ProductCode="iPhone_15_0001" AND Name Like "iPhone%"';
    QueryExpression expr = QueryExpression.build(queryFormula);
    Product2 p = new Product2(
        ProductCode = 'iPhone_15_0001',
        Name = 'iPhone 15 256GB Black'
    );
    System.debug(expr.evaluate(p));

}

{
    String queryFormula = 'ProductCode="iPhone_15_0001" AND Name Like "iPhone%"';
    QueryExpression expr = QueryExpression.build(queryFormula);
    // Product2 p = new Product2(
    //     ProductCode = 'iPhone_15_0001',
    //     Name = 'iPhone 15 256GB Black'
    // );
    SObjectQueryExprPlugin queryPlugin = new SObjectQueryExprPlugin('Product2');
    System.debug(expr.toQuery(queryPlugin));

}

