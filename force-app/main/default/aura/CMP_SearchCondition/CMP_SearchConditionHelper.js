({
    //helper for search button(onclick handling)
    updatePageNumbers : function(component) {
        var totalPage = component.get("v.totalPage");
        var currentPage = component.get("v.currentPage");
        var startPage = Math.max(1, currentPage - 1);
        var endPage = Math.min(totalPage, startPage + 2);
        var pageNumbers = [];
        for (var i = startPage; i <= endPage; i++) {
            pageNumbers.push(i);
        }
        component.set("v.pageNumbers", pageNumbers);
    },
    loadData : function(component) {
        var action = component.get("c.getRecords");
        var searchName = component.get("v.searchName");
        var searchCode = component.get("v.searchCode");
        var gender = component.get("v.selectedGender");
        var classId= component.get("v.selectedClass");
        var day=component.get("v.searchDayOfBirth");
        var month=component.get("v.searchMonthOfBirth");
        var year=component.get("v.searchYearOfBirth");
        var birthdate=component.get("v.birthdate");
        var FieldOrderBy=component.get("v.FieldOrderBy");
        var OrderType=component.get("v.OrderType");
        console.log(FieldOrderBy);
        console.log(OrderType);
        if(year==""){
            year =0;
        }
        if(birthdate==null){
            birthdate='';
        }
        action.setParams({
            currentPage: component.get("v.currentPage"),
            pageSize: component.get("v.pageSize"),
            classId: classId,
            gender:gender,
            searchName:searchName,
            searchCode:searchCode,
            day:day,
            month:month,
            year:year,
            birthdate:birthdate,
            orderField:FieldOrderBy,
            orderType:OrderType
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.students", result.records);
                component.set("v.totalStudents", result.records);
                component.set("v.totalPage", result.totalPage);
                component.set("v.totalRecords", result.totalRecords);
                this.updateDisplayedRecords(component);
                this.updatePageNumbers(component);
                //fire event
                var searchEvent = $A.get("e.c:CMP_SearchEvent");
                searchEvent.setParams({
                    "totalStudents": result.records
                });
                searchEvent.fire();
            } else {
                console.error("Error fetching data");
            }
        });
        $A.enqueueAction(action);
    },
    updateDisplayedRecords : function(component) {
        var records = component.get("v.students");
        var currentPage = component.get("v.currentPage");
        var pageSize = component.get("v.pageSize");
        var start = (currentPage - 1) * pageSize;
        var end = start + pageSize;
        component.set("v.students", records.slice(start, end));
    },
    updateSelectedRecordsNumber:function(component,allSelect=false){
        var students = component.get("v.students");
        var selectedIds = [] ;
        students.forEach(function(student){
            if(student.selected__c ==true){
                selectedIds.push(student.Id);
            }
        });
        component.set("v.selectedRecordsNumber",selectedIds.length);
        if(allSelect){
            component.set("v.selectedRecordsNumber",component.get("v.pageSize"));
        }
    },
    navigateToPage : function(component, pageNumber) {
        // Update the current page and reload data
        component.set("v.currentPage", pageNumber);
        this.updateSelectAll(component,true);
        this.loadData(component);
    },
    updateSelectAll: function(component, navigated){
        var students = component.get("v.students");
        var selectedIds = [] ;
        students.forEach(function(student){
            if(student.selected__c ==true){
                selectedIds.push(student.Id);
            }
        });
        var pageSize = component.get("v.pageSize");
        if(selectedIds.length == pageSize && navigated==false){
            component.set("v.allStudentChecked",true);
        }else{
            component.set("v.allStudentChecked",false);
        }
        this.updateSelectedRecordsNumber(component);
    },
})
