/*
    * クラス名：CMP_SearchConditionHelper.js
    * クラス概要：CMP Create Student Helper
    * @created：2023/12/26 + Nguyen Vinh
    * @modified：
*/
({
    /*
        get class to set the class options to search student by class
    */  
    getClasses: function (component) {
        var action = component.get("c.getClassOptions");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var classOptions = response.getReturnValue();
                component.set("v.classList", classOptions);
            } else {
                console.error("Error fetching class options: " + state);
            }
        });

        $A.enqueueAction(action);
    },
    /*
    init all select options for searching action
    */
    initializeOptions: function(component) {
        component.set("v.monthOptions", [
            { label: "January", value: "1" },
            { label: "February", value: "2" },
            { label: "March", value: "3" },
            { label: "April", value: "4" },
            { label: "May", value: "5" },
            { label: "June", value: "6" },
            { label: "July", value: "7" },
            { label: "August", value: "8" },
            { label: "September", value: "9" },
            { label: "October", value: "10" },
            { label: "November", value: "11" },
            { label: "December", value: "12" }
        ]);
        component.set("v.FieldOrderByList",[
            {label:"Student Code", value:"StudentCode__c"},
            {label:"Student Name", value:"Firstname__c"},
            {label:"Class", value:"Class_look__r.Name"},
            {label:"Student Birthdate", value:"Birthday__c"},
            {label:"Student Gender", value:"Gender__c"},
        ])
        component.set("v.OrderTypeList",[
            {label:"Ascendant", value:"ASC"},
            {label:"Descendant", value:"DESC"},
        ])

        var days = [];
        for (var i = 1; i <= 31; i++) {
            days.push({ label: i.toString(), value: i.toString() });
        }
        component.set("v.dayOptions", days);
    },
    /*
        get all the query condition and search student, then set the event attribute 
    */
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
        if(year==""){
            year =0;
        }
        if(birthdate==null){
            birthdate='';
        }
        action.setParams({
            pageSize: component.get("v.pageSize"),
            classId: classId,
            gender:gender,
            searchName:searchName.trim(),
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
                var searchEvent = $A.get("e.c:CMP_SearchEvent");
                searchEvent.setParams({
                    "totalStudents": result.records,
                    "totalPages":result.totalPage,
                    "totalRecords":result.totalRecords
                });
                searchEvent.fire();
            } else {
                console.error("Error fetching data");
            }
        });
        $A.enqueueAction(action);
    }
})