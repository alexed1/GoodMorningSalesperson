public with sharing class GenerateSalesTacticalPriorities {


    @InvocableMethod
    public static List<List<Recommendation>> Generate(List<Requests> requests) {
        String userId =  requests[0].userId;
        Integer maxResults = requests[0].maxResults;
        String salesTacticalPlanName = requests[0].salesTacticalPlanName;
        String tacticName = requests[0].tacticName;
        String planType = requests[0].planType;
        List<Recommendation> recs = new List<Recommendation>(); 
        System.debug('entering Generate Sales TacticalPriorities');
        System.debug('cur values are: ' +tacticName + ' ' + maxResults + ' ' + userId);
        //1) read in the SalesPriorityPlan
        //2) Find all opportunities where the criteria type’s value exceeds the threshold
        //3) Generate recommendations  (unless the value of the criteria is 0) and set the TacticalPriority

        SalesTacticalPlan__c curSalesTacticalPlan = [select name, Id,Sector_Name__c, Tactical_Ordering__c, Plan_Type__c	 from SalesTacticalPlan__c where name = :salesTacticalPlanName];
        System.debug('returned tactical plan is: ' + curSalesTacticalPlan);
        List<Opportunity> relevantOpportunities = new List<Opportunity>();
        List<Policy__c> relevantPolicies = new List<Policy__c>();
        List<SObject> relevantRecords = new List<SObject>();

        switch on planType {
            when 'OpportunitySelling' {
                //relevantOpportunities = ProcessPolicyTactics.Process(relevantOpportunities, tacticName, curSalesTacticalPlan, maxResults);
                //recs = ProcessPolicyTactics.GenerateRecommendations(relevantOpportunities, tacticName,  curSalesTacticalPlan);
            }
            when 'InsurancePolicies' {
                relevantPolicies = ProcessPolicyTactics.Process(tacticName, curSalesTacticalPlan, maxResults);
                recs = ProcessPolicyTactics.GenerateRecommendations(relevantPolicies, tacticName,  curSalesTacticalPlan);
            }
            when 'Service' {
                relevantRecords = ProcessServiceTactics.Process(tacticName, curSalesTacticalPlan, maxResults);
                recs = ProcessServiceTactics.GenerateRecommendations(relevantRecords, tacticName,  curSalesTacticalPlan);
            }
            when else {
                System.debug('unsupported value was passed in as planType');
                throw new InvocableActionException ('unsupported value was passed in as planType');
                }
        }
        
        System.debug('relevantOpportunities are: ' + relevantOpportunities);

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


  


    public class Requests {

        @InvocableVariable
        public String userId;

        @InvocableVariable
        public String tacticName;

        @InvocableVariable
        public String salesTacticalPlanName;

        @InvocableVariable
        public Integer maxResults;

        @InvocableVariable
        public String planType;	

    }

    public class Results {

        @InvocableVariable
        public List<List<Recommendation>> curRecs;

    }

     public class InvocableActionException extends Exception {}


}

