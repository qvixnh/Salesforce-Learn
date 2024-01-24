/**
 * クラス名：   VF_SearchStudentCtrl.cls
 * クラス概要： Search Student Controller
 * @created： 2023/12/15 + Nguyen Vinh
 * @modified: 
 */
public with sharing class VF_SearchStudentCtrl {
    public String searchName { get; set; }
    public String searchCode { get; set; }
    public Integer gender {get;set;}
    public String searchSelectedClass {get;set;}
    public List<Student__c> searchResults { get; set; }
    public List<SelectOption> classList { get; set; }
    public List<SelectOption> classListCreate { get; set; }
    public Date birthdate { get; set; }
    public Integer day {get;set;}
    public List<SelectOption> dayOptions { get; set; }
    public List<SelectOption> monthOptions { get; set; }
    public Integer month {get;set;}
    public Integer year {get;set;}
    public Student__c student {get;set;}
    public Student__c studentToCreate {get;set;}

    public String selectedId {get;set;}
    public Map<Integer,List<Student__c>> recordsByPages { get; set; }
    public Integer pageSize { get; set; }
    public Integer startIndex { get; set; }
    public Integer totalRecords { get; set; }
    public Integer currentPage { get; set; }
    public Integer totalPages { get; set; }
    public List<Integer> pageNumbers {
        get {
            pageNumbers = new List<Integer>();
            Integer startPage = Math.max(1, currentPage - 1);
            Integer endPage = Math.min(totalPages, startPage + 2);
            for (Integer i = startPage; i <= endPage; i++) {
                pageNumbers.add(i);
            }
            return pageNumbers;
        }
        private set;
    }

    public Map<Id, Boolean> selectedIds { get; set; }
    public Integer selectedRecordsNumber { get; set; }
    public Boolean allSelected { get; set; }
    public VF_SearchStudentCtrl() {
        day= 0;
        dayOptions = new List<SelectOption>();
        dayOptions.add(new SelectOption('0', 'All'));
        for (Integer i = 1; i <= 31; i++) {
            String label = (i < 10) ? '0' + String.valueOf(i) : String.valueOf(i);
            dayOptions.add(new SelectOption(String.valueOf(i), label));
        }
        monthOptions = new List<SelectOption>();
        monthOptions.add(new SelectOption('0', 'All'));
        monthOptions.add(new SelectOption('1', 'January'));
        monthOptions.add(new SelectOption('2', 'February'));
        monthOptions.add(new SelectOption('3', 'March'));
        monthOptions.add(new SelectOption('4', 'April'));
        monthOptions.add(new SelectOption('5', 'May'));
        monthOptions.add(new SelectOption('6', 'June'));
        monthOptions.add(new SelectOption('7', 'July'));
        monthOptions.add(new SelectOption('8', 'August'));
        monthOptions.add(new SelectOption('9', 'September'));
        monthOptions.add(new SelectOption('10', 'October'));
        monthOptions.add(new SelectOption('11', 'November'));
        monthOptions.add(new SelectOption('12', 'December'));
        month = 0;
        selectedRecordsNumber = 0;
        pageSize = 10;
        startIndex = 0;
        currentPage = 1;
        this.studentToCreate= new Student__c();
        this.student = new Student__c();
        searchResults = [SELECT Id
                                , StudentCode__c
                                , Firstname__c
                                , Lastname__c
                                , selected__c,Class_look__r.Name
                                , Gender__c
                                , Birthday__c
                                , Address__c 
                        FROM Student__C] ;
        classList = getClassOptions();
        classListCreate = getClassOptionsCreate();
        selectedIds = new Map<Id, Boolean>();
        allSelected = false;
        for (Student__c student : [SELECT Id FROM Student__c]) {
            selectedIds.put(student.Id, false);
        }
        performPagination();
        
    }

    /**
     * performSearch
     * @param    : 
     * @return   :  
     * @created  : 2023/12/15 + Nguyen Vinh
     * @modified : 2023/12/18 + Nguyen Vinh
     */
    public void performSearch() {
        try {
            List<String> conditions = new List<String>();
    
            List<String> selectedFields = new List<String>{
                'Id', 'StudentCode__c', 'Firstname__c', 'Lastname__c', 'selected__c',
                'Class_look__r.Name', 'Gender__c', 'Birthday__c', 'Address__c'
            };
            String queryString = 'SELECT ' + String.join(selectedFields, ', ') + ' FROM Student__c';
            if (!String.isBlank(searchName)) {
                conditions.add('Firstname__c LIKE \'%' + searchName + '%\'');
            }
            if (!String.isBlank(searchCode)) {
                conditions.add('StudentCode__c LIKE \'%' + searchCode + '%\'');
            }
            if (searchSelectedClass != '1') {
                conditions.add('Class__c = \'' + searchSelectedClass + '\'');
            }
            if (gender == 1 || gender == 0) {
                conditions.add('Gender__c = ' + (gender == 1 ? 'True' : 'False'));
            }
            if (birthdate != null) {
                String formattedDate = birthdate.year() + '-' + pad(birthdate.month()) + '-' + pad(birthdate.day());
                conditions.add('Birthday__c = ' + formattedDate);
            }
            if (day > 0) {
                conditions.add('DAY_IN_MONTH(Birthday__c) = ' + day);
            }
            if (month > 0) {
                conditions.add('CALENDAR_MONTH(Birthday__c) = ' + month);
            }
            if (year > 0) {
                conditions.add('CALENDAR_YEAR(Birthday__c) = ' + year);
            }
            queryString += !conditions.isEmpty() ? ' WHERE ' + String.join(conditions, ' AND ') + ' ORDER BY StudentCode__c' : ' ORDER BY StudentCode__c';
            searchResults = Database.query(queryString);
        } catch (Exception e) {
            System.debug(e);
        }
        performPagination();
    }
    /**
     * performPagination
     * @param    : 
     * @return   :  
     * @created  : 2023/12/21+ Nguyen Vinh
     * @modified : 2023/12/18 + Nguyen Vinh
     */
    private void performPagination() {
        totalRecords = searchResults.size();
        totalPages = (totalRecords + pageSize - 1) / pageSize;
        startIndex = 0;
        currentPage = 1;
        this.recordsByPages = new Map<Integer, List<Student__c>>();
        for (Integer i = 0; i < totalPages; i++) {
            List<Student__c> pageList = new List<Student__c>();
            for (Integer j = pageSize * i; j < Math.min(pageSize * (i + 1), searchResults.size()); j++) {
                pageList.add(searchResults[j]);
            }
            this.recordsByPages.put(i + 1, pageList);
        }
    }
    /**
     * clearFilters
     * @param    : 
     * @return   :  PageReference
     * @created  : 2023/12/15 + Nguyen Vinh
     * @modified : 
     */
    public PageReference clearFilters() {
        searchCode = null;
        searchName = null;
        searchSelectedClass = null;
        gender = null;
        day = 0;
        month = 0;
        year = null;
        birthdate = null;
        return null;
    }
    /**
     * pad
     * @param    : Integer value
     * @return   :  String
     * @created  : 2023/12/21 + Nguyen Vinh
     * @modified : 
     */
    private String pad(Integer value) {
        return String.valueOf(value).leftPad(2, '0');
    }
    /**
     * getClassOptions
     * @param    : 
     * @return   : List<SelectOption>
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public  List<SelectOption> getClassOptions() {
        List<SelectOption> options = new List<SelectOption>();
        List<Class__c> classes = [SELECT Id, Name FROM Class__c];
        options.add(new SelectOption('1', 'all'));
        for (Class__c cls : classes) {
            options.add(new SelectOption(cls.Id, cls.Name));
        }
        return options;
    }
     /**
     * getClassOptionsCreate
     * @param    : 
     * @return   : List<SelectOption>
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public  List<SelectOption> getClassOptionsCreate() {
        List<SelectOption> options = new List<SelectOption>();
        List<Class__c> classes = [
            SELECT 
                Id
                , Name 
            FROM Class__c
        ];
        for (Class__c cls : classes) {
            options.add(new SelectOption(cls.Id, cls.Name));
        }
        return options;
    }
      /**
     * createStudent
     * @param    : 
     * @return   : 
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public void createStudent() {
        try {
                this.studentToCreate.Name = studentToCreate.Firstname__c.left(39) + ' ' + studentToCreate.Lastname__c.left(39);
                insert studentToCreate;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Student created successfully.'));
                selectedIds.put(student.Id, false);
                this.studentToCreate = new Student__c();
                searchResults = new List<Student__c>();
                performSearch();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating student: ' + e.getMessage()));
            System.debug('Exception Details: ' + e);
        }
    }
    /**
     * updateStudent
     * @param    : 
     * @return   : 
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public PageReference updateStudent() {
        try {
            this.student.Name = student.Firstname__c.left(39) + ' ' + student.Lastname__c.left(39);
            update student;
            this.student=new Student__c();
            searchResults = new List<Student__c>();
            performSearch();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Student updated successfully.'));
            return null;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating student: ' + e.getMessage()));
            System.debug('Exception Details: ' + e);
            return null;
        }
    }
    public void deleteStudent() {
        try {
            if (String.isNotBlank(selectedId)) {
                Student__c studentToDelete = [SELECT Id FROM Student__c WHERE Id = :selectedId ];
                if (studentToDelete != null) {
                    delete studentToDelete;
                    selectedId = '';
                    this.student=new Student__c();
                    searchResults = new List<Student__c>();
                    performSearch();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Student deleted successfully.'));
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected student not found.'));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No student selected for deletion.'));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error deleting student: ' + e.getMessage()));
            System.debug('Exception Details: ' + e);
        }
    }
      /**
     * deleteSelectedRecords
     * @param    : 
     * @return   : 
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public void deleteSelectedRecords() {
        List<Id> selectedRecordIds = new List<Id>();
        for (Id recordId : selectedIds.keySet()) {
            if (selectedIds.get(recordId)) {
                selectedRecordIds.add(recordId);
            }
        }
        if (!selectedRecordIds.isEmpty()) {
            try {
                List<Student__c> studentsToDelete = [SELECT Id FROM Student__c WHERE Id IN :selectedRecordIds];
                List<Id> keysToRemove = new List<Id>();
                for (Id studentId : selectedIds.keySet()) {
                    Boolean checked = selectedIds.get(studentId);
                    if (checked == true) {
                        keysToRemove.add(studentId);
                    }
                }
                for (Id key : keysToRemove) {
                    selectedIds.remove(key);
                }
                delete studentsToDelete;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Selected records deleted successfully.'));
                performSearch();
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error deleting records: ' + e.getMessage()));
                System.debug('Exception Details: ' + e);
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records selected for deletion.'));
        }
    }
     /**
     * previous
     * @param    : 
     * @return   : PageReference
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public PageReference previous() {
        startIndex -= pageSize;
        currentPage--;
        this.allSelected=false;
        updateSelectedRecordsNumder();
        return null;
    }
    /**     
     * next
     * @param    : 
     * @return   : PageReference
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public PageReference next() {
        startIndex += pageSize;
        currentPage++;
        this.allSelected=false;
        updateSelectedRecordsNumder();
        return null; 
    }
     /**     
     * first
     * @param    : 
     * @return   : PageReference
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public PageReference first() {
        startIndex = 0;
        currentPage = 1;
        this.allSelected=false;
        updateSelectedRecordsNumder();
        return null; 
    }
     /**     
     * last
     * @param    : 
     * @return   : PageReference
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public PageReference last() {
        if(totalRecords ==0){
            
            return null;
        }
        else{
            Integer remainder = Math.mod(totalRecords, pageSize);
            startIndex = totalRecords - remainder;
            if (remainder == 0) {
                startIndex -= pageSize;
            }
            
            currentPage = totalPages;
            this.allSelected=false;
            updateSelectedRecordsNumder();
            return null; 
        }    
    }
     /**     
     * gotoPage
     * @param    : 
     * @return   : PageReference
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public PageReference gotoPage() {
        startIndex = (currentPage - 1) * pageSize;
        this.allSelected=false;
        updateSelectedRecordsNumder();
        return null;
    }
    /**     
     * selectAllCheckboxesTable
     * @param    : 
     * @return   : 
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public void selectAllCheckboxesTable() {
        Integer count = 0;
        List<Student__c> selectPageList = recordsByPages.containsKey(currentPage) ? recordsByPages.get(currentPage) : new List<Student__c>();
        for (Student__c student : selectPageList) {
            selectedIds.put(student.Id, allSelected);
        }
        updateSelectedRecordsNumder();
    }
    
    /**     
     * setStudent
     * @param    : 
     * @return   : 
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public void setStudent() {
        if (selectedId == '') {
            this.student = new Student__c();
        } else {
            this.student = [
                SELECT 
                    Id
                    , StudentCode__c
                    , Firstname__c
                    , Lastname__c
                    , Class_look__r.Name
                    , Gender__c
                    , Birthday__c
                    , Address__c
                FROM Student__c
                WHERE Id = :selectedId
            ];
        }
    }
    public Boolean getHasPrevious() {
        return startIndex - pageSize >= 0;
    }

    public Boolean getHasNext() {
        return startIndex + pageSize < totalRecords;
    }

     /**     
     * clearRecords
     * @param    : 
     * @return   : 
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public void clearRecords() {
        allSelected = false;
        for (Id recordId : selectedIds.keySet()) {
            selectedIds.put(recordId, false);
        }
        this.selectedRecordsNumber=0;

    }
     /**     
     * updateSelectedRecordsNumder
     * @param    : 
     * @return   : 
     * @created  : 2023/12/22 + Nguyen Vinh
     * @modified : 
     */
    public void updateSelectedRecordsNumder(){
        Integer count =0;
        for (Boolean checked : selectedIds.values()) {
            if(checked==true){
                count++;
            }
        }
        
        this.selectedRecordsNumber=count;
        updateSelectAll();
    }
    /**     
     * updateSelectAll
     * @param    : 
     * @return   : 
     * @created  : 2023/1/19 + Nguyen Vinh
     * @modified : 
     */
    public void updateSelectAll(){
        Integer count = 0;
        for (Integer i=startIndex;i<startIndex+pageSize;i++) {
            if(this.selectedIds.get(this.searchResults[i].Id)){
                count++;
            }
        }
        if(count==this.pageSize){
            this.allSelected=true;
        }else{
            this.allSelected=false;
            
        }
    }

}