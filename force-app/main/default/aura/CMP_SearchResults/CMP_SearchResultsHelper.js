/*
    * クラス名：CMP_SearchResultHelper.js
    * クラス概要：CMP SearchResult Helper
    * @created：2023/12/26 + Nguyen Vinh
    * @modified：
*/
({
    /*
        get student detail to show in detail modal, update, or delete 1 student record
    */
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
    /*
    when the page change or checkbox elements change, udpate the check all 
    */

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
    /*
    when the page change or checkbox elements change, udpate the selected records number label all 
    */
    updateSelectedRecordsNumber:function(component){
        var students = component.get("v.totalStudents");
        var selectedIds = [] ;
        students.forEach(function(student){
            if(student.selected__c ==true){
                selectedIds.push(student.Id);
            }
        });
        component.set("v.selectedRecordsNumber",selectedIds.length);
        
    },
    /*when navigate to another page,update the display student by current page number and update the page numbers list*/
    updateTable : function(component) {
        var records = component.get("v.totalStudents");
        var currentPage = component.get("v.currentPage");
        var pageSize = component.get("v.pageSize");
        var start = (currentPage - 1) * pageSize;
        var end = start + pageSize;
        component.set("v.students", records.slice(start, end));
        var totalPage = component.get("v.totalPage");
        var startPage = Math.max(1, currentPage - 1);
        var endPage = Math.min(totalPage, startPage + 2);
        var pageNumbers = [];
        for (var i = startPage; i <= endPage; i++) {
            pageNumbers.push(i);
        }
        component.set("v.pageNumbers", pageNumbers);
        this.updateSelectAll(component);
        this.updateSelectedRecordsNumber(component);
    
    },
    /*when click on page number, navigate to that page*/
    navigateToPage : function(component, pageNumber) {
        component.set("v.currentPage", pageNumber);
        component.set("v.allStudentChecked",false);
        this.updateTable(component);

    },
    /*
        handle navigate nex or previous page
    */
    navigate : function(component, direction) {
        var currentPage = component.get("v.currentPage");
        component.set("v.currentPage", currentPage + direction);
        component.set("v.allStudentChecked",false);
        this.updateTable(component);
    },
    /*
        handle delete one student record
    */
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
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Student record deleted successfully.",
                        "type": "success"
                    });
                    toastEvent.fire();
                    var reloadEvent = $A.get("e.c:CMP_ReloadEvent");
                    reloadEvent.fire();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": result,
                        "type": "error"
                    });
                    toastEvent.fire();
                }
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
        component.set("v.DeleteStudentModal", false);
        component.set("v.parentStatus", false);
    },
    /*
        handle delete selected student records
    */
    helperDeleteSelectedStudents:function(component){
        var students = component.get("v.totalStudents");
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
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Student record deleted successfully - ."+ result,
                    "type": "success"
                });
                toastEvent.fire();
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
        component.set("v.DeleteMultipleStudentsModal", false);
        $A.enqueueAction(action);
    },
    checkStu: function(component, id, check){
        var students = component.get("v.totalStudents");
        for(var stu of students ){
            if(stu.Id == id){
                stu.selected__c = check;
            }

        }
        component.set("v.totalStudents",students);
    }
})