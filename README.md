# Marketing Data Mart

A marketing performance data mart built as a data analyst take-home assignment. The project combines app installs, ad revenue, in-app events, and campaign costs in BigQuery, then explores campaign performance and attribution in Tableau.

## Files

| File | Contents |
| --- | --- |
| [`sql/marketing_data_mart.sql`](sql/marketing_data_mart.sql) | BigQuery SQL for the campaign-level data mart |
| [`data/marketing_data_mart.csv`](data/marketing_data_mart.csv) | Export of the resulting data mart |
| [`data/marketing_data_mart.xlsx`](data/marketing_data_mart.xlsx) | Spreadsheet export of the data mart |
| [`docs/data_diagnostics.xlsx`](docs/data_diagnostics.xlsx) | Checks of identifiers, joins, and source-data granularity |
| [`docs/project_description.docx`](docs/project_description.docx) | Detailed methodology and findings (Ukrainian) |
| [`dashboard/marketing_mart.pdf`](dashboard/marketing_mart.pdf) | Four-page dashboard export |

## Approach

- **Grain:** install date × app × media source × campaign ID.
- **Period:** June 1–July 26, 2026, the shared window with available campaign costs.
- **Joining:** revenue and in-app events are aggregated by installation identifier before being joined to installs; costs are aggregated separately to the campaign grain. A full outer join retains unmatched costs and installs.
- **Metrics:** installs, costs, ad and in-app revenue, profit, ROAS, CPI, conversion rates, and attribution status. Revenue is observed within the available data window; it is not a lifetime-value estimate.

The SQL uses placeholder BigQuery paths (`your-project.your_dataset`). Replace them with a dataset containing `non_org_installs_report`, `ad_revenue_raw`, `in_app_events_report`, and `cost_table` before running it. The included exports allow the results and dashboard to be reviewed without access to the original source tables.

AI assisted with hypothesis generation, SQL review, and organizing the written explanation. Join keys, aggregation levels, and calculations were checked using diagnostic queries and control totals.
