/**
 * クラス名：   B00_CreateStudent.cls
 * クラス概要： B00 Create Student
 * @created： 2023/01/24 + Nguyen Vinh
 * @modified:
 */
public with sharing class B00_CreateStudent {
    private static final String BATCHNAME = 'B01_科目得点削除バッチ';
    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    private static final String BATCH_SUCCESS = 'Batch run successfully';
    private BatchLog__c batchLogObj = new BatchLog__c();
    /**
     * start
     * @param    : Database.BatchableContext BC
     * @return   : Database.QueryLocator
     * @created  : 2023/01/24 + Nguyen Vinh
     * @modified : 2023/01/25 + Nguyen Vinh
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
    }
    public void execute(Database.BatchableContext BC) {
        List<Student__c> recordsToInsert = new List<Student__c>();
        for(Integer i = 0; i < 70; i++) {
            Student__c record = new Student__c();
            record.Firstname__c = getRandomFirstName();
            record.Lastname__c = getRandomLastName();
            record.Name = record.Firstname__c + ' ' + record.Lastname__c;
            record.TotalCredit__c = 0;
            record.GPAScore__c = 0;
            record.Class_look__c = getRandomClass().Id;
            record.Gender__c = getRandomGender();
            record.Birthday__c = Date.valueOf('2000-01-01');
            record.Address__c = getRandomAddress();
            
            recordsToInsert.add(record);
        }

        insert recordsToInsert;
    }
    
    // Helper methods to generate random data
    private static String getRandomFirstName() {
        List<String> strList = new List<String>{'Vĩnh', 'Bách', 'Đức', 'Duy', 'Vũ', 'Tài', 'Kiệt', 'Phúc', 'Nhung', 'Lan', 'Lam', 'Trung', 'Hiếu'};
        Integer ranNumber = (Integer) Math.floor(Math.random() * strList.size());
        return (String)strList[ranNumber];
    }

    private static String getRandomLastName() {
        List<String> strList = new List<String>{'Nguyễn', 'Trần', 'Lê', 'Tào', 'Lương', 'Đỗ', 'Trương'};
        Integer ranNumber = (Integer) Math.floor(Math.random() * strList.size());
        return (String)strList[ranNumber];
    }
    private static String getRandomAddress() {
        List<String> strList = new List<String>{'An Giang', 'HCM', 'Bình Thuận', 'Bạc Liêu', 'Bắc Giang', 'Kiên Giang', 'Tiền Giang', 'Lâm Đồng', 'Đồng Tháp', 'Phú Yên', 'Gia Lai', 'Huế', 'Hà Nội'};
        Integer ranNumber = (Integer) Math.floor(Math.random() * strList.size());
        return (String)strList[ranNumber];
    }
    private static Class__c getRandomClass() {
        List<Class__c> classes = [SELECT 
                                Id
                                , Name
                                , NumberOfStudent__c
                                , Falcuty__c
                            FROM Class__c 
                            ORDER BY Name ];
        Integer ranNumber = (Integer) Math.floor(Math.random() * classes.size());
        return classes[ranNumber];
    }

    private static Boolean getRandomGender() {
        return Math.random() < 0.5; // 50% chance for true/false
    }

}