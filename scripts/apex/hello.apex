// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

String exprString = 'A = B AND (C>10 OR FF=$User.name) OR Func(2, 10)=TRUE';
QueryExpressionParser parser = new QueryExpressionParser(exprString);
QueryExpression expr = parser.parse(null);
System.debug(expr.toString());

Datetime.valueOf()

String p = '^(\\d{4})\\-(0?[1-9]|1[012])\\-(0?[1-9]|[12][0-9]|3[01]) ([0-1][0-9]|[2][0-3]):([0-5][0-9]):([0-5][0-9])$';
Boolean r = Pattern.matches(p, '1992-10-12 23:12:12');
System.debug(r);

String p = '^(\\d{4})\\-(0?[1-9]|1[012])\\-(0?[1-9]|[12][0-9]|3[01])$';
Boolean r = Pattern.matches(p, '1992-13-12');
System.debug(r);

{
    SObjectQueryExprPlugin plugin = new SObjectQueryExprPlugin();
    String exprString = 'AssistantName Like \'%Jyue\' AND Title=\'Mr.\'';
    // String exprString = 'A = B AND (C>10 OR FF=$User.name) OR Func(2, 10)=TRUE';
    QueryExpressionParser parser = new QueryExpressionParser(exprString);
    QueryExpression expr = parser.parse(new SObjectQueryExprPlugin());
    Contact c = new Contact(
        AssistantName = 'Jyue@salesforce.com',
        Title = 'Mr.'
    );
    System.debug(expr.toString());
    System.debug(expr.evaluate(c));
}

{
    String exprString = 'AssistantName Like \'%Test%\' AND Title=\'Mr.\' AND Account.Name=\'Soforce\'';
    // String exprString = 'Account.Name=\'Soforce1\'';
    QueryExpression expr = QueryExpression.build(exprString);
    Contact c = new Contact(
        AssistantName = 'Test@soforce.com',
        Title = 'Mr.'
    );
    Account parentAccount = new Account(
        Name = 'Soforce'
    );
    c.putSObject('Account', parentAccount);
    System.debug(expr.evaluate(c));




}