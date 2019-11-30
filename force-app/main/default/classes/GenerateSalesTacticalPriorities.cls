public with sharing class GenerateSalesTacticalPriorities {


    @InvocableMethod
    public static List<List<Recommendation>> Generate(List<Requests> requests) {
        String userId = requests[0].userId;
        Integer maxResults = requests[0].maxResults;
        String salesTacticalPlanName = requests[0].salesTacticalPlanName;
        String tacticName = requests[0].tacticName;
        System.debug('entering Generate Sales TacticalPriorities');
        System.debug('cur values are: ' +tacticName + ' ' + maxResults + ' ' + userId);
        //1) read in the SalesPriorityPlan
        //2) Find all opportunities where the criteria type’s value exceeds the threshold
        //3) Generate recommendations  (unless the value of the criteria is 0) and set the TacticalPriority

        SalesTacticalPlan__c curSalesTacticalPlan = [select name, Id,Sector_Name__c, Tactical_Ordering__c,Minimum_Opportunity_Value__c	,Minimum_Score__c	 from SalesTacticalPlan__c where name = :salesTacticalPlanName];
        System.debug('returned tactical plan is: ' + curSalesTacticalPlan);
        List<Opportunity> relevantOpportunities;

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
        System.debug('relevantOpportunities are: ' + relevantOpportunities);
            
        List<Recommendation> recs = new List<Recommendation>(); 
        if (relevantOpportunities != null)
            for (Opportunity curOpp:relevantOpportunities) {
                Recommendation rec = new Recommendation(
                    Name = curOpp.Name,
                    Description = 'Work on the ' + curOpp.Name + ' opportunity.' ,
                    //Pre-req: Create a screen flow with the name simpleFlow                        
                    ActionReference = 'TacticalFollowup',
                    AcceptanceLabel = 'Go',
                    Tactical_Priority__c = getPriority(curSalesTacticalPlan.Tactical_Ordering__c, tacticName)
                );
                System.debug('generated recommendation: ' + rec);
                recs.add(rec);
            }

              //Create a Results object to hold the return values
        List<List<Recommendation>> response = new List<List<Recommendation>>();


        //add the return values to the Results object
        response.add(recs);
        System.debug('response is: '+ response);
        return response; 

    }

    //the dual list box works with comma-separated strings. locate the priority of the current tactic
    public static Integer getPriority(String orderingString, String tacticName) {
        //break the string into an array
        //find the name in the array
        //return the index+1. return 0 if not found
        List<String> orderedTactics = orderingString.split(',');
        Integer index = orderedTactics.indexOf(tacticName);
        return index+1;

    }


    public class InvocableActionException extends Exception {
    }


    public class Requests {

        @InvocableVariable
        public String userId;

        @InvocableVariable
        public String tacticName;

        @InvocableVariable
        public String salesTacticalPlanName;

        @InvocableVariable
        public Integer maxResults;
    }

    public class Results {

        @InvocableVariable
        public List<List<Recommendation>> curRecs;

    }

}

