public with sharing class ProcessSalesTactics {
    
    public static List<Opportunity> Process (List<Opportunity> relevantOpportunities, String tacticName, SalesTacticalPlan__c curSalesTacticalPlan, Integer maxResults) {
    
        switch on tacticName {
            when 'Einstein Score'  {
                System.debug('entering Einstein Score');
                if (curSalesTacticalPlan.Tactical_Ordering__c.split(',').contains('Einstein Score')) {
                    System.debug('Einstein Score is a chosen tactic');
                    relevantOpportunities = [select name, Id from Opportunity WHERE Opportunity.Einstein_Score__c != null ORDER BY Opportunity.Einstein_Score__c DESC  LIMIT :maxResults];
                }
            }
            when 'Opportunity Value'  {
                if (curSalesTacticalPlan.Tactical_Ordering__c.split(',').contains('Opportunity Value')) {
                    System.debug('Opportunity is a chosen tactic');
                    relevantOpportunities = [select name, Id from Opportunity WHERE Opportunity.Amount != null ORDER BY Opportunity.Amount DESC  LIMIT :maxResults];
                }
            }
            when 'Proximity to Renewal'  {
                if (curSalesTacticalPlan.Tactical_Ordering__c.split(',').contains('Proximity to Renewal')) {
                    System.debug('Proximity to Renewal is a chosen tactic');
                    //query for opps with the shortest time to CloseDate, limited by the max requested
                    relevantOpportunities = [select name, Id from Opportunity WHERE Opportunity.Days_To_Close__c != null ORDER BY Opportunity.Days_To_Close__c ASC NULLS LAST LIMIT :maxResults];
                }
            }
            when 'Sector Focus'  {
                System.debug('Sector Focus is a chosen tactic');
                List<String> curTactics = curSalesTacticalPlan.Tactical_Ordering__c.split(',');
                if (curTactics.contains('Sector Priority')) {
                    System.debug('ordering contains Sector priority');
                    relevantOpportunities = [select name, Id from Opportunity where Sector__c = :curSalesTacticalPlan.Sector_Name__c LIMIT :maxResults];
                }

            }
            when else {
                System.debug('unsupported value was passed in as tacticName');
            }
        }

        return relevantOpportunities;
    }

    public static List<Recommendation> GenerateRecommendations (List<Opportunity> relevantOpportunities, String tacticName, SalesTacticalPlan__c curSalesTacticalPlan ) {
        List<Recommendation> recs = new List<Recommendation>(); 
        if (relevantOpportunities != null)
            for (Opportunity curOpp:relevantOpportunities) {
                Recommendation rec = new Recommendation(
                    Name = curOpp.Name,
                    Description = 'Work on the ' + curOpp.Name + ' opportunity.' ,
                    //Pre-req: Create a screen flow with the name simpleFlow                        
                    ActionReference = 'TacticalFollowup',
                    AcceptanceLabel = 'Go',
                    Tactical_Priority__c = GenerateSalesTacticalPriorities.getPriority(curSalesTacticalPlan.Tactical_Ordering__c, tacticName)
                );
                System.debug('generated recommendation: ' + rec);
                recs.add(rec);
            }
        return recs;
    }
    
   

}
