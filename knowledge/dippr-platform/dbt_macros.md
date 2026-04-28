---
title: dippr — Custom dbt Macros
type: dbt-macros
owner: data-platform-team
last_modified: 2026-04-28
status: legacy-import
imported_from: memory/project_dbt_macros.md
as_of_at_import: 2026-04-21
related:
---
All custom macros live flat at `dbt_e2_pipelines/macros/` (~46 files, ~55 macros). Dispatch order in `dbt_project.yml`: `["prodigy_dbt", "spark_utils", "dbt_utils"]` — custom wins over packages.

## Post-hook macros (applied to every silver/gold/gold_pii model)

Auto-called via `+post-hook` in `dbt_project.yml`.

- `set_ownership_macro()` (in `get_grants.sql`) — sets Unity Catalog ownership to the model's `meta.owner` group (Data Engineering, EdCROWs, etc.).
- `set_tags_macro()` (in `set_databricks_tags.sql`) — applies Unity Catalog tags to the model relation and columns.
- Related internals: `get_owner_group_macro(target_name)`, `get_alter_ownership_sql(resource, grp)`, `set_unity_catalog_tags(resource, tags)`.

## Schema / materialization overrides

- `generate_schema_name()` (in `get_custom_schema.sql`) — overrides dbt's default schema resolver; honors the target-conditional `+schema` blocks in `dbt_project.yml`.
- `get_incremental_merge_since_sql(arg_dict)` — custom incremental merge SQL for non-default merge windowing.
- `dev_limit.sql` — row/day limit helper; couples with `dev_limit_row` / `dev_limit_days` vars.
- `batch_load_offset_date(...)` — windowed batch-loading helper for incremental models with date fields.

## Date / period / school year

- `school_year(date_column)`, `first_day_of_school_year(date_column)`, `last_day_of_school_year(date_column)` — Prodigy school-year math.
- `mockable_current_date()`, `mockable_current_timestamp()` — date/time that can be mocked in tests.
- `parse_timezone(timezone)` — timezone-string parsing.
- `period_filter(...)`, `period_filter_monthly(...)` — incremental window filters.

## Event / Segment parsing (used heavily by silver event models)

- `create_event_view(event_row, source_table, source_name)` — generates per-event view SQL for `models/events/*.sql`.
- `canonical_event_type(event_title, event_type)` — normalizes event-type taxonomy.
- `extract_segment_trigger_field/operator/sub_field/value(trigger_predicate)` — parses Segment trigger predicate strings.
- `flatten_struct_array_with_index(struct_array, key_prefix)` — flattens nested struct arrays with positional index.

## Email / spam / PII filters

- `is_valid_email_format`, `is_prodigy_email_address`, `is_testing_email_account` — email classification.
- `is_redacted(name_col)`, `is_spam_account_name(name_col)` — name-quality checks.
- `filter_blacklisted_teacher_emails(email_col)`, `remove_student_emails_by_domain(domain)` — cleanup filters.
- `filter_reward_program_eligible_schools(country, province, school_id, source)` — reward-program eligibility.

## Marketing / attribution

- `campaign_name_parser(campaign_name_column)` — UTM campaign name parser.
- `channel_attribution(utm_source, utm_medium, referring_url)` — marketing channel classification.
- `gsc_is_branded_query(query)` — Google Search Console branded vs. nonbranded classifier.
- `is_sso_referrer(referring_url)` — SSO-referrer detection.
- `page_type_bucketer(path, path_end, url)` — URL-to-page-type classifier.

## String / hash / Spark-dispatched utilities

Override `dbt_utils`/`spark_utils` defaults via dispatch order:

- `spark__string_agg(field_to_agg, delimiter)` — string_agg override.
- `spark__hash(field)`, `spark__snapshot_hash_arguments(args)` — hash overrides for snapshot keys.
- `pad_trailing(expr, pad_char='/')` — string padding.
- `format_teacher_name(teacher_name_col)` — name normalization.
- `run_sql(query)` (in `sql_macro.sql`) — generic SQL exec helper.

## Dimensioning / pruning

- `dimension_pruning(dimension, ...)` — prunes long-tail dimension values below a bottom percentile; CTE or table output.
- `this_table_is_not_empty()` — emptiness check, commonly used as a sanity gate.
- `schooldigger_keys.sql` — `sd_norm(col)`, `sd_lpad(col, pad_size)`, `fips_district_uid(fips_state, fips_leaid)`, `fips_school_uid(fips_state, fips_leaid, fips_schoolid)` — SchoolDigger/FIPS key construction.

## Game-specific

- `player_level_cohort(player_level)` — bucket players by level for cohort analysis.

## Security

- `try_decrypt_with_identity_key(encrypted_value)` — decrypt using the internal Identity service key; returns NULL on failure.

## Databricks lineage / reflection

- `extract_reference_tables_from_databricks_sql(query_text)` — parses query text to discover referenced tables (for lineage).
- `transform_for_databricks_lineage_entity_name(string_value)` — entity-name normalization for Unity Catalog lineage.
