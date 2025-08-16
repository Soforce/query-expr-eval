# QueryExprEval Utility Component

The QueryExprEval utility component provides classes and methods for evaluating SQL-based query expressions for SObjects and Apex objects. This component extends the out-of-the-box FormulaEval solution to support SQL-based expression evaluation.

```Java
String exprString = 'AssistantName Like \'%Test%\' AND Title=\'Mr.\' AND Account.Name=\'Soforce\'';
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
```

## Supported Operators

The QueryExprEval component supports the following operators:
* AND, OR, NOT, LIKE, IN and 'NOT IN'
* '=', '!=', '<', '<=', '>', '>='

## QueryExpression Class
### Usage
The QueryExpression class constructs and evaluates a query’s logical expression using the provided context object.

### QueryExpression Methods
* [build(expr)](#buildexpr) <br>
  Parse the query expression string.
 
* [build(expr, plugin)](#buildexpr-plugin) <br>
  Parse the query expression string.

- [evaluate(ctx)](#evaluatectx) <br>
  Return the evaluated result for the given expression and context object.
      
#### build(expr)
##### Signature
```Java
public static QueryExpression build(String expression) 
```
##### Parameters
###### ***expressison***
Type: String

Query expression string to be evaluated.

##### Return Value
Type: QueryExpression

##### Example
```Java
String exprString = 'AssistantName Like \'%Test%\' AND Title=\'Mr.\' AND Account.Name=\'Soforce\'';
QueryExpression expr = QueryExpression.build(exprString);
System.debug(expr.toString());
```



#### build(expr, plugin)
##### Signature
```Java
public static QueryExpression build(String expression, IExpressionProcessorPlugin plugin) 
```
##### Parameters
###### ***expressison***
**Type**: ***String***

Query expression string to be evaluated.

###### ***plugin***
**Type**: ***IExpressionProcessorPlugin***

The custom expression plugin Apex class to extend the functionality of QueryExprEval. The custom plugin must implement the IExpressionProcessorPlugin interface.

##### Return Value
Type: QueryExpression

##### Example
```Java
String exprString = 'AssistantName Like \'%Test%\' AND Title=\'Mr.\' AND Account.Name=\'Soforce\'';
QueryExpression.IExpressionProcessorPlugin plugin = new SObjectQueryExprPlugin();
QueryExpression expr = QueryExpression.build(exprString, plugin);
System.debug(expr.toString());
```

#### evaluate(ctx)
##### Signature
```Java
public Object evaluate(Object context)
```
##### Parameters
###### ***context***
Type: Object

The context object to be evaluated with the given query expression.

##### Return Value
Type: Object
Return the evaluated result for the given expression and context object.

##### Example
```
    String exprString = 'AssistantName Like \'%Test%\' AND Title=\'Mr.\'';
    QueryExpression expr = QueryExpression.build(exprString);
    Contact c = new Contact(
        AssistantName = 'Test@soforce.com',
        Title = 'Mr.'
    );
    Boolean result = (Boolean)expr.evaluate(c);
    System.debug(result); // true
```

## IExpressionProcessorPlugin Class
### Usage
The interface to extend the functionality of the QueryExprEval utility class. The ```SObjectQueryExprPlugin``` has been provided to support Sobject as the context object.

### IExpressionProcessorPlugin Methods
#### evaluateVar(varName, ctx)
Return the value of the given variable name based on the given context object. 
##### Signature
```Java
Object evaluateVar(String varName, Object context) 
```
##### Parameters
###### ***varName***
Type: String

###### ***context***
Type: Object

##### Return Value
Type: Object


#### evaluateFunc(funcName, Object[] args, ctx)
Return the executed result of the given function based on the given context object. 
##### Signature
```Java
Object evaluateFunc(String funcName, List<Object> params, Object context) 
```
##### Parameters
###### ***funcName***
**Type**: ***String***

###### ***params***
**Type**: ***List<Object>***

The params passed to the function.

##### Parameters
###### ***context***
**Type**: ***Object***

##### Return Value
Type: Object


