WITH selected_events AS (
    SELECT
        pr.game_id,
        pr.player1_id AS player_id,
        pr.player1_team_id AS team_id,
        pr.event_msg_type,
        pr.score,
        '1' AS p_num
    FROM play_records pr
    JOIN games g ON g.id = pr.game_id
    WHERE g.season_id =  '22017'
      AND pr.event_msg_type IN ('FREE_THROW', 'FIELD_GOAL_MADE', 'FIELD_GOAL_MISSED', 'REBOUND')

    UNION ALL

    SELECT
        pr.game_id,
        pr.player2_id AS player_id,
        pr.player2_team_id AS team_id,
        pr.event_msg_type,
        pr.score,
        '2' AS p_num
    FROM play_records pr
    JOIN games g ON g.id = pr.game_id
    WHERE g.season_id =  '22017'
      AND pr.event_msg_type IN ('FREE_THROW', 'FIELD_GOAL_MADE', 'FIELD_GOAL_MISSED', 'REBOUND')
),

five_players AS (
    SELECT
        se.player_id,
        COUNT(DISTINCT team_id) - 1 AS switch_count
    FROM selected_events se
    JOIN players p ON p.id = se.player_id
    GROUP BY se.player_id, p.is_active, p.last_name, p.first_name
    ORDER BY switch_count DESC, p.is_active DESC, p.last_name, p.first_name
    LIMIT 5
),

statistic AS (
    SELECT
        se.player_id,
        se.team_id,

        COUNT(*) FILTER (
            WHERE se.event_msg_type = 'FIELD_GOAL_MADE' AND se.p_num = '1'
        ) * 2
        +
        COUNT(*) FILTER (
            WHERE se.event_msg_type = 'FREE_THROW' AND se.p_num = '1' AND se.score IS NOT NULL
        ) AS point_count,

        COUNT(*) FILTER (
            WHERE se.event_msg_type = 'FIELD_GOAL_MADE' AND se.p_num = '2'
        )
        +
        COUNT(*) FILTER (
            WHERE se.event_msg_type = 'FREE_THROW' AND se.p_num = '2' AND se.score IS NOT NULL
        ) AS assist_count,

        COUNT(DISTINCT se.game_id) AS game_count

    FROM selected_events se
    WHERE se.player_id IN (SELECT fp.player_id FROM five_players fp)
    GROUP BY se.player_id, se.team_id
)

SELECT
    s.player_id,
    p.first_name,
    p.last_name,
    t.id AS team_id,
    t.full_name,
    ROUND(CAST(s.point_count AS NUMERIC) / s.game_count, 2) AS ppg,
    ROUND(CAST(s.assist_count AS NUMERIC) / s.game_count, 2) AS apg,
    s.game_count AS games
FROM statistic s
JOIN players p ON p.id = s.player_id
JOIN teams t ON t.id = s.team_id
ORDER BY s.player_id, s.team_id;
