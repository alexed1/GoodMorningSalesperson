public with sharing class ProcessServiceTactics {
    
    public static List<SObject> Process (String tacticName, SalesTacticalPlan__c curTacticalPlan, Integer maxResults) {
        List<SObject> relevantRecords = new List<SObject>();

        switch on tacticName {
            when 'Limited Offers'  {
                System.debug('entering Limited Offers');
                if (curTacticalPlan.Tactical_Ordering__c.split(',').contains('Limited Offers')) {
                    System.debug('Limited Offers is a chosen tactic');
                    //travel sector affected by an epidemic. highly disruptive. ask if we can help. HQ has authoized payment relief of 30 days
                    relevantRecords = [select Name, Id from Account WHERE Account.Industry IN ('Transportation','Tourism') AND Account.Region__c = 'East Asia'  LIMIT :maxResults];
                    for(SObject curItem : relevantRecords){
                        curItem.put('Description','Travel sector affected by an epidemic. May be disruptive to this customer. HQ has authorized payment relief of 30 days');
                    }
                }
            }
            when 'Case Follow Up'  {
                if (curTacticalPlan.Tactical_Ordering__c.split(',').contains('Case Follow Up')) {
                    //find cases where close date is less than 7 days ago, followup complete is false, tier is premium, and owner is cur user
                    System.debug('Case Follow Up is a chosen tactic');

                    relevantRecords = [select Subject, Id from Case WHERE Days_Closed__c < 7 AND Followup_Complete__c = false LIMIT :maxResults];
                    System.debug('Relevant Records: ' + relevantRecords);
                    for(SObject curItem : relevantRecords){
                        curItem.put('Description','Case recently closed and not followed up');
                        //curItem.put('Subject', curItem.get('Subject'));
                    }
                }
            }
            when 'Priority Messages'  {
                if (curTacticalPlan.Tactical_Ordering__c.split(',').contains('Priority Messages')) {
                    
                    System.debug('Priority Messages is a chosen tactic');
                   // relevantAccounts = [select name, Id from Policy__c WHERE Policy__c.Days_to_Conversion_Credit_Expiration__c	<100 AND Policy__c.Days_to_Conversion_Credit_Expiration__c >0 ORDER BY Policy__c.Days_to_Conversion_Credit_Expiration__c ASC  LIMIT :maxResults];
                }
            }
            when 'Einstein (Renewal Risks)'  {
                if (curTacticalPlan.Tactical_Ordering__c.split(',').contains('Einstein (Renewal Risks)')) {
                    
                    System.debug('Einstein (Renewal Risks) is a chosen tactic');
                   // relevantAccounts = [select name, Id from Policy__c WHERE Policy__c.Days_to_Conversion_Credit_Expiration__c	<100 AND Policy__c.Days_to_Conversion_Credit_Expiration__c >0 ORDER BY Policy__c.Days_to_Conversion_Credit_Expiration__c ASC  LIMIT :maxResults];
                }
            }
            when else {
                System.debug('unsupported value was passed in as tacticName');
            }
        }
        System.debug('Relevant Records: ' + relevantRecords);
        return relevantRecords;
    }

    public static List<Recommendation> GenerateRecommendations (List<SObject> relevantRecords, String tacticName, SalesTacticalPlan__c curTacticalPlan ) {
        List<Recommendation> recs = new List<Recommendation>(); 
        String curName;

        if (relevantRecords != null)
            for (SObject curItem : relevantRecords) {
                if (curItem.getSObjectType().getDescribe().getName() != 'Case' ) {
                    curName = (String)curItem.get('Name');
                }
                else {
                    curName = (String)curItem.get('Subject');
                }
                Recommendation rec = new Recommendation(
                    Name = curName,
                    Description = 'Prioritize ' + curName + '. \n The reason is: ' + (String)curItem.get('Description') ,
                    //Pre-req: Create a screen flow with the name simpleFlow                        
                    ActionReference = 'TacticalFollowup',
                    AcceptanceLabel = 'Go',
                    Tactical_Priority__c = GenerateSalesTacticalPriorities.getPriority(curTacticalPlan.Tactical_Ordering__c, tacticName),
                    ContextRecordId__c = (String)curItem.Id,
                    ContextId__c = (String)curItem.Id
                );
                System.debug('generated recommendation: ' + rec);
                System.debug('contextrecordId is ' + rec.ContextRecordId__c);
                recs.add(rec);
            }
        return recs;
    }
}
