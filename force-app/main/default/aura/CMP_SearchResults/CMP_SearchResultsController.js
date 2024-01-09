({
    /*
        handle the search event to load students
    */
    handleSearchEvent: function(component, event, helper) {
        var totalStudents = event.getParam("totalStudents");
        var totalPages = event.getParam("totalPages");
        var totalRecords = event.getParam("totalRecords");
        component.set("v.totalStudents",totalStudents);
        component.set("v.totalPage",totalPages);
        component.set("v.totalRecords",totalRecords);
        helper.updateTable(component);
        helper.navigateToPage(component,1);
    },
    /*
    handle select all student checkbox
    */
    selectAll: function(component, event, helper) {
        var students = component.get("v.students");
        var checked = event.getSource().get("v.checked");
        for(let i = 0; i<students.length;i++ ){
            students[i].selected__c = checked;
        }
        helper.updateSelectedRecordsNumber(component,checked);
        component.set("v.students",students); 
    },
    /*
    handle close detail student button, show the detail modal
    */
    openDetail: function(component, event, helper) {
        var studentId = event.getSource().get("v.name");
        helper.getStudentDetail(component, studentId);
        component.set("v.DetailStudentModal", true);
    },
    /*
    handle open create student button, show the create modal
    */
    openCreate: function(component, event, helper) {
        component.set("v.CreateStudentModal", true);
    },
    /*
    handle open update student button, show the update modal
    */
    openUpdate: function(component, event, helper) {
        var studentId = event.getSource().get("v.name");
        helper.getStudentDetail(component, studentId);
        component.set("v.UpdateStudentModal", true);
    },
    /*
    handle open delete student button, show the delete modal
    */
    openDelete: function(component, event, helper) {
        var studentId = event.getSource().get("v.name");
        helper.getStudentDetail(component, studentId);
        component.set("v.DeleteStudentModal", true);
    },
    /*
    handle open delete multiple students button, show the delete multiple students  modal
    */
    openDeleteMultipleStudents: function(component, event, helper) {
        component.set("v.DeleteMultipleStudentsModal", true);
    },
    /*
    handle close student detail, delete student and  delete multiple students button, clese the delete multiple students  modal
    */
    close: function(component, event, helper) {
        component.set("v.DeleteMultipleStudentsModal", false);
        component.set("v.DetailStudentModal", false);
        component.set("v.DeleteStudentModal", false);
    },
    /*
    handle close create modal button, clese the create student form  modal
    */
    closeCreate: function(component, event, helper) {
        component.set("v.CreateStudentModal", false);
    },
    /*
    handle close udpate modal button, clese the udpate student form  modal
    */
    closeUpdate: function(component, event, helper) {
        component.set("v.UpdateStudentModal", false);
        component.set("v.DetailStudentModal", false);

        helper.navigateToPage(component, component.get("v.currentPage"));
    },
    /*
    handle button delete one student record 
    */
    deleteStudent: function(component, event, helper) {
        helper.helperDeleteStudent(component);
    },
    /*
    handle button delete multiple students record 
    */
    deleteSelectedStudents: function(component, event, helper) {
        helper.helperDeleteSelectedStudents(component);
    },
    /*go to the previous page*/
    previous : function(component, event, helper) {
        helper.navigate(component, -1);
    },
    /*go to the first page*/
    first : function(component, event, helper) {
        helper.navigateToPage(component, 1);
    },
    /*go to the next page*/
    next : function(component, event, helper) {
        helper.navigate(component, 1);
    },
    /*go to the last page*/
    last : function(component, event, helper) {
        helper.navigateToPage(component, component.get("v.totalPage"));
    },
    /*go to page*/
    page : function(component, event, helper) {
        var pageNumber = event.getSource().get("v.label");
        helper.navigateToPage(component, pageNumber);
    },
    
    /*click on row to select student*/
    rowClick: function(component, event, helper) {
        var clickedRow = event.currentTarget;
        var modal = component.get("v.parentStatus");
        if(modal){
            return;
        }
        var checkbox = clickedRow.querySelector('[type="checkbox"]');
        var newchecked=!checkbox.checked;
        var studentId = checkbox.getAttribute("value");
        var students = component.get("v.students");
        for(let i = 0; i<students.length;i++ ){
            if(students[i].Id == studentId){
                students[i].selected__c = newchecked;
            }
        }
        helper.updateSelectAll(component,false);
        helper.updateSelectedRecordsNumber(component);
        component.set("v.students",students);
    }
})