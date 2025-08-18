public with sharing class SObjectQueryExprPlugin implements QueryExpression.IExpressionProcessorPlugin, QueryExpression.IExpressionQueryPlugin {
    public class SObjectQueryExprPluginException extends Exception {}

    private String sobjectPrefix;

    public SObjectQueryExprPlugin() {

    }

    public SObjectQueryExprPlugin(String sobjectPrefix) {
        this.sobjectPrefix = sobjectPrefix;
    }

    /**
     * Implement IExpressionProcessorPlugin.evaluateVar
     */
    public Object evaluateVar(String varName, Object context) {
        
        List<String> parts = varName.split('\\.');
        if (parts[0].startsWith('$User')) {
            if (SObjectQueryExprPlugin.loginUser == null) SObjectQueryExprPlugin.loginUser = getUserInfo();
            return SObjectQueryExprPlugin.loginUser.get(parts[1]);
        } else if (parts[0].startsWith('$Organization')) {
            if (SObjectQueryExprPlugin.myOrg == null) SObjectQueryExprPlugin.myOrg = getOrganization();
            return SObjectQueryExprPlugin.myOrg.get(parts[1]);
        } else {
            if (context == null) return null;
            
            SObject sobj = (SObject)context;
            if (parts.size() == 1) return sobj.get(varName);
            else if (parts.size() == 2) {
                return sobj.getSObject(parts[0]).get(parts[1]);
            } else {
                throw new QueryExpression.NotSupportedException('The ' + varName + ' variable is Not supported');
            }
        }
    }
    /**
     * Implement IExpressionProcessorPlugin.evaluateFunc
     */
    public Object evaluateFunc(String funcName, List<Object> params, Object context) {
        throw new SObjectQueryExprPluginException('The ' + funcName + ' function is NOT supported by the SObjectQueryExprPlugin yet.');
    }   
    /**
     * Implement IExpressionQueryPlugin.buildQuery
     */
    public String buildQuery(String query, QueryExpression expr) {
        if (sobjectPrefix != null && expr instanceOf QueryExpression.VariableExpr) {
            return sobjectPrefix + '.' + query;
        } else {
            return query;
        }
    }    
    
    /**
     * Retrieve current login user
     */
    private static User loginUser;
    private User getUserInfo() {
        User u = [SELECT Id, Username, FirstName, LastName, Title, Phone, Fax, ProfileId, Address, Alias, CompanyName, Department, Division
                    FROM User
                    WHERE Id=:UserInfo.getUserId()];
        return u;
    }

    /**
     * Retrieve organization info
     */
    private static Organization myOrg;
    private Organization getOrganization() {
        Organization org = [SELECT Id, OrganizationType, Name, Division, Street, City, State, PostalCode, Country, Fax, Phone, UiSkin
                    FROM Organization LIMIT 1];
        return org;
    }

}