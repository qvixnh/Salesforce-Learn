public with sharing class Classes {
    public Class__c selClass { get; set; }
    public List<Class__c> classesList { get; set; }
    public List<Class__c> searchResults { get; set; }

    //PAGINATION HANDLE
        public Integer pageSize { get; set; }
        public Integer startIndex { get; set; }
        public Integer totalRecords { get; set; }
        public Integer currentPage { get; set; }
        public Integer totalPages { get; set; }
    //PAGINATION END
    public Classes() {
        //PAGINATION START
        pageSize = 5;
        // Initialize startIndex
        startIndex = 0;
        // Initialize currentPage
        currentPage = 1;
        //PAGINATION END
        this.selClass=new Class__c();
        searchResults = new List<Class__c>();
    }
    public void performSearch() {
            
        searchResults  = [SELECT Id, Class_Code__c, Class_Name__c, Number_Of_Student__c FROM Class__c ORDER BY Class_Code__c];
        //PAGINATION START
        totalRecords = searchResults.size();

        // Calculate total pages
        totalPages = (totalRecords + pageSize - 1) / pageSize;

        // Reset startIndex to the beginning
        startIndex = 0;
        // Reset currentPage to 1
        currentPage = 1;
        //PAGINATION END

    }
    public PageReference createClass() {
        try {
            insert selClass;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Class created successfully.'));
            selClass = new Class__c(); // Reset the form after successful creation
            return new PageReference('/apex/Classes');
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating class: ' + e.getMessage()));
        }
        return null;
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
            // Calculate the starting index for the last page
            Integer remainder = Math.mod(totalRecords, pageSize);
            startIndex = totalRecords - remainder;
            if (remainder == 0) {
                startIndex -= pageSize;
            }
            
            currentPage = totalPages;
            return null; // Or return a PageReference if needed
        }
    //PAGINATION END
}