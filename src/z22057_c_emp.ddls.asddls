@AccessControl.authorizationCheck: #NOT_REQUIRED 
@EndUserText.label: 'Consumption View 22CS057' 
@Metadata.ignorePropagatedAnnotations: true 
@Metadata.allowExtensions: true 
define root view entity Z22057_C_EMP 
as projection on Z22057_I_EMP 
{ 
key EmpId, 
FirstName, 
LastName, 
DateOfBirth, 
Email, 
HireDate, 
@Semantics.amount.currencyCode: 'Curry' 
Salary, 
Curry
}
