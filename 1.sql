SELECT
    player_id,
    first_name,
    last_name,
    period,
    period_time
FROM (
    SELECT
        p.id AS "player_id",
        p.first_name,
        p.last_name,
        pr.period,
        pr.pctimestring AS "period_time",
        pr.player1_id,
        pr.event_msg_type AS field_goal_made_event,
        LAG(pr.event_msg_type) OVER (ORDER BY pr.event_number) AS previous_event,
        LAG(pr.player1_id) OVER (ORDER BY pr.event_number) AS previous_player
    FROM play_records AS pr
    JOIN players AS p ON p.id = pr.player1_id
    WHERE pr.game_id = {{game_id}}  /* 22000529 */
    ORDER BY pr.event_number
) AS subquery
WHERE previous_player = subquery.player1_id
  AND previous_event = 'REBOUND'
  AND field_goal_made_event = 'FIELD_GOAL_MADE'
ORDER BY period,period_time DESC,player_id;



with all_records as (
    SELECT pr.game_id,pr.event_number,pr.event_msg_type,pr.period,pr.player1_id,pr.pctimestring,
               lag(pr.event_msg_type) over (partition by pr.game_id order by pr.event_number) as prev_event,
               lag(pr.event_number) over (partition by pr.game_id order by pr.event_number) as prev_number,
               lag(pr.player1_id) over (partition by pr.game_id order by pr.event_number) as prev_player
    FROM play_records pr
    WHERE pr.event_msg_type = 'REBOUND' OR pr.event_msg_type = 'FIELD_GOAL_MADE' AND pr.game_id = 22000529
)

SELECT p.id,p.first_name,p.last_name,f.period,f.pctimestring as period_time
FROM all_records f
JOIN players p ON p.id = f.player1_id
WHERE f.event_msg_type = 'FIELD_GOAL_MADE' AND f.prev_event = 'REBOUND' AND f.event_number - f.prev_number = 1 AND f.prev_player = f.player1_id
ORDER BY f.period,f.pctimestring DESC,p.id




