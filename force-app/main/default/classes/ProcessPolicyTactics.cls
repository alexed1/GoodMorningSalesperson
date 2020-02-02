public with sharing class ProcessPolicyTactics {
    
    public static List<Policy__c> Process ( String tacticName, SalesTacticalPlan__c curSalesTacticalPlan, Integer maxResults) {
        List<SObject> relevantPolicies = new List<SObject>();
        switch on tacticName {
            when 'Policy Expiring Soon (Attained Age)'  {
                System.debug('entering Term Policy Expiring Soon');
                if (curSalesTacticalPlan.Tactical_Ordering__c.split(',').contains('Policy Expiring Soon (Attained Age)')) {
                    System.debug('Policy Expiring Soon (Attained Age) is a chosen tactic');
                    relevantPolicies = [select name, Id from Policy__c WHERE Policy__c.Days_to_Conversion_Credit_Expiration__c < 100 ORDER BY Policy__c.Days_to_Conversion_Credit_Expiration__c ASC  LIMIT :maxResults];
                }
            }
            when 'Conversion Option Expiring Soon'  {
                if (curSalesTacticalPlan.Tactical_Ordering__c.split(',').contains('Conversion Option Expiring Soon')) {
                    
                    System.debug('Conversion Option Expiring Soon is a chosen tactic');
                    relevantPolicies = [select name, Id from Policy__c WHERE Policy__c.Days_to_Conversion_Credit_Expiration__c	<100 AND Policy__c.Days_to_Conversion_Credit_Expiration__c >0 ORDER BY Policy__c.Days_to_Conversion_Credit_Expiration__c ASC  LIMIT :maxResults];
                }
            

            }
            when else {
                System.debug('unsupported value was passed in as tacticName');
            }
        }
        System.debug('Relevant Policies: ' + relevantPolicies);
        return relevantPolicies;
    }

    public static List<Recommendation> GenerateRecommendations (List<Policy__c> relevantPolicies, String tacticName, SalesTacticalPlan__c curSalesTacticalPlan ) {
        List<Recommendation> recs = new List<Recommendation>(); 
        if (relevantPolicies != null)
            for (Policy__c curItem:relevantPolicies) {
                Recommendation rec = new Recommendation(
                    Name = curItem.Name,
                    Description = 'Work on the ' + curItem.Name + ' Policy.' ,
                    //Pre-req: Create a screen flow with the name simpleFlow                        
                    ActionReference = 'TacticalFollowup',
                    AcceptanceLabel = 'Go',
                    Tactical_Priority__c = GenerateSalesTacticalPriorities.getPriority(curSalesTacticalPlan.Tactical_Ordering__c, tacticName),
                    ContextRecordId__c = curItem.Id,
                    ContextId__c = curItem.Id
                );
                System.debug('generated recommendation: ' + rec);
                System.debug('contextrecordId is ' + rec.ContextRecordId__c);
                recs.add(rec);
            }
        return recs;
    }
}
