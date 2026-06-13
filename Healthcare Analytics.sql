CREATE DATABASE IF NOT EXISTS HEALTHCARE_ANALYSIS;
USE HEALTHCARE_ANALYSIS;

SELECT * FROM appointments;
SELECT * FROM billing;
SELECT * FROM departments;
SELECT * FROM doctors;
SELECT * FROM emergency_cases;
SELECT * FROM hospital_staff;
SELECT * FROM insurance;
SELECT * FROM patient_feedback;
SELECT * FROM patients;
SELECT * FROM treatments;

-------- DATA CLEANING PART --------
-- check duplicate appointments --
select appointment_id,count(*)
from appointments
group by appointment_id
having count(*) >1;

select patient_id,doctor_id,appointment_date,appointment_time,
appointment_status,visit_type,waiting_time_min,
booking_date,count(*) as all_appointments
from appointments
group by patient_id,doctor_id,appointment_date,appointment_time,
appointment_status,visit_type,waiting_time_min,
booking_date
having count(*) >1;

           --- check duplicate billing ---
select bill_id,count(*)
from billing
group by bill_id
having count(*) >1;

select patient_id,appointment_id,total_amount,
paid_amount, payment_method,
payment_status,billing_date, insurance_claim,
 count(*) from billing
group by patient_id, appointment_id,
total_amount, paid_amount, payment_method,
payment_status, billing_date,
insurance_claim
having count(*)>1;
         -- check duplicate departments --
select department_id,count(*)
from departments
group by  department_id
having count(*) >1;

select department_name, floor_number,
created_date,count(*)
from departments
group by department_id, department_name,
floor_number, created_date 
having count(*) >1;

     -- check duplicate doctors --
select doctor_id,count(*)
from doctors
group by doctor_id
having count(*) >1;

select doctor_id, doctor_name, gender, specialization,
 department_id, experience_years,
 joining_date, consultation_fee, doctor_rating,
 city, doctor_status,count(*)
from doctors
group by doctor_id, doctor_name, gender, specialization,
department_id, experience_years, joining_date,
consultation_fee, doctor_rating,
city, doctor_status
having count(*) >1;

       -- check duplicate emergency_cases --
select emergency_id,count(*)
from emergency_cases
group by emergency_id
having count(*) >1;

select  patient_id, arrival_time, severity_level, admitted,count(*)
from emergency_cases
group by  patient_id, arrival_time, severity_level, admitted
having count(*) >1;

            -- check duplicate hospital_staff --
select staff_id,count(*)
from hospital_staff
group by staff_id
having count(*) >1;

select staff_name,role, department_id,
joining_date, salary,count(*)
from hospital_staff
group by staff_id, staff_name, role,
 department_id, joining_date, salary
having count(*) >1;

         -- check duplicate insurance --
select insurance_id,count(*)
from insurance
group by insurance_id
having count(*) >1;

select insurance_provider, coverage_percent,
policy_number, expiry_date,count(*)
from insurance
group by insurance_provider, coverage_percent,
policy_number, expiry_date
having count(*) >1;

       -- check duplicate patient_feedback --
select feedback_id,count(*)
from patient_feedback 
group by feedback_id
having count(*) >1;

select patient_id,
doctor_id, rating, review_text,
feedback_date,count(*)
from patient_feedback 
group by patient_id,
doctor_id, rating,
review_text, feedback_date
having count(*) >1;
    -- check duplicate  patients --
select patient_id,count(*)
from patients
group by patient_id
having count(*) >1;


select patient_id,patient_name, gender, age,
 blood_group, city, state, admission_date,
discharge_date, insurance_id, phone_number,
email, patient_status,count(*)
from patients
group by patient_id,patient_name, gender, age,
 blood_group, city, state, admission_date,
discharge_date, insurance_id, phone_number,
email, patient_status
having count(*) >1;

create table patients_clean AS
select distinct
patient_id,patient_name,gender,
age,blood_group,city,state,
admission_date,discharge_date,insurance_id,
phone_number,email,patient_status
from patients;

SELECT *
FROM patients_clean
WHERE discharge_date < admission_date;

UPDATE patients_clean
SET discharge_date = NULL
WHERE discharge_date < admission_date;

UPDATE patients_clean
SET discharge_date = NULL
WHERE discharge_date < admission_date;
-- check duplicate treatments  --
select treatment_id,count(*)
from treatments
group by treatment_id
having count(*) >1;

select patient_id, doctor_id, treatment_name,
treatment_cost, treatment_date,
treatment_status,count(*)
from treatments
group by  patient_id, doctor_id, treatment_name,
treatment_cost, treatment_date,
treatment_status
having count(*) >1;

    -- update appointments table --

update appointments
set waiting_time_min = Null
where waiting_time_min <0;

-- update billing --

update billing 
set payment_status = Null
where paid_amount  <0;

update billing
set payment_status = 'Pending'
where paid_amount = 0;
 select * from billing;
 -- update doctors --
 update doctors 
 set doctor_rating = Null
 where doctor_rating = '';
 select * from doctors;
 
 update doctors 
 set doctor_status = 'Active'
 where doctor_status = 'active';
 
 update doctors 
 set gender = 'Male'
 where gender in ('male','m','M');
 update doctors 
 set gender = 'Female'
 where gender in ('female','f','F');
 select * from doctors;
 -- update patients --
 update patients 
 set gender = 'Male'
 where gender in ('male','m','M');
 update patients 
 set gender = 'Female'
 where gender in ('female','f','F');
 SELECT * FROM patients;
 
 update patients
 set phone_number = Null
 where phone_number = '';
 update patients
 set email = Null
 where email= '';
 SELECT * FROM patients;
 
 -- update treatments -- 
 update treatments 
 set treatment_cost = Null
 where treatment_cost <0;
 select * from treatments;

 ---- bussines_purposes_question answer ----
 
-- 1. Total Revenue Generated --
CREATE VIEW Total_revenue as 
select sum(total_amount) as Total_revenue from billing;

-- 2. Pending Payments --
CREATE VIEW total_pending as 
select payment_status,count(*) as total_pending
 from billing 
where payment_status = "Pending"
group by payment_status;
-- 3. Average Treatment Cost --
CREATE VIEW avg_treatment_cost as
select avg(treatment_cost) as avg_treatment_cost
from treatments;
-- 4. Emergency Severity Analysis --
CREATE VIEW total_severity_level as
select severity_level,count(*) as total_severity_level
from emergency_cases
group by severity_level;


SELECT * FROM departments;
SELECT * FROM doctors;
-- 5. Department-wise Doctor Count --
CREATE VIEW total_doctors as
select dp.department_name,count(d.doctor_id) as total_doctors 
from departments dp
join doctors d
on dp.department_id = d.department_id
group by dp.department_name;
-- 6. Highest Revenue Generating Patient --
CREATE VIEW revenue as
select p.patient_id,p.patient_name,
sum(b.paid_amount) as revenue 
from patients p
join billing b
on p.patient_id = b.patient_id
group by p.patient_id,p.patient_name
order by  revenue desc 
limit 1;
-- 7. Doctor-wise Average Rating --
CREATE VIEW avg_doctor_rating as 
select doctor_name,avg(doctor_rating) as avg_doctor_rating
from doctors 
group by doctor_name
order by avg_doctor_rating desc
limit 10;

-- 8. Top Revenue Generating Patients --
CREATE VIEW top_revenue_patients as 
select p.patient_name,sum(b.paid_amount) as spent 
from patients p 
left join billing b 
on p.patient_id = b.patient_id
group by p.patient_name
order by spent desc
limit 10;

-- 9. Doctors with More Than 50 Appointments --
CREATE VIEW doctor_wise_appointment as
select d.doctor_name,count(ap.appointment_id) as appointments 
from doctors d 
inner join appointments as ap
on d.doctor_id = ap.doctor_id
group by d.doctor_name
having count(appointment_id) > 50
order by appointments desc;

-- 10. Patients Spending Above Average --
CREATE VIEW avg_patient_spending as
select p.patient_id,p.patient_name,
sum(b.paid_amount) as patient_spending from patients p
left join billing b 
on p.patient_id = b.patient_id
group by p.patient_id,p.patient_name
having SUM(b.paid_amount) > (
    select avg(paid_amount)
    from billing
);

-- 11. Rank Doctors by Appointments -- 
CREATE VIEW Rank_Doctors_Appointments as
select 
d.doctor_id,d.doctor_name,count(ap.appointment_id) as total_appointment,
dense_rank() over(order by count(ap.appointment_id)desc) as rank_appointment
from doctors d
left join appointments ap
on d.doctor_id = ap.doctor_id
group by d.doctor_id,d.doctor_name;

-- 12. Running Revenue Total -- 
CREATE VIEW  running_total as
select billing_date,total_amount,
sum(total_amount) over (order by billing_date
rows between unbounded preceding and current row ) as running_total
from billing;

-- 13. Top 5 Revenue Patients --
CREATE VIEW Top_5_Revenue_Patients as
select 
p.patient_name,sum(b.paid_amount) as Revenue,
rank() over(order by sum(b.paid_amount) desc) as Patients_Revenue
from patients p 
join billing b
on p.patient_id = b.patient_id
group by p.patient_name
limit 5;

-- 14. Department-wise Average Doctor Rating -- 
CREATE VIEW  Department_wise_Average_Doctor_Rating as
select de.department_name,avg(d.doctor_rating) as avg_rating
from departments de 
left join doctors d 
on de.department_id = d.department_id
group by de.department_name
order by avg_rating desc; 
-- 15. Dense Rank by Revenue --
CREATE VIEW  Dense_Rank_wise_Revenue as 
select patient_id,sum(paid_amount) as revenue,
dense_rank() over(order by sum(paid_amount) desc) as rank_revenue
from billing
group by patient_id;
-- 16. Doctors with Above Average Rating --
CREATE VIEW  Doctors_Average_Rating as 
select doctor_name,doctor_rating
from doctors
where doctor_rating >
(select avg(doctor_rating) as avg_rating 
from doctors)
order by doctor_rating desc;

-- 17. Monthly Revenue Ranking --
CREATE VIEW Monthly_Revenue_rank_wise as 
select date_format(billing_date,'%Y-%m') as month_,sum(paid_amount) as revenue,
dense_rank() over(order by sum(paid_amount)desc) as monthly_revenue
from billing 
group by date_format(billing_date,'%Y-%m');



