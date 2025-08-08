public with sharing class SObjectQueryExprPlugin implements QueryExpression.IExpressionProcessorPlugin {
    public class SObjectQueryExprPluginException extends Exception {}
    public SObjectQueryExprPlugin() {

    }

    public Object evaluateVar(String varName, Object context) {
        SObject sobj = (SObject)context;
        List<String> parts = varName.split('\\.');
        if (parts.size() == 1) return sobj.get(varName);
        else if (parts.size() == 2) {
            return sobj.getSObject(parts[0]).get(parts[1]);
            // return sobj.get(varName);
        } else {
            throw new QueryExpression.NotSupportedException('Not supported');

        }
    }

    public Object evaluateFunc(String funcName, List<Object> params, Object context) {
        throw new SObjectQueryExprPluginException('Function is NOT supported by the SObjectQueryExprPlugin yet.');
    }    
}