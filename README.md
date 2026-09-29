[Українська](#українська) · [English](#english)

## Українська

# Маркетингова вітрина

Проєкт створено в межах тестового завдання на позицію аналітика даних. У BigQuery я об’єднала дані про встановлення застосунку, рекламний дохід, події всередині застосунку та витрати на кампанії. У Tableau візуалізувала ефективність кампаній і якість атрибуції.

Дозвіл компанії на використання матеріалів тестового завдання для публікації проєкту отримано.

**[Переглянути інтерактивний дашборд у Tableau Public](https://public.tableau.com/app/profile/tania.mokliak/viz/Marketing_Campaign_Performance_Dashboard/MarketingCampaignPerformanceDahboard)**

## Файли

| Файл | Вміст |
| --- | --- |
| [`sql/marketing_data_mart.sql`](sql/marketing_data_mart.sql) | SQL-запит для побудови вітрини на рівні кампанії |
| [`data/marketing_data_mart.csv`](data/marketing_data_mart.csv) | Експорт готової вітрини у CSV |
| [`data/marketing_data_mart.xlsx`](data/marketing_data_mart.xlsx) | Експорт готової вітрини в Excel |
| [`docs/data_diagnostics.xlsx`](docs/data_diagnostics.xlsx) | Перевірки ідентифікаторів, з’єднань і гранулярності джерел |
| [`docs/project_description.docx`](docs/project_description.docx) | Докладний опис методології та висновків |
| [`dashboard/marketing_mart.pdf`](dashboard/marketing_mart.pdf) | PDF-експорт чотирьох сторінок дашборду |

## Підхід

- **Рівень вітрини:** дата встановлення × застосунок × рекламне джерело × ID кампанії.
- **Період:** 1 червня — 26 липня 2026 року, спільне вікно з доступними даними про витрати.
- **Об’єднання:** рекламний та in-app дохід спочатку агреговано за ідентифікатором інсталяції, а витрати — до рівня кампанії. `FULL OUTER JOIN` зберігає також витрати без інсталяцій та інсталяції без зіставлених витрат.
- **Показники:** інсталяції, витрати, рекламний та in-app дохід, прибуток, ROAS, CPI, конверсії і статус атрибуції. Дохід відображає лише доступний період спостереження; це не оцінка повного LTV.

У SQL використано шаблонні шляхи BigQuery (`your-project.your_dataset`). Перед запуском їх потрібно замінити на власний проєкт і датасет із таблицями `non_org_installs_report`, `ad_revenue_raw`, `in_app_events_report` та `cost_table`. Експорти дають змогу переглянути результат і дашборд без доступу до вихідних таблиць.

ШІ допомагав формувати аналітичні гіпотези, перевіряти SQL і структурувати опис. Ключі з’єднання, рівні агрегації та розрахунки я окремо перевіряла діагностичними запитами й контрольними сумами.

---

## English

# Marketing Data Mart

I built this project for a data analyst take-home assignment. In BigQuery, I combined app install data, ad revenue, in-app events, and campaign costs. In Tableau, I visualized campaign performance and attribution quality.

The company granted permission to use the assignment materials for this public project.

**[View the interactive dashboard on Tableau Public](https://public.tableau.com/app/profile/tania.mokliak/viz/Marketing_Campaign_Performance_Dashboard/MarketingCampaignPerformanceDahboard)**

### Files

| File | Contents |
| --- | --- |
| [`sql/marketing_data_mart.sql`](sql/marketing_data_mart.sql) | SQL query that builds the campaign-level data mart |
| [`data/marketing_data_mart.csv`](data/marketing_data_mart.csv) | Export of the completed data mart in CSV format |
| [`data/marketing_data_mart.xlsx`](data/marketing_data_mart.xlsx) | Export of the completed data mart in Excel format |
| [`docs/data_diagnostics.xlsx`](docs/data_diagnostics.xlsx) | Checks of identifiers, joins, and source-data grain |
| [`docs/project_description.docx`](docs/project_description.docx) | Detailed methodology and findings (in Ukrainian) |
| [`dashboard/marketing_mart.pdf`](dashboard/marketing_mart.pdf) | PDF export of the four dashboard pages |

### Methodology

- **Data mart grain:** install date × app × media source × campaign ID.
- **Period:** June 1–July 26, 2026, the common window with available cost data.
- **Joins:** ad and in-app revenue were first aggregated by installation identifier; costs were aggregated to campaign level. A `FULL OUTER JOIN` also retains costs without matched installs and installs without matched costs.
- **Metrics:** installs, costs, ad and in-app revenue, profit, ROAS, CPI, conversion rates, and attribution status. Revenue covers only the available observation period; it is not an estimate of full LTV.

The SQL uses placeholder BigQuery paths (`your-project.your_dataset`). Before running it, replace them with your own project and dataset containing `non_org_installs_report`, `ad_revenue_raw`, `in_app_events_report`, and `cost_table`. The exports let you inspect the result and dashboard without access to the source tables.

AI helped generate analytical hypotheses, review SQL, and organize the description. I independently checked join keys, aggregation levels, and calculations using diagnostic queries and reconciliation totals.
