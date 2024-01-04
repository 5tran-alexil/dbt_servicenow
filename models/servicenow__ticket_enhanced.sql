
with task as (
    
  select *
  from {{ ref('stg_servicenow__task') }}
),

problem_task as (
    
  select *
  from {{ ref('stg_servicenow__problem_task') }}
),
problem as (
    
  select *
  from {{ ref('stg_servicenow__problem') }}
),
-- actually, because the relationship between incident and problem is many to many, it wouldn't make sense to left join Incident > Problem > Task. Therefore Incident would need to be its own model. So we won't use incident table in the Task Enhanced Mode. But we will use stg_sn__incident to create an aggregated model on the Problem grain in order to left join metrics like sum(incidents) per problem

incident as (
    
  select *
  from {{ ref('stg_servicenow__incident') }}
),

incidents_per_problem as (

  select
    problem_id_value,
    count(distinct incident_id) as total_incidents
    -- ideally would have fields such as 'total_high_severity_incidents' and 'total_medium_severity_incidents' that would tell you incidents per problem by severity. But severity level is customizable so we may be limited here
  from incident
  group by 1
),

change_task as (
    
  select *
  from {{ ref('stg_servicenow__change_task') }}
),

change_request as (
    
  select *
  from {{ ref('stg_servicenow__change_request') }}
),

sys_user as (
    
  select *
  from {{ ref('stg_servicenow__sys_user') }}
),

task_enhanced as (

select 

  task.task_id,
  task.is_task_active,
  task.task_description,
  task.activity_due,
  task.priority,
  task.impact,
  task.urgency,
  task.task_state,
  task.task_number,
  task.task_order,
  case when task.task_id in (select task_id from problem_task) then true else false end as is_problem_task,
  case when task.task_id in (select task_id from change_task) then true else false end as is_change_task,
  task.task_created_at,
  task.sys_created_by,
  creator.email as creator_email,
  creator.manager_value as creator_manager_value,
  creator.department_value as creator_department_value,
  creator.sys_user_name as creator_name,
  creator.roles as creator_roles,
  task.task_updated_at,
  task.sys_updated_by,
  updater.email as updater_email,
  updater.manager_value as updater_manager_value,
  updater.department_value as updater_department_value,
  updater.sys_user_name as updater_name,
  updater.roles as updater_roles,
  task.task_opened_at,
  task.opened_by_link,
  task.opened_by_value, 
  opener.manager_value as opener_manager_value,
  opener.email as opener_email,
  opener.department_value as opener_department_value,
  opener.sys_user_name as opener_name,
  opener.roles as opener_roles,
  task.assigned_to_link,
  task.assigned_to_value,
  assignee.email as assignee_email,
  assignee.manager_value as assignee_manager_value,
  assignee.department_value as assignee_department_value,
  assignee.sys_user_name as assignee_name,
  assignee.roles as assignee_roles,
  task.task_closed_at,
  {{ dbt.datediff("task.task_created_at", "task.task_closed_at", 'minute') }} as task_minutes_to_close,
  task.closed_by_link,
  task.closed_by_value,
  closer.email as closer_email,
  closer.manager_value as closer_manager_value,
  closer.department_value as closer_department_value,
  closer.sys_user_name as closer_name,
  closer.roles as closer_roles,
  task.task_effective_number,
  task.additional_assignee_list,
  task.approval,
  task.approval_history,
  task.approval_set,
  task.assignment_group_link,
  task.assignment_group_value,
  task.business_duration,
  task.calendar_duration,
  task.business_service_link,
  task.business_service_value,
  task.close_notes,
  task.comments,
  task.comments_and_work_notes,
  task.company_link,
  task.company_value, 
  task.contact_type, 
  task.task_due_date_at,
  task.expected_start,
  task.task_follow_up_at,
  task.group_list,
  task.knowledge,
  task.made_sla,
  task.sla_due,
  task.parent_link, 
  task.parent_value,
  task.reassignment_count,
  task.route_reason,
  task.short_description,
  task.sys_class_name,
  task.sys_domain_link,
  task.sys_domain_path,
  task.sys_domain_value,
  task.upon_approval,
  task.upon_reject,
  task.watch_list,
  task.work_start,
  task.work_end,
  task.work_notes,
  task.work_notes_list,
  problem_task.problem_task_cause_code,
  problem_task.problem_task_close_code,
  problem_task.problem_task_started_at,
  problem_task.started_by_link,
  problem_task.started_by_value,
  problem_task_starter.email as problem_task_starter_email,
  problem_task_starter.manager_value as problem_task_starter_manager_value,
  problem_task_starter.department_value as problem_task_starter_department_value,
  problem_task_starter.sys_user_name as problem_task_starter_name,
  problem_task_starter.roles as problem_task_starter_roles, 
  problem.problem_id as associated_problem_id,
  problem.problem_category,
  problem.cause_notes,
  incidents_per_problem.total_incidents as total_incidents_caused_by_problem,
  problem.problem_confirmed_at,
  problem.problem_confirmed_by_value,
  problem_confirmer.email as problem_confirmer_email,
  problem_confirmer.manager_value as problem_confirmer_manager_value,
  problem_confirmer.department_value as problem_confirmer_department_value,
  problem_confirmer.sys_user_name as problem_confirmer_name,
  problem_confirmer.roles as problem_confirmer_roles,
  problem.problem_first_reported_by_task_value,
  problem_reporter.email as problem_reporter_email,
  problem_reporter.manager_value as problem_reporter_manager_value,
  problem_reporter.department_value as problem_reporter_department_value,
  problem_reporter.sys_user_name as problem_reporter_name,
  problem_reporter.roles as problem_reporter_roles,
  problem.problem_fix_at,
  problem.problem_fix_by_value,
  problem_fixer.email as problem_fixer_email,
  problem_fixer.manager_value as problem_fixer_manager_value,
  problem_fixer.department_value as problem_fixer_department_value,
  problem_fixer.sys_user_name as problem_fixer_name,
  problem_fixer.roles as problem_fixer_roles,
  problem.problem_fix_notes,
  problem.is_known_error as problem_is_known_error,
  problem.is_major_problem,
  problem.problem_state,
  problem.problem_related_incidents,
  problem.problem_resolution_code,
  problem.problem_resolved_at,
  problem.problem_resolved_by_value,
  problem_resolver.email as problem_resolver_email,
  problem_resolver.manager_value as problem_resolver_manager_value,
  problem_resolver.department_value as problem_resolver_department_value,
  problem_resolver.sys_user_name as problem_resolver_name,
  problem_resolver.roles as problem_resolver_roles,
  problem.problem_subcategory,
  problem.problem_created_at,
  problem.problem_updated_at,
  {{ dbt.datediff("problem.problem_created_at", "problem.problem_resolved_at", 'minute') }} as problem_minutes_to_resolve,
  change_task.change_task_type,
  change_task.change_task_close_code,
  change_task.change_task_created_from,
  change_task.is_change_on_hold,
  change_task.change_on_hold_reason,
  change_task.change_task_planned_end_date,
  change_task.change_task_planned_start_date,
  change_request.change_request_id,
  change_request.change_request_category,
  change_request.change_plan,
  change_request.change_request_close_code,
  change_request.change_request_end_date,
  change_request.change_request_implementation_plan,
  change_request.change_request_justification,
  change_request.is_change_request_on_hold,
  change_request.change_request_on_hold_reason,
  change_request.change_request_phase,
  change_request.change_request_phase_state,
  change_request.change_request_reason,
  change_request.change_requested_by_date,
  change_request.change_requested_by_value,
  change_requester.email as change_requester_email,
  change_requester.manager_value as change_requester_manager_value,
  change_requester.department_value as change_requester_department_value,
  change_requester.sys_user_name as change_requester_name,
  change_requester.roles as change_requester_roles,
  change_request.change_request_review_date,
  change_request.change_request_review_status,
  change_request.change_request_risk,
  change_request.change_request_scope,
  change_request.change_request_start_date,
  change_request.change_request_test_plan,
  change_request.change_request_type

from task
left join problem_task
  on task.task_id = problem_task.problem_task_id
left join sys_user problem_task_starter
  on problem_task.started_by_value = problem_task_starter.user_id
left join problem
  on problem_task.problem_value = problem.problem_id
left join sys_user problem_confirmer
  on problem.problem_confirmed_by_value = problem_confirmer.user_id
left join sys_user problem_reporter
  on problem.problem_first_reported_by_task_value = problem_reporter.user_id
left join sys_user problem_fixer
  on problem.problem_fix_by_value = problem_fixer.user_id
left join sys_user problem_resolver
  on problem.problem_resolved_by_value = problem_resolver.user_id
left join incidents_per_problem
  on incidents_per_problem.problem_id_value = problem.problem_id
left join change_task
  on task.task_id = change_task.change_task_id
left join change_request
  on change_task.change_request_value = change_request.change_request_id
left join sys_user change_requester
  on change_request.change_requested_by_value = change_requester.user_id
left join sys_user assignee
  on task.assigned_to_value = assignee.user_id
left join sys_user closer 
  on task.closed_by_value = closer.user_id
left join sys_user opener
  on task.opened_by_value = opener.user_id
left join sys_user creator
  on task.sys_created_by = creator.user_id
left join sys_user updater
  on task.sys_updated_by = updater.user_id
)

select *
from task_enhanced
