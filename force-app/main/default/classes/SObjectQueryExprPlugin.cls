public with sharing class SObjectQueryExprPlugin implements QueryExpression.IExpressionProcessorPlugin {
    public class SObjectQueryExprPluginException extends Exception {}
    public SObjectQueryExprPlugin() {

    }

    public Object evaluateVar(String varName, Object context) {
        SObject sobj = (SObject)context;
        return sobj.get(varName);
    }

    public Object evaluateFunc(String funcName, List<Object> params, Object context) {
        throw new SObjectQueryExprPluginException('Function is NOT supported by the SObjectQueryExprPlugin yet.');
    }    
}