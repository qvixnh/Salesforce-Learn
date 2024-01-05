({
    myAction : function(component, event, helper) {

    },
    deleteStudent: function(component, event, helper) {
        var studentId = component.get("v.student.Id");

        var action = component.get("c.deleteStudentRecord");
        action.setParams({
            "studentId": studentId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result === 'Success') {
                    // Student deleted successfully
                    alert("Student record deleted successfully");
                } else {
                    // Handle other cases like record not found or error
                    alert(result);
                }
            } else {
                // Handle server-side error
                alert("Error occurred");
            }
        });

        $A.enqueueAction(action);
    }
})
