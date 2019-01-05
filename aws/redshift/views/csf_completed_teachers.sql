drop view analysis.csf_completed_teachers;
create view analysis.csf_completed_teachers as
select 
  user_id,
  school_year, 
  script_id,
  script_name,
  completed_at
from
(
  select 
    se.user_id, 
    com.school_year,
    com.script_id,
    com.script_name,
    completed_at,
    row_number() over(partition by se.user_id, com.school_year order by completed_at asc) completed_at_order
  from analysis.csf_completed com
    join analysis.school_years sy on com.completed_at between sy.started_at and sy.ended_at
    join dashboard_production.followers f on f.student_user_id = com.user_id and f.created_at between sy.started_at and sy.ended_at
    join dashboard_production.sections se on se.id = f.section_id
)
where completed_at_order = 5
with no schema binding; 

GRANT ALL PRIVILEGES ON analysis.csf_completed_teachers TO GROUP admin;
GRANT SELECT ON analysis.csf_completed_teachers TO GROUP reader, GROUP reader_pii;
