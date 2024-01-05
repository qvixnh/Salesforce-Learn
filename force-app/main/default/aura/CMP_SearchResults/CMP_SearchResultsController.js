({

    //table's controller handle

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
        component.set("v.parentStatus", true);
    },
    handlerActionCreate: function(component, event, helper) {
        component.set("v.CreateStudentModal", true);
        component.set("v.parentStatus", true);

    },
    handlerActionUpdate: function(component, event, helper) {
        var studentId = event.getSource().get("v.name");
        helper.getStudentDetail(component, studentId);
        component.set("v.UpdateStudentModal", true);
        component.set("v.parentStatus", true);

    },
    handlerActionDelete: function(component, event, helper) {
        var studentId = event.getSource().get("v.name");
        helper.getStudentDetail(component, studentId);
        component.set("v.DeleteStudentModal", true);
        component.set("v.parentStatus", true);

    },
    handlerActionDeleteMultipleStudents: function(component, event, helper) {
        component.set("v.DeleteMultipleStudentsModal", true);
        component.set("v.parentStatus", true);
    },
    handlerActionClose: function(component, event, helper) {
        component.set("v.DeleteMultipleStudentsModal", false);
        component.set("v.DetailStudentModal", false);
        component.set("v.DeleteStudentModal", false);
        component.set("v.parentStatus", false);
    },
    handlerActionCreateClose: function(component, event, helper) {
        component.set("v.CreateStudentModal", false);
        component.set("v.parentStatus", false);
        helper.navigateToPage(component, component.get("v.totalPage"));

    },
    handlerActionUpdateClose: function(component, event, helper) {
        component.set("v.UpdateStudentModal", false);
        component.set("v.parentStatus", false);
        helper.navigateToPage(component, component.get("v.currentPage"));

    },
    deleteStudent: function(component, event, helper) {
        var studentId = component.get("v.selectedStudent.Id");
        var action = component.get("c.deleteStudentRecord");
        action.setParams({
            "studentId": studentId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();    
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result === 'Success') {
                    // Show a success toast message
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Student record deleted successfully.",
                        "type": "success"
                    });
                    //helper.refreshTableData(component);
                    toastEvent.fire();
                } else {
                    // Show an error toast message
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": result,
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            } else {
                // Show an error toast message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "error occued when deleting student",
                    "type": "error"
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
        component.set("v.DeleteStudentModal", false);
        component.set("v.parentStatus", false);
        helper.navigateToPage(component, 1);
    },
    deleteSelectedStudents: function(component, event, helper) {
        var students = component.get("v.students");
        var selectedIds = [] ;
        students.forEach(function(student){
            if(student.selected__c ==true){
                selectedIds.push(student.Id);
            }
        });
        var action = component.get("c.deleteSelectedStudentsCtrl");
        action.setParams({
            "studentIds": selectedIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // Show a success toast message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Student record deleted successfully - ."+ result,
                    "type": "success"
                });
                toastEvent.fire();

            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "error occued when deleting student",
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
    
        $A.enqueueAction(action);
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
    },
    handleRowSelection: function(component, event, helper) {
        // var studentId = event.getSource().get("v.value");
        // var students = component.get("v.students");
        // var checked = event.getSource().get("v.checked");
        // for(let i = 0; i<students.length;i++ ){
        //     if(students[i].id == studentId){
        //         students[i].selected__c = checked;
        //     }
        // }
        // helper.updateSelectAll(component,false);
        // helper.updateSelectedRecordsNumber(component);
        // component.set("v.students",students);
    },
    
})