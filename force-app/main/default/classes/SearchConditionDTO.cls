public class SearchConditionDTO {
    public SearchConditionDTO() {

    }
    @AuraEnabled
    public String classId;
    
    @AuraEnabled
    public Integer gender;
    
    @AuraEnabled
    public String searchName;
    
    @AuraEnabled
    public String searchCode;
    
    @AuraEnabled
    public Integer day;
    
    @AuraEnabled
    public Integer month;
    
    @AuraEnabled
    public Integer year;
    
    @AuraEnabled
    public String birthdate;
    
    @AuraEnabled
    public String orderField;
    
    @AuraEnabled
    public String orderType;
}