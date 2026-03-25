@isTest
/**
 * Tiny class for testing performance in unit tests. Designed to facilitate A/B testing of different approaches
 */
public class Benchmarker {

    //Defaults set to 0 in case we don't have a test.startTest()
    private static Integer initialHeapSize = 0;
    private static Integer initialQueries = 0;
    private static Integer initialCpuTime = 0;
    private static Integer initialDmlStatements = 0;

    private static Integer finalHeapSize;
    private static Integer finalQueries;
    private static Integer finalCpuTime;
    private static Integer finalDmlStatements;

    /**
     * If possible, invoke this just after Test.startTest() to capture initial values.
     */
    public static void start(){
        initialHeapSize = Limits.getHeapSize();
        initialQueries = Limits.getQueries();
        initialCpuTime = Limits.getCpuTime();
        initialDmlStatements = Limits.getDmlStatements();
    }

    /**
     * Debugs (to LoggingLevel.DEBUG) certain numbers from the Limits class
     * @param methodName (String): The name of the method under test; This name is added to the debug log
     */
    public static void mark(String methodName){
        finalHeapSize = Limits.getHeapSize();
        finalQueries = Limits.getQueries();
        finalCpuTime = Limits.getCpuTime();
        finalDmlStatements = Limits.getDmlStatements();
        List<String> messages = new List<String>{
            'Benchmarker:methodName: ' + methodName,
                'Benchmarker:Heap: ' + (finalHeapSize - initialHeapSize),
                'Benchmarker:Queries: ' + (finalQueries - initialQueries),
                'Benchmarker:CpuTime: ' + (finalCpuTime - initialCpuTime),
                'Benchmarker:DmlStatements: ' + (finalDmlStatements - initialDmlStatements)
        };
        System.debug(LoggingLevel.DEBUG, String.join(messages, '\n'));
    }
}