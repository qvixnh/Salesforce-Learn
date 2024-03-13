public with sharing class mockData {
    @AuraEnabled
    public static String genStudents(List<Class__c > classL){
        try {
            List<String> firstL = new List<String>{'Vĩnh', 'Bách', 'Đức', 'Duy', 'Vũ', 'Tài', 'Kiệt', 'Phúc', 'Nhung', 'Lan', 'Lam', 'Trung', 'Hiếu'};
            List<String> lastL = new List<String>{'Nguyễn', 'Trần', 'Lê', 'Tào', 'Lương', 'Đỗ', 'Trương'};
            List<String> addressL = new List<String>{'An Giang', 'HCM', 'Bình Thuận', 'Bạc Liêu', 'Bắc Giang', 'Kiên Giang', 'Tiền Giang', 'Lâm Đồng', 'Đồng Tháp', 'Phú Yên', 'Gia Lai', 'Huế', 'Hà Nội'};
            List<Boolean> genderL = new List<Boolean>{true,false};
            List<Student__c> recordsToInsert = new List<Student__c>();
            for(Integer i = 0; i < 10; i++) {
                Student__c record = new Student__c();
                record.Firstname__c = firstL[getRandomNumber(firstL.size())];
                record.Lastname__c = lastL[getRandomNumber(lastL.size())];
                record.Address__c = addressL[getRandomNumber(addressL.size())];
                record.Class_look__c = classL[getRandomNumber(classL.size())].Id;
                record.Gender__c = genderL[getRandomNumber(genderL.size())];
                record.Name = record.Firstname__c + ' ' + record.Lastname__c;
                record.TotalCredit__c = 0;
                record.GPAScore__c = 0;
                record.Birthday__c = Date.valueOf('2000-01-01');
                recordsToInsert.add(record);
            }
            insert recordsToInsert;
            return 'success';
        } catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }
    static Integer getRandomNumber(Integer listSize){
        listSize = listSize - 1;
        Integer ranNumber = Integer.valueof(Math.random() * listSize);
        return ranNumber;
    } 
    
    public  class  CustomException extends Exception {
        
    }
}