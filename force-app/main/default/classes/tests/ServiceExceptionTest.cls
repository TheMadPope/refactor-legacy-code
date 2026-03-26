@IsTest
public class ServiceExceptionTest {
    @IsTest
    private static void test(){
        boolean exceptionThrown = false;

        Test.startTest();
        try{
            throw new ServiceException('Test');
        }catch(ServiceException e)
        {
            exceptionThrown = true;
        }
        ServiceException.test();
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Exception should be thrown');
    }
}