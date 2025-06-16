with statistic as (
SELECT sub.game_id,
     sub.player_id,
     sub.points,
     sub.assists,
     sub.rebounds,
     CASE
         WHEN sub.points >= 10
             AND sub.assists >= 10
             AND sub.rebounds >= 10
             THEN 1
         ELSE 0
         END AS "X"
  FROM (SELECT pr.game_id,
               p.id     AS player_id,
               SUM(CASE
                       WHEN pr.event_msg_type = 'FIELD_GOAL_MADE' AND pr.player1_id = p.id THEN 2
                   WHEN pr.event_msg_type = 'FREE_THROW' AND pr.score IS NOT NULL AND pr.player1_id = p.id
                       THEN 1
                   ELSE 0
               END) AS points,
           COUNT(CASE
                     WHEN pr.event_msg_type = 'FIELD_GOAL_MADE' AND pr.player2_id = p.id THEN 1
                     ELSE NULL
               END) AS assists,
           COUNT(CASE
                     WHEN pr.event_msg_type = 'REBOUND' AND pr.player1_id = p.id THEN 1
                     ELSE NULL
               END) AS rebounds
    FROM play_records AS pr
             JOIN games AS g
                  ON pr.game_id = g.id
             JOIN players AS p
                  ON p.id = pr.player1_id OR p.id = pr.player2_id
    WHERE g.season_id = '22018'
      AND pr.event_msg_type IN ('FIELD_GOAL_MADE', 'FREE_THROW', 'REBOUND')
    GROUP BY pr.game_id, p.id) AS sub
),
Streaks AS (
    SELECT
        stat.game_id,
        stat.player_id,
        stat."X",
        ROW_NUMBER() OVER (partition by stat.player_id ORDER BY stat.game_id) - ROW_NUMBER() OVER (PARTITION BY stat.player_id, stat."X" ORDER BY stat.game_id) AS streak_group
    FROM statistic stat
)
select
    StreaksCount.player_id,
    MAX(StreaksCount.streak_count) AS longest_streak
FROM (
    SELECT
        s.player_id,
        COUNT(*) AS streak_count
    FROM Streaks s
    WHERE s."X" = 1
    GROUP by s.player_id, s.streak_group
) AS StreaksCount
group by StreaksCount.player_id
order by longest_streak desc, player_id asc;