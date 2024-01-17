public class StudentTriggerHandler {
    public static void afterInsert(List<Student__c> students) {
        Set<Id> classIds = new Set<Id>();
        for (Student__c student : students) {
            classIds.add(student.Class__c);
            
        }

        List<Class__c> classesToUpdate = [SELECT Id, Number_Of_Student__c FROM Class__c WHERE Id IN :classIds];
        List<Class__c> classesToUpdateList = new List<Class__c>();
        for (Class__c cls : classesToUpdate) {
            Integer numberOfStudents = cls.Number_Of_Student__c != null ? cls.Number_Of_Student__c.intValue() : 0;
            for (Student__c student : students) {
                if (student.Class__c == cls.Id) {
                    numberOfStudents++;
                }
            }
            cls.Number_Of_Student__c = Decimal.valueOf(numberOfStudents); // Convert back to Decimal if necessary
            classesToUpdateList.add(cls);
        }
        if (!classesToUpdateList.isEmpty()) {
            update classesToUpdateList;
        }
    }
    public static void afterDelete(List<Student__c> students) {
        Set<Id> classIds = new Set<Id>();
        for (Student__c student : students) {
            classIds.add(student.Class__c);
        }
        System.debug(students);
        System.debug(classIds);
        // List<Class__c> classesToUpdate = [SELECT Id, Number_Of_Student__c FROM Class__c WHERE Id IN :classIds];
        // List<Class__c> classesToUpdateList = new List<Class__c>();
        // for (Class__c cls : classesToUpdate) {
        //     Integer numberOfStudents = cls.Number_Of_Student__c != null ? cls.Number_Of_Student__c.intValue() : 0;
        //     for (Student__c student : students) {
        //         if (student.Class__c == cls.Id) {
        //             numberOfStudents--;
        //         }
        //     }
        //     cls.Number_Of_Student__c = Decimal.valueOf(numberOfStudents); // Convert back to Decimal if necessary
        //     classesToUpdateList.add(cls);
        // }
        // if (!classesToUpdateList.isEmpty()) {
        //     update classesToUpdateList;
        // }
    }
    public static void afterUpdate(List<Student__c> oldStudents, List<Student__c> newStudents) {
        // Set<Id> oldClassIds = new Set<Id>();
        // for (Student__c student : oldStudents) {
        //     oldClassIds.add(student.Class__c);
        // }
        // for (Student__c student : oldStudents) {
        //     oldClassIds.add(student.Class__c);
        // }
        // List<Class__c> classesToUpdate = [SELECT Id, Number_Of_Student__c FROM Class__c WHERE Id IN :oldClassIds];
        // List<Class__c> classesToUpdateList = new List<Class__c>();
        // for (Class__c cls : classesToUpdate) {
        //     Integer numberOfStudents = cls.Number_Of_Student__c != null ? cls.Number_Of_Student__c.intValue() : 0;
        //     for (Student__c student : oldStudents) {
        //         if (student.Class__c == cls.Id) {
        //             numberOfStudents++;
        //         }
        //     }
        //     cls.Number_Of_Student__c = Decimal.valueOf(numberOfStudents);
        //     classesToUpdateList.add(cls);
        // }
        // if (!classesToUpdateList.isEmpty()) {
        //     update classesToUpdateList;
        // }
    }

}
