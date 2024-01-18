public with sharing class VF_SearchStudentCtrl {
    //validation Error
    public String firstNameError{get;set;}
    public String lastNameError{get;set;}
    public String birthdateError{get;set;}
    public String addressError{get;set;}

    public String searchName { get; set; }
    public String searchCode { get; set; }
    public Boolean searchMale { get; set; }
    public String searchType { get; set; }
    public Integer gender {get;set;}
    public String searchSelectedClass {get;set;}
    public List<Student__c> searchResults { get; set; }
    public List<SelectOption> classList { get; set; }
    public List<SelectOption> classListCreate { get; set; }
    public String searchMessage{get;set;}
    public Date birthdate { get; set; }
    public Integer day {get;set;}
    public List<SelectOption> dayOptions { get; set; }
    public List<SelectOption> monthOptions { get; set; }

    public Integer month {get;set;}
    public Integer year {get;set;}

    public Student__c student {get;set;}
    public Student__c selectedStudent {get;set;}
    public String selectedId {get;set;}
    //PAGINATION HANDLE
        public Map<Integer,List<Student__c>> recordsByPages { get; set; }
        public Integer pageSize { get; set; }
        public Integer startIndex { get; set; }
        public Integer totalRecords { get; set; }
        public Integer currentPage { get; set; }
        public Integer totalPages { get; set; }
        //pagenumber handling
        // List to store page numbers based on total pages and current page
        public List<Integer> pageNumbers {
            get {
                pageNumbers = new List<Integer>();
                
                // Calculate the start and end page numbers to display
                Integer startPage = Math.max(1, currentPage - 1);
                Integer endPage = Math.min(totalPages, startPage + 2);
                // Populate the list with page numbers to display
                for (Integer i = startPage; i <= endPage; i++) {
                    pageNumbers.add(i);
                }
                return pageNumbers;
            }
            private set;
        }

        // NEW METHOD: Handle navigation to a specific page
        public PageReference gotoPage() {
            // Calculate the start index for the selected page
            startIndex = (currentPage - 1) * pageSize;

            // Return null to stay on the same page and rerender the results
            return null;
        }
        
    //PAGINATION END
    
    //SELECT RECORDS HANDLE - ATTRIBUTE 
    public Map<Id, Boolean> selectedIds { get; set; }
    public Integer selectedRecordsNumber { get; set; }
    public Boolean allSelected { get; set; }

    // Search by Birthday range
    public Date startDate { get; set; }
    public Date endDate { get; set; }
    
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

        // Set a default value for month
        month = 0;
        selectedRecordsNumber = 0;
        //PAGINATION START
        pageSize = 10;
        // Initialize startIndex
        startIndex = 0;
        // Initialize currentPage
        currentPage = 1;
        //PAGINATION END
        this.student = new Student__c();
        searchResults = new List<Student__c>();
        classList = getClassOptions();
        classListCreate = getClassOptionsCreate();

        // Initialize selectedIds map
        selectedIds = new Map<Id, Boolean>();
        allSelected = false;
        // Populate selectedIds with all student IDs
        for (Student__c student : [SELECT Id FROM Student__c]) {
            selectedIds.put(student.Id, false);
        }
        performSearch();
        
    }

    
    public void performSearch() {

        String queryString = 'SELECT Id';
        queryString += ', Student_Code__c';
        queryString +=', First_Name__c';
        queryString +=', Last_Name__c';
        queryString +=', Class__r.Class_Name__c';
        queryString +=', Gender__c';
        queryString +=', Birthdate__c';
        queryString +=', Address__c';
        queryString += ' FROM Student__c';
        queryString += ' WHERE First_Name__c LIKE \'%' + searchName + '%\'';
        queryString += ' AND Student_Code__c LIKE \'%' + searchCode + '%\'';
        searchMessage+=' /Name: '+searchName;
        searchMessage+=' /Code: '+searchCode;
        
        //searchMessage
        searchMessage = 'List of Students';
        if(searchSelectedClass !='1'){
            queryString += ' AND Class__c = :searchSelectedClass';
        }
        if(gender==1){
            queryString += ' AND Gender__c = True';
            searchMessage+=' /male';
        }
        else if(gender==0){
            queryString += ' AND Gender__c = False';
            searchMessage+=' /female';
        }
        if (birthdate != null) {
            // Assuming that the Birthdate__c field is a date field
            String formattedDate = birthdate.year() + '-' + pad(birthdate.month()) + '-' + pad(birthdate.day());
            queryString += ' AND Birthdate__c = ' + formattedDate;
            searchMessage+=' /birthday:'+formattedDate;
        }
        if (startDate != null && endDate != null) {
            // Assuming that the Birthdate__c field is a date field
            String formattedStartDate = startDate.year() + '-' + pad(startDate.month()) + '-' + pad(startDate.day());
            String formattedEndDate = endDate.year() + '-' + pad(endDate.month()) + '-' + pad(endDate.day());
            queryString += ' AND Birthdate__c >= ' + formattedStartDate + ' AND Birthdate__c <= ' + formattedEndDate;
            searchMessage+=' /birthday between:'+formattedStartDate + ' - ' +formattedEndDate;
        }
        queryString = searchByDayMonthYear(queryString);        
        queryString += ' ORDER BY Student_Code__c';
        searchResults = Database.query(queryString);

        //PAGINATION START
        totalRecords = searchResults.size();

        // Calculate total pages
        totalPages = (totalRecords + pageSize - 1) / pageSize;
        setRecordsByPagesNumber();
        // Reset startIndex to the beginning
        startIndex = 0;
        // Reset currentPage to 1
        currentPage = 1;
        //PAGINATION END

    }
    //HELPER METHOD SECTION  

    public PageReference clearFilters() {
        // Reset filter variables to default values
        searchCode = null;
        searchName = null;
        searchSelectedClass = null;
        gender = null;
        startDate = null;
        endDate = null;
        day = 0;
        month = 0;
        year = null;
        birthdate = null;

        // Add additional logic if needed

        // Return null to stay on the same page
        return null;
    }
    public void setRecordsByPagesNumber() {
        recordsByPages = new Map<Integer, List<Student__c>>();
        for (Integer i = 0; i < totalPages; i++) {
            List<Student__c> pageList = new List<Student__c>();
            for (Integer j = pageSize * i; j < Math.min(pageSize * (i + 1), searchResults.size()); j++) {
                pageList.add(searchResults[j]);
            }
            recordsByPages.put(i + 1, pageList); // Assuming pages are 1-indexed
        }
    }
    private String  searchByDayMonthYear(String queryString){
        if (day != 0) {
            queryString += ' AND DAY_IN_MONTH(Birthdate__c) = :day';
            searchMessage +=' /day: '+day;
        }
        if (month != 0) {
            queryString += ' AND CALENDAR_MONTH(Birthdate__c) = :month';
            searchMessage +=' /month: '+month;
        
        }
        if (year >1980) {
            queryString += ' AND CALENDAR_YEAR(Birthdate__c) = :year';
            searchMessage +=' /year: '+year;
        }
        if((0<year && year<1980) || year> Date.today().year()){
            searchMessage = 'invalid year';
        }
        if(month==2 && day>29){
            searchMessage = 'February does not have greater than 29 days';
        }
        return queryString;
    }
    private String pad(Integer value) {
        return String.valueOf(value).leftPad(2, '0');
    }
    private Integer getAge(Date birthdate){
        Date today = Date.today();
        return today.year() - birthdate.year() - (today.month() < birthdate.month() || (today.month() == birthdate.month() && today.day() < birthdate.day()) ? 1 : 0);
    }
    public  List<SelectOption> getClassOptions() {
        List<SelectOption> options = new List<SelectOption>();
        List<Class__c> classes = [SELECT Id, Class_Name__c FROM Class__c];
        options.add(new SelectOption('1', 'all'));
        for (Class__c cls : classes) {
            options.add(new SelectOption(cls.Id, cls.Class_Name__c));
        }
        return options;
    }
    public  List<SelectOption> getClassOptionsCreate() {
        List<SelectOption> options = new List<SelectOption>();
        List<Class__c> classes = [
            SELECT 
                Id
                , Class_Name__c 
            FROM Class__c
        ];
        for (Class__c cls : classes) {
            options.add(new SelectOption(cls.Id, cls.Class_Name__c));
        }
        return options;
    }
    public void setStudent() {
        if (selectedId == '') {
            this.student = new Student__c();
        } else {
            this.student = [
                SELECT 
                    Id
                    , Student_Code__c
                    , First_Name__c
                    , Last_Name__c
                    , Class__r.Class_Name__c
                    , Gender__c
                    , Birthdate__c
                    , Address__c
                FROM Student__c
                WHERE Id = :selectedId
                LIMIT 1
            ];
        }
    }
    public void setStudentEmpty() {
        this.student=new Student__c();
    }
    
    //CRUD MODAL HANDLE
    //handle creating student in searchpage
    public void createStudent() {
        try {
            Boolean errorFlag=false;
            if (String.isBlank(this.student.First_Name__c)) {
                setStudentEmpty();
                this.firstNameError='First Name cannot be blank.';
                errorFlag=true;
            }
            else if(!String.isBlank(this.student.First_Name__c)){
                this.firstNameError='';
            }
            if (String.isBlank(this.student.Last_Name__c)) {
                setStudentEmpty();
                this.lastNameError='Last Name cannot be blank.';
                errorFlag=true;
            }
            else if (!String.isBlank(this.student.Last_Name__c)) {
                this.lastNameError='';
            }
            if (String.isBlank(this.student.Address__c)) {
                setStudentEmpty();
                this.addressError='Address cannot be blank.';
                errorFlag=true;
            }
            else if (!String.isBlank(this.student.Address__c)) {
                this.addressError='';
            }
            if(this.student.Birthdate__c == null){
                setStudentEmpty();
                this.birthdateError='Birthdate cannot be blank.';
                errorFlag=true;
            }
            else if(this.student.Birthdate__c != null){
                Integer age = getAge(this.student.Birthdate__c);
                this.birthdateError='';
                if (age < 17) {
                    setStudentEmpty();
                    this.birthdateError='Student must be at least 17 years old.';
                    errorFlag=true;
                }
                else{
                    this.birthdateError='';
                }
            }
            if(!errorFlag){
                this.student.Name = student.First_Name__c.left(39) + ' ' + student.Last_Name__c.left(39);
                insert student;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Student created successfully.'));
                selectedIds.put(student.Id, false);
                this.student = new Student__c();
                searchResults = new List<Student__c>();
                performSearch();
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'error when creatomg student'));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating student: ' + e.getMessage()));
            System.debug('Exception Details: ' + e);
        }
    }
    
    //handle update student
    
    public PageReference updateStudent() {
        try {
            //isBlank check validation
            if (String.isBlank(this.student.First_Name__c)) {
                setStudentEmpty();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'First Name cannot be blank.'));
                return null;
            }
            if (String.isBlank(this.student.Last_Name__c)) {
                setStudentEmpty();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Last Name cannot be blank.'));
                return null;
            }
            if (String.isBlank(this.student.Address__c)) {
                setStudentEmpty();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Address cannot be blank.'));
                return null;
            }
            if(this.student.Birthdate__c ==null){
                setStudentEmpty();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Birthdate cannot be blank.'));
                return null;
            }
            Integer age =getAge(this.student.Birthdate__c);
            if (age < 17) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Student must be at least 17 years old.'));
                return null;
            }
            update student;
            //reload trang
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
    //handle delete
    public void deleteStudent() {
        try {
            if (String.isNotBlank(selectedId)) {
                Student__c studentToDelete = [SELECT Id FROM Student__c WHERE Id = :selectedId LIMIT 1];
                if (studentToDelete != null) {
                    delete studentToDelete;
                    selectedId = '';
                    this.student=new Student__c();
                    //reload trang
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
    // Method to handle deleting selected records
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
                // Create a list to store keys to be removed
                List<Id> keysToRemove = new List<Id>();

                // Iterate over the selectedIds map
                for (Id studentId : selectedIds.keySet()) {
                    Boolean checked = selectedIds.get(studentId);
                    if (checked == true) {
                        keysToRemove.add(studentId);
                    }
                }

                // Remove the selected keys from the map
                for (Id key : keysToRemove) {
                    selectedIds.remove(key);
                }
                delete studentsToDelete;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Selected records deleted successfully.'));
                // Refresh the search results after deletion
                performSearch();
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error deleting records: ' + e.getMessage()));
                System.debug('Exception Details: ' + e);
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records selected for deletion.'));
        }
    }
    //PAGINATION START
        public Boolean getHasPrevious() {
            return startIndex - pageSize >= 0;
        }

        public Boolean getHasNext() {
            return startIndex + pageSize < totalRecords;
        }

        public PageReference previous() {
            startIndex -= pageSize;
            currentPage--;
            return null; // Or return a PageReference if needed
        }

        public PageReference next() {
            startIndex += pageSize;
            currentPage++;
            return null; // Or return a PageReference if needed
        }
        // Method to go to the first page
        public PageReference first() {
            startIndex = 0;
            currentPage = 1;
            return null; // Or return a PageReference if needed
        }
        // Method to go to the last page
        public PageReference last() {
            if(totalRecords ==0){
                
                return null;
            }
            else{
                // Calculate the starting index for the last page
                Integer remainder = Math.mod(totalRecords, pageSize);
                startIndex = totalRecords - remainder;
                if (remainder == 0) {
                    startIndex -= pageSize;
                }
                
                currentPage = totalPages;
                return null; // Or return a PageReference if needed
            
            }    
        }
    //PAGINATION END

    //SELECT RECORDS HANDLE
        // Method to handle selecting all checkboxes
        public void selectAllCheckboxesTable() {
            Integer count = 0;
            List<Student__c> selectPageList = recordsByPages.containsKey(currentPage) ? recordsByPages.get(currentPage) : new List<Student__c>();
            for (Student__c student : selectPageList) {
                selectedIds.put(student.Id, true);
            }
            
            updateSelectedRecordsNumder();
        }
        
        public void selectAllCheckboxes() {
            for (Student__c student : searchResults) {
                selectedIds.put(student.Id, true);
            }
                      
            updateSelectedRecordsNumder();
        }
        // Method to handle clearing selected records
        // public void clearRecords() {
        //     selectedIds.clear();
        // }
        public void clearRecords() {
            allSelected = false;
            for (Id recordId : selectedIds.keySet()) {
                selectedIds.put(recordId, false);
            }
            this.selectedRecordsNumber=0;

        }
        //update the selected records number
        public void updateSelectedRecordsNumder(){
            Integer count =0;
            for (Boolean checked : selectedIds.values()) {
                if(checked==true){
                    count++;
                }
            }
            this.selectedRecordsNumber=count;
        }
    //SELECT RECORDS END

}