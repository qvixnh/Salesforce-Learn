({
    getStudentDetail: function(component, studentId) {
        var action = component.get("c.getStudentDetails");
        action.setParams({
            "studentId": studentId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.selectedStudent", response.getReturnValue());
            } else {
                console.error('Error: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    //PAGINATION
    updateSelectAll: function(component, navigated=false){
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
    uncheck:function(component){
        var students = component.get("v.students");
        students.forEach(function(student){
            student.selected__c =false;
        });
        component.set("v.selectedRecordsNumber",0);

    },
    updateTable : function(component) {
        var records = component.get("v.totalStudents");
        var currentPage = component.get("v.currentPage");
        var pageSize = component.get("v.pageSize");
        var start = (currentPage - 1) * pageSize;
        var end = start + pageSize;
        component.set("v.students", records.slice(start, end));
        //update Page Numbers
        var totalPage = component.get("v.totalPage");
        var startPage = Math.max(1, currentPage - 1);
        var endPage = Math.min(totalPage, startPage + 2);
        var pageNumbers = [];
        for (var i = startPage; i <= endPage; i++) {
            pageNumbers.push(i);
        }
        component.set("v.pageNumbers", pageNumbers);
    },
    navigateToPage : function(component, pageNumber) {
        this.uncheck(component);
        component.set("v.currentPage", pageNumber);
        component.set("v.allStudentChecked",false);
        this.updateTable(component);

    },

    navigate : function(component, direction) {
        this.uncheck(component);
        var currentPage = component.get("v.currentPage");
        component.set("v.currentPage", currentPage + direction);
        component.set("v.allStudentChecked",false);
        this.updateTable(component);
    },
    //helper to delete
    helperDeleteStudent: function(component) {
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
                    // var toastEvent = $A.get("e.force:showToast");
                    // toastEvent.setParams({
                    //     "title": "Success!",
                    //     "message": "Student record deleted successfully.",
                    //     "type": "success"
                    // });
                    // toastEvent.fire();
                    alert("student delete successfully");
                    var reloadEvent = $A.get("e.c:CMP_ReloadEvent");
                    reloadEvent.fire();
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
    },
    helperDeleteSelectedStudents:function(component){
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
                // var toastEvent = $A.get("e.force:showToast");
                // toastEvent.setParams({
                //     "title": "Success!",
                //     "message": "Student record deleted successfully - ."+ result,
                //     "type": "success"
                // });
                // toastEvent.fire();
                alert("multiple students deleted successfully");
                var reloadEvent = $A.get("e.c:CMP_ReloadEvent");
                reloadEvent.fire();
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
    }
})