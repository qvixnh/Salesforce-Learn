// CMP_CreateStudentCtrl.cls
public class CMP_CreateStudentCtrl {

    @AuraEnabled
    public static String createStudentRec(String  sFirstName, String sLastName, String sClassId, Boolean sGender, String sAddress, Date sBirthdate) {
        try {
            Student__c student = new Student__c();
            student.Name = sFirstName + ' ' + sLastName;
            student.First_Name__c = sFirstName;
            student.Last_Name__c = slastName;
            student.Class__c = sClassId ;
            student.Birthdate__c= sBirthdate;
            student.Gender__c= sGender;
            student.Address__c = sAddress;
            insert student;
            return student.id;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
        
    private static Boolean isStudentOldEnough(Date birthdate) {
        if (birthdate == null) {
            return false;
        }

        // Calculate age
        Date today = Date.today();
        Integer studentAge = today.year() - birthdate.year();

        // Check if the student is at least 17 years old
        if (today.month() < birthdate.month() || (today.month() == birthdate.month() && today.day() < birthdate.day())) {
            studentAge--; // Adjust age if the birthday hasn't occurred yet this year
        }

        return studentAge >= 17;
    }
    @AuraEnabled
    public static List<Class__c>  getClasses(){
        try { 
            return[SELECT 
                    Id
                    , Class_Code__c
                    , Class_Name__c
                    , Number_Of_Student__c 
                    FROM Class__c 
                    ORDER BY Class_Code__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Add additional methods or logic as needed
}
