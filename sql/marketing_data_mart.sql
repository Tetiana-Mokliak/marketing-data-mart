WITH installs AS (
    SELECT
        firebase_analytic_app_id AS user_id,  --У межах цього тестового завдання firebase_analytic_app_id — найкращий доступний ідентифікатор інсталяції/екземпляра застосунку. Я умовно назвала його user_id, але це не справжній ідентифікатор людини.
        DATE(install_date) AS install_date,
        app_id,
        media_source,
        campaign_id,
        campaign_name
    FROM `your-project.your_dataset.non_org_installs_report`
    WHERE DATE(install_date) BETWEEN '2026-06-01' AND '2026-07-26'
),

ad_revenue_by_user AS (        --У цьому CTE для кожного умовного користувача з когорти інсталяцій 1 червня — 26 липня рахуємо весь доступний у таблиці рекламний дохід і кількість подій із позитивним доходом.
    SELECT
        firebase_analytic_app_id AS user_id,

        SUM(
            COALESCE(event_revenue_usd, 0)
        ) AS ad_revenue_usd,

        COUNTIF(
            event_revenue_usd > 0
        ) AS ad_revenue_events

    FROM `your-project.your_dataset.ad_revenue_raw`

    WHERE DATE(install_date) BETWEEN '2026-06-01' AND '2026-07-26'

    GROUP BY user_id
),

in_app_by_user AS (
    SELECT
        firebase_analytic_app_id AS user_id,

        -- Позитивні платежі та повернення зі знаком мінус
        SUM(
            COALESCE(event_revenue_usd, 0)
        ) AS in_app_revenue_usd,

        -- Користувач хоча б раз здійснив платіж
        MAX(
            IF(event_revenue_usd > 0, 1, 0)
        ) AS is_payer,

        COUNTIF(
            event_name = 'trial_started'
        ) AS trial_starts,

        COUNTIF(
            event_name = 'trial_converted'
        ) AS trial_conversions,

        COUNTIF(
            event_name = 'no_trial_sub_started'
        ) AS direct_subscriptions,

        COUNTIF(
            event_name = 'subscription_renewed'
        ) AS renewals,

        COUNTIF(
            event_name = 'subscription_refunded'
        ) AS refunds

    FROM `your-project.your_dataset.in_app_events_report`

    WHERE DATE(install_date) BETWEEN '2026-06-01' AND '2026-07-26'

    GROUP BY user_id
),

campaign_performance AS (
    SELECT
        i.install_date,
        i.app_id,
        i.media_source,
        i.campaign_id,

        ANY_VALUE(
            i.campaign_name
        ) AS campaign_name,

        COUNT(*) AS installs,

        COUNTIF(
            a.ad_revenue_usd > 0
        ) AS ad_revenue_users,

        COUNTIF(
            p.is_payer = 1
        ) AS payers,

        SUM(
            COALESCE(a.ad_revenue_events, 0)
        ) AS ad_revenue_events,

        SUM(
            COALESCE(p.trial_starts, 0)
        ) AS trial_starts,

        SUM(
            COALESCE(p.trial_conversions, 0)
        ) AS trial_conversions,

        SUM(
            COALESCE(p.direct_subscriptions, 0)
        ) AS direct_subscriptions,

        SUM(
            COALESCE(p.renewals, 0)
        ) AS renewals,

        SUM(
            COALESCE(p.refunds, 0)
        ) AS refunds,

        SUM(
            COALESCE(a.ad_revenue_usd, 0)
        ) AS ad_revenue_usd,

        SUM(
            COALESCE(p.in_app_revenue_usd, 0)
        ) AS in_app_revenue_usd

    FROM installs AS i

    LEFT JOIN ad_revenue_by_user AS a
        USING (user_id)

    LEFT JOIN in_app_by_user AS p
        USING (user_id)

    GROUP BY
        i.install_date,
        i.app_id,
        i.media_source,
        i.campaign_id
),

campaign_costs AS (
    SELECT
        SAFE_CAST(date AS DATE) AS install_date,
        app_id,
        media_source,
        campaign_id,

        ANY_VALUE(
            campaign
        ) AS campaign_name,

        SUM(cost_usd) AS cost_usd,
        SUM(impressions) AS impressions,
        SUM(clicks) AS clicks

    FROM `your-project.your_dataset.cost_table`

    WHERE SAFE_CAST(date AS DATE)
        BETWEEN '2026-06-01' AND '2026-07-26'

    GROUP BY
        install_date,
        app_id,
        media_source,
        campaign_id
),

joined AS (
    SELECT
        COALESCE(
            p.install_date,
            c.install_date
        ) AS install_date,

        COALESCE(
            p.app_id,
            c.app_id
        ) AS app_id,

        COALESCE(
            p.media_source,
            c.media_source
        ) AS media_source,

        COALESCE(
            p.campaign_id,
            c.campaign_id
        ) AS campaign_id,

        COALESCE(
            p.campaign_name,
            c.campaign_name
        ) AS campaign_name,

        COALESCE(c.impressions, 0) AS impressions,
        COALESCE(c.clicks, 0) AS clicks,

        COALESCE(p.installs, 0) AS installs,
        COALESCE(p.ad_revenue_users, 0) AS ad_revenue_users,
        COALESCE(p.payers, 0) AS payers,

        COALESCE(p.ad_revenue_events, 0) AS ad_revenue_events,
        COALESCE(p.trial_starts, 0) AS trial_starts,
        COALESCE(p.trial_conversions, 0) AS trial_conversions,

        COALESCE(
            p.direct_subscriptions,
            0
        ) AS direct_subscriptions,

        COALESCE(p.renewals, 0) AS renewals,
        COALESCE(p.refunds, 0) AS refunds,

        COALESCE(c.cost_usd, 0) AS cost_usd,

        COALESCE(
            p.ad_revenue_usd,
            0
        ) AS ad_revenue_usd,

        COALESCE(
            p.in_app_revenue_usd,
            0
        ) AS in_app_revenue_usd

    FROM campaign_performance AS p

    FULL OUTER JOIN campaign_costs AS c
        USING (
            install_date,
            app_id,
            media_source,
            campaign_id
        )
),

calculated AS (
    SELECT
        *,

        ad_revenue_usd
            + in_app_revenue_usd
            AS total_revenue_usd,

        ad_revenue_usd
            + in_app_revenue_usd
            - cost_usd
            AS profit_usd,        --дохід мінус зафіксовані витрати на залучення

        CASE
            WHEN campaign_id IS NULL
                THEN 'Unattributed'

            WHEN cost_usd > 0
                AND installs > 0
                THEN 'Matched paid campaign'

            WHEN cost_usd > 0
                AND installs = 0
                THEN 'Cost without installs'  --Витрати є, але установок за відповідною комбінацією ключів не знайдено

            WHEN cost_usd = 0
                AND installs > 0
                THEN 'Installs without cost'  --установки без зіставлених витрат

            ELSE 'Other'
        END AS attribution_status,

        campaign_id IS NOT NULL
            AS is_attributed_campaign

    FROM joined
)

SELECT
    install_date,
    app_id,
    media_source,
    campaign_id,
    campaign_name,
    attribution_status,
    is_attributed_campaign,

    impressions,
    clicks,
    installs,
    ad_revenue_users,
    payers,

    ad_revenue_events,
    trial_starts,
    trial_conversions,
    direct_subscriptions,
    renewals,
    refunds,

    cost_usd,
    ad_revenue_usd,
    in_app_revenue_usd,
    total_revenue_usd,
    profit_usd,

    SAFE_DIVIDE(
        total_revenue_usd,
        cost_usd
    ) AS roas,

    SAFE_DIVIDE(
        cost_usd,
        installs
    ) AS cpi,

    SAFE_DIVIDE(
        total_revenue_usd,
        installs
    ) AS revenue_per_install,

    SAFE_DIVIDE(
        clicks,
        impressions
    ) AS ctr,

    SAFE_DIVIDE(
        installs,
        clicks
    ) AS click_to_install_rate,

    SAFE_DIVIDE(
        payers,
        installs
    ) AS payer_conversion_rate,

    SAFE_DIVIDE(
        trial_conversions,
        trial_starts
    ) AS trial_conversion_rate,

    SAFE_DIVIDE(
        in_app_revenue_usd,
        payers
    ) AS in_app_arppu

FROM calculated

ORDER BY
    install_date,
    campaign_id;