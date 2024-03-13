/*
    * クラス名：CMP_SearchConditionController.js
    * クラス概要：CMP Create Student Controller
    * @created：2023/12/26 + Nguyen Vinh
    * @modified：
*/
({
    /*init class options, gender, day, month select options, and load student to event*/
    init: function(component, event, helper) {
        helper.getClasses(component);
        helper.initializeOptions(component);
        helper.loadData(component);
    },
    /*
        validate the date select if it's valid, if not then clear the month options
    */
    handleDayChange: function(component, event, helper) {
        var day = component.get("v.searchDayOfBirth");
        var month = component.get("v.searchMonthOfBirth");
        if(month==2 && day>28){
            component.set("v.searchMonthOfBirth",0 )
        }  
    },
    /*
    validate the month select and get the days of selected month to ensure that not choosing the invalid day
    */
    handleMonthChange: function(component, event, helper) {
        var day = component.get("v.searchDayOfBirth");
        var month = component.get("v.searchMonthOfBirth");
        var year = component.get("v.searchYearOfBirth");
        var days = [];
        var daysInMonth = new Date(year,month,0).getDate();
        for (var i = 1; i <= daysInMonth; i++) {
            days.push({ label: i.toString(), value: i.toString() });
        }
        component.set("v.dayOptions", days);
        if(month==2 && day>28){
            component.set("v.searchDayOfBirth",0 )
        }
    },
    /*
    clear all search filters to get all students
    */
    clearAllFilters: function(component, event, helper) {
        component.set("v.selectedClass", "null");
        component.set("v.selectedGender", "2");
        component.set("v.searchName", "");
        component.set("v.searchCode", "SV_");
        component.set("v.birthdate", "");
        component.set("v.searchDayOfBirth",0 )
        component.set("v.searchMonthOfBirth",0)
        component.set("v.searchYearOfBirth",0)
    },
    /*
    handle search button
    */
    handleChange: function(component, event, helper) {
        helper.loadData(component);
    },
    
})