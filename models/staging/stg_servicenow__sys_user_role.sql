{{ config(enabled=var('servicenow__using_roles', False)) }}

with base as (

    select * 
    from {{ ref('stg_servicenow__sys_user_role_base') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_servicenow__sys_user_role_base')),
                staging_columns=get_sys_user_role_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='servicenow_union_schemas', 
            union_database_variable='servicenow_union_databases') 
        }}
    from base
),

final as (
    
    select 
        source_relation, 
        cast(sys_id as {{ dbt.type_string() }}) as sys_user_role_id,
        name as sys_user_role_name,
        description as sys_user_role_description,
        sys_created_on,
        sys_updated_on
        _fivetran_deleted,
        _fivetran_synced,
        assignable_by_link,
        assignable_by_value,
        can_delegate,
        elevated_privilege,
        grantable,
        includes_roles,
        requires_subscription,
        scoped_admin,
        suffix
    from fields
)

select *
from final
