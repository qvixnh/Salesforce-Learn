({
    //search event
    handleSearchEvent: function(component, event, helper) {
        var totalStudents = event.getParam("totalStudents");
        var totalPages = event.getParam("totalPages");
        var totalRecords = event.getParam("totalRecords");
        component.set("v.totalStudents",totalStudents);
        component.set("v.totalPage",totalPages);
        component.set("v.totalRecords",totalRecords);
        helper.updatePageNumbersPagination(component);
        helper.updateDisplayedRecordsPagination(component);
        helper.navigateToPage(component,1);
    },
    handleSelectAll: function(component, event, helper) {
        var students = component.get("v.students");
        var checked = event.getSource().get("v.checked");
        for(let i = 0; i<students.length;i++ ){
            students[i].selected__c = checked;
        }
        helper.updateSelectedRecordsNumber(component,checked);
        component.set("v.students",students); 
    },
    //handle 3 action button
    handlerAction: function(component, event, helper) {
        var studentId = event.getSource().get("v.name");
        helper.getStudentDetail(component, studentId);
        component.set("v.DetailStudentModal", true);
    },
    handlerActionCreate: function(component, event, helper) {
        component.set("v.CreateStudentModal", true);
    },
    handlerActionUpdate: function(component, event, helper) {
        var studentId = event.getSource().get("v.name");
        helper.getStudentDetail(component, studentId);
        component.set("v.UpdateStudentModal", true);
    },
    handlerActionDelete: function(component, event, helper) {
        var studentId = event.getSource().get("v.name");
        helper.getStudentDetail(component, studentId);
        component.set("v.DeleteStudentModal", true);
    },
    handlerActionDeleteMultipleStudents: function(component, event, helper) {
        component.set("v.DeleteMultipleStudentsModal", true);
    },
    handlerActionClose: function(component, event, helper) {
        component.set("v.DeleteMultipleStudentsModal", false);
        component.set("v.DetailStudentModal", false);
        component.set("v.DeleteStudentModal", false);
    },
    handlerActionCreateClose: function(component, event, helper) {
        component.set("v.CreateStudentModal", false);
        helper.navigateToPage(component, component.get("v.totalPage"));
    },
    handlerActionUpdateClose: function(component, event, helper) {
        component.set("v.UpdateStudentModal", false);
        helper.navigateToPage(component, component.get("v.currentPage"));
    },
    deleteStudent: function(component, event, helper) {
        helper.helperDeleteStudent(component);
    },
    deleteSelectedStudents: function(component, event, helper) {
        helper.helperDeleteSelectedStudents(component);
    },
    //PAGINATION
    handlePrevious : function(component, event, helper) {
        helper.navigate(component, -1);
    },
    handleFirst : function(component, event, helper) {
        helper.navigateToPage(component, 1);
    },
    handleNext : function(component, event, helper) {
        helper.navigate(component, 1);
    },
    handleLast : function(component, event, helper) {
        helper.navigateToPage(component, component.get("v.totalPage"));
    },
    navigateToPage : function(component, event, helper) {
        var pageNumber = event.getSource().get("v.label");
        helper.navigateToPage(component, pageNumber);
    },
    
    //ROW SELECTION
    handleRowClick: function(component, event, helper) {
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