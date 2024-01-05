({
    //setup the field for searching student
    handleDayChange: function(component, event, helper) {
        var day = component.get("v.searchDayOfBirth");
        var month = component.get("v.searchMonthOfBirth");
        var year = component.get("v.searchYearOfBirth");
        if(month==2 && day>28){
            component.set("v.searchMonthOfBirth",0 )
        }  
    },
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
    clearAllFilters: function(component, event, helper) {
        component.set("v.selectedClass", "null");
        component.set("v.selectedGender", "2");
        component.set("v.searchName", "");
        component.set("v.searchCode", "ST-");
        component.set("v.birthdate", "");
        component.set("v.searchDayOfBirth",0 )
        component.set("v.searchMonthOfBirth",0)
        component.set("v.searchYearOfBirth",0)
    },
    //handle search action
    handleChange: function(component, event, helper) {
        helper.updatePageNumbers(component);
        helper.loadData(component);
        helper.navigateToPage(component, 1);
    },
    
})
