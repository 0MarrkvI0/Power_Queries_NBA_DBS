
WITH shooting_per_game AS (
    SELECT
        p.first_name,
        p.last_name,
        pr.game_id,
        g.season_id,
        g.season_type,
        (SUM(CASE WHEN pr.event_msg_type = 'FIELD_GOAL_MADE' THEN 1 ELSE 0 END) * 1.0) /
        (SUM(CASE WHEN pr.event_msg_type IN ('FIELD_GOAL_MADE', 'FIELD_GOAL_MISSED') THEN 1 ELSE 0 END)) AS shooting_percentage
    FROM players AS p
    JOIN play_records AS pr
        ON p.id = pr.player1_id
    JOIN games AS g
        ON pr.game_id = g.id
    WHERE
        p.first_name = 'LeBron'
        AND p.last_name = 'James'
        AND g.season_type = 'Regular Season'
        AND g.season_id IN
        (
            SELECT g.season_id
            FROM players AS p
            JOIN play_records AS pr ON p.id = pr.player1_id
            JOIN games AS g ON pr.game_id = g.id
            WHERE p.first_name = 'LeBron'
            AND p.last_name = 'James'
            AND g.season_type = 'Regular Season'
            GROUP BY g.season_id
            HAVING COUNT(DISTINCT pr.game_id) >= 50
        )
    GROUP BY
        pr.game_id, p.first_name, p.last_name, g.season_id, g.season_type
),
game_shooting_diff AS (
    SELECT
        season_id,
        game_id,
        shooting_percentage,
        ROW_NUMBER() OVER (PARTITION BY season_id ORDER BY game_id) AS row_num
    FROM shooting_per_game
),
season_diff AS (
    SELECT
        season_id,
        game_id,
        shooting_percentage,
        COALESCE(LAG(shooting_percentage) OVER (PARTITION BY season_id ORDER BY game_id), shooting_percentage) AS prev_shooting_percentage
    FROM game_shooting_diff
)
SELECT
    season_id,
    ROUND(AVG(ABS(shooting_percentage - prev_shooting_percentage))*100,2) AS season_stability
FROM season_diff
GROUP BY season_id
ORDER BY season_stability,season_id;
