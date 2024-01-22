public class StudentTriggerHandler {
    public static void afterInsert(List<Student__c> students) {
        Set<Id> classIds = new Set<Id>();
        for (Student__c student : students) {
            classIds.add(student.Class__c);
        }
        List<Class__c> classesToUpdate = [SELECT Id, NumberOfStudent__c FROM Class__c WHERE Id IN :classIds];
        List<Class__c> classesToUpdateList = new List<Class__c>();
        for (Class__c cls : classesToUpdate) {
            Integer numberOfStudents = cls.NumberOfStudent__c != null ? cls.NumberOfStudent__c.intValue() : 0;
            for (Student__c student : students) {
                if (student.Class__c == cls.Id) {
                    numberOfStudents++;
                }
            }
            cls.NumberOfStudent__c = Decimal.valueOf(numberOfStudents);
            classesToUpdateList.add(cls);
        }
        if (!classesToUpdateList.isEmpty()) {
            update classesToUpdateList;
        }
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for (Student__c student : students) {
            if (String.isNotBlank(student.Address__c)) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { student.Address__c });
                email.setSubject('Welcome to Our School!');
                email.setPlainTextBody('Dear ' + student.Name + ',\n\n' +
                                        'Welcome to our school! Thank you for joining.\n\n' +
                                        'Best regards,\nSchool Administration');

                // Add the email message to the list
                emailList.add(email);
            }
        }

        // Send the emails asynchronously
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }
    public static void afterDelete(List<Student__c> students) {
        Set<Id> classIds = new Set<Id>();
        for (Student__c student : students) {
            classIds.add(student.Class__c);
        }
        try {
            List<Class__c> classesToUpdate = [SELECT Id, NumberOfStudent__c FROM Class__c WHERE Id IN :classIds];
            List<Class__c> classesToUpdateList = new List<Class__c>();
            for (Class__c cls : classesToUpdate) {
                Integer numberOfStudents = cls.NumberOfStudent__c != null ? cls.NumberOfStudent__c.intValue() : 0;
                for (Student__c student : students) {
                    if (student.Class__c == cls.Id) {
                        numberOfStudents--;
                    }
                }
                cls.NumberOfStudent__c = Decimal.valueOf(numberOfStudents); 
                classesToUpdateList.add(cls);
            }
            if (!classesToUpdateList.isEmpty()) {
                update classesToUpdateList;
            }    
        } catch (Exception e) {
            System.debug(e);
        }
        
    }
    public static void afterUpdate(List<Student__c> oldStudents, List<Student__c> newStudents) {
        afterInsert(newStudents);
        afterDelete(oldStudents);
    }

}