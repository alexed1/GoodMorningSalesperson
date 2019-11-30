//expects a List of Recommendations. It will compare the Names of the Recommendations. 
//when it finds a duplicate, it enhances it with a property called Duplicate set to True
public with sharing class MarkDuplicates {


    @InvocableMethod
    public static List<List<Recommendation>> Mark(List<Requests> requests) {
        List<Recommendation> inputrecs = requests[0].inputRecs;
         
        System.debug('entering Mark Duplicates');
        List<Recommendation> processedRecs = new List<Recommendation>();

        for  (Recommendation currentRec:inputRecs){
            //if it shares the name of a processedRec, set its Duplicate flag
            for (Recommendation processedRec:processedRecs) {
                if (currentRec.Name == processedRec.Name){
                    System.debug('currentRec and processedRec match on name: ' + currentRec.Name);
                    currentRec.DuplicateText__c = 'true';
                }
            }
            //put it in the processedRecs list
            processedRecs.add(currentRec);
        }

              //Create a Results object to hold the return values
        List<List<Recommendation>> response = new List<List<Recommendation>>();


        //add the return values to the Results object
        response.add(processedRecs);
        System.debug('response is: '+ response);
        return response; 

    }


    public class InvocableActionException extends Exception {
    }


    public class Requests {

        @InvocableVariable
        public List<Recommendation> inputRecs;

        
    }

    public class Results {

        @InvocableVariable
        public List<List<Recommendation>> outputRecs;

    }

}

